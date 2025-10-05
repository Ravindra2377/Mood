import XCTest
import CoreData
import Combine
@testable import Mood

final class SyncManagerConcurrentAndFailureTests: XCTestCase {
    var persistence: InMemoryPersistence!
    var session: URLSession!
    var apiClient: APIClient!
    var syncManager: SyncManager!
    var tokenProvider: NetworkTestTokenProvider!

    override func setUp() {
        super.setUp()
        persistence = InMemoryPersistence()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)

        let baseURL = URL(string: "https://api.example.com")!
        tokenProvider = NetworkTestTokenProvider(accessToken: "old-token", refreshToken: "seed-refresh", session: session, refreshURL: baseURL.appendingPathComponent("/api/auth/refresh"))
        apiClient = APIClient(baseURL: baseURL, session: session, tokenProvider: tokenProvider)
        syncManager = SyncManager(context: persistence.container.newBackgroundContext(), api: apiClient)
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

    func testConcurrent401sTriggersSingleRefreshAndAllSucceed() throws {
        // Seed 3 unsynced entries
        let ctx = persistence.container.viewContext
        for i in 0..<3 {
            let entry = MoodEntry(context: ctx)
            entry.id = UUID()
            entry.timestamp = Date()
            entry.rating = Int16(3 + i)
            entry.note = "entry \(i)"
            entry.synced = false
        }
        try ctx.save()

        var moodUploadCount = 0
        var refreshCount = 0

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else { throw URLError(.badURL) }
            if url.path == "/api/moods" {
                moodUploadCount += 1
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
            } else if url.path == "/api/auth/refresh" {
                refreshCount += 1
                let payload = ["access_token": "new-token", "refresh_token": "new-refresh"]
                let data = try JSONSerialization.data(withJSONObject: payload, options: [])
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            throw URLError(.badURL)
        }

        let exp = expectation(description: "concurrent-sync")
        syncManager.syncPending { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, 3)
                // verify DB marked synced
                let ctx = self.persistence.container.viewContext
                let fetch: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
                let all = try! ctx.fetch(fetch)
                XCTAssertTrue(all.allSatisfy({ $0.synced }))
            case .failure(let err):
                XCTFail("Expected success but got \(err)")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
        XCTAssertEqual(refreshCount, 1, "Expected single refresh to be performed for concurrent 401s")
        XCTAssertGreaterThanOrEqual(moodUploadCount, 3, "Expected at least one upload per entry")
    }

    func testRefreshFailureNotifiesWaitersAndLeavesEntriesUnsynced() throws {
        // Seed 1 unsynced entry
        let ctx = persistence.container.viewContext
        let entry = MoodEntry(context: ctx)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.rating = 5
        entry.note = "fail-refresh"
        entry.synced = false
        try ctx.save()

        var moodUploadCount = 0
        var refreshCount = 0

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else { throw URLError(.badURL) }
            if url.path == "/api/moods" {
                moodUploadCount += 1
                let resp = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
                return (resp, nil)
            } else if url.path == "/api/auth/refresh" {
                refreshCount += 1
                // Simulate refresh failure
                let resp = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
                return (resp, nil)
            }
            throw URLError(.badURL)
        }

        let exp = expectation(description: "refresh-fail")
        syncManager.syncPending { result in
            switch result {
            case .success:
                XCTFail("Expected failure when refresh fails")
            case .failure:
                // expected
                let ctx = self.persistence.container.viewContext
                let fetch: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
                let all = try! ctx.fetch(fetch)
                XCTAssertTrue(all.first?.synced == false)
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
        XCTAssertEqual(refreshCount, 1, "Expected one refresh attempt")
        XCTAssertGreaterThanOrEqual(moodUploadCount, 1)
    }
}

// TokenProvider that performs an actual network refresh using given URLSession so MockURLProtocol can intercept
fileprivate class NetworkTestTokenProvider: TokenProvider {
    private(set) var accessToken: String?
    private(set) var refreshToken: String
    private let session: URLSession
    private let refreshURL: URL
    var refreshCalled = false

    init(accessToken: String?, refreshToken: String, session: URLSession, refreshURL: URL) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.session = session
        self.refreshURL = refreshURL
    }

    func getToken() -> String? {
        return accessToken
    }

    func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        refreshCalled = true
        var req = URLRequest(url: refreshURL)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["old_refresh_token": refreshToken]
        do {
            req.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        let task = session.dataTask(with: req) { data, response, error in
            if let err = error {
                completion(.failure(err))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            guard (200..<300).contains(http.statusCode), let data = data else {
                completion(.failure(URLError(.userAuthenticationRequired)))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let at = json["access_token"] as? String {
                    self.accessToken = at
                    if let rt = json["refresh_token"] as? String {
                        self.refreshToken = rt
                    }
                    completion(.success(at))
                    return
                }
                completion(.failure(URLError(.cannotParseResponse)))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
