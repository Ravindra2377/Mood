import XCTest
import CoreData
@testable import Mood

/// Integration-style unit test: simulate 401 on first upload, ensure token refresh is attempted and upload retried.
final class SyncManagerRefreshFlowTests: XCTestCase {
    var persistence: InMemoryPersistence!
    var session: URLSession!
    var apiClient: APIClient!
    var syncManager: SyncManager!
    var tokenProvider: TestTokenProvider!

    override func setUp() {
        super.setUp()
        persistence = InMemoryPersistence()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)

        tokenProvider = TestTokenProvider(initialToken: "old-token")
        apiClient = APIClient(baseURL: URL(string: "https://api.example.com")!, session: session, tokenProvider: tokenProvider)
        syncManager = SyncManager(context: persistence.container.newBackgroundContext(), api: apiClient)

        // seed one unsynced entry
        let ctx = persistence.container.viewContext
        let entry = MoodEntry(context: ctx)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.rating = 4
        entry.note = "Needs refresh"
        entry.synced = false
        try! ctx.save()
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        persistence = nil
        session = nil
        apiClient = nil
        syncManager = nil
        tokenProvider = nil
        super.tearDown()
    }

    func test401TriggersRefreshAndRetry() throws {
        // Handler logic: first /api/moods with old-token -> 401, refresh endpoint -> 200 with new-token, then /api/moods with new-token -> 201
        var uploadCallCount = 0
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else { throw URLError(.badURL) }
            if url.path == "/api/moods" {
                uploadCallCount += 1
                let auth = request.value(forHTTPHeaderField: "Authorization") ?? ""
                if auth.contains("old-token") {
                    let resp = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
                    return (resp, nil)
                } else if auth.contains("new-token") {
                    let resp = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: nil)!
                    return (resp, nil)
                } else {
                    let resp = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!
                    return (resp, nil)
                }
            } else if url.path == "/auth/refresh" {
                let payload = ["access_token": "new-token", "refresh_token": "r"]
                let data = try JSONSerialization.data(withJSONObject: payload, options: [])
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            throw URLError(.badURL)
        }

        let exp = expectation(description: "sync-refresh")
        syncManager.syncPending { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, 1)
                // verify DB marked synced
                let ctx = self.persistence.container.viewContext
                let fetch: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
                fetch.fetchLimit = 10
                let all = try! ctx.fetch(fetch)
                XCTAssertTrue(all.first?.synced == true)
            case .failure(let err):
                XCTFail("Expected success but got \(err)")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
        XCTAssertGreaterThanOrEqual(uploadCallCount, 2)
        XCTAssertTrue(tokenProvider.refreshCalled)
    }
}

// Simple in-test TokenProvider that stores token in memory and implements refresh by setting a new token
fileprivate class TestTokenProvider: TokenProvider {
    private var token: String?
    var refreshCalled = false

    init(initialToken: String?) {
        self.token = initialToken
    }

    func getToken() -> String? {
        return token
    }

    func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        refreshCalled = true
        // Simulate network refresh; in this test, MockURLProtocol will intercept refresh request and return new token
        // But to simulate realistic behavior, we'll perform a tiny URLSession call using the shared configuration
        // For simplicity, set new token immediately (the SyncManager's refresh path expects completion to be called after network)
        // In this test environment, the SyncManager triggers api.tokenProvider.refreshToken, and our test's MockURLProtocol
        // will have already registered a handler for /auth/refresh, but APIClient isn't making that call; so we simulate refresh by setting directly.
        // Set token to new-token to emulate successful refresh
        self.token = "new-token"
        completion(.success("new-token"))
    }
}
