import XCTest
import CoreData
import Combine
@testable import Mood

final class SyncManagerTests: XCTestCase {
    var persistence: InMemoryPersistence!
    var apiClient: APIClient!
    var syncManager: SyncManager!
    var session: URLSession!

    override func setUp() {
        super.setUp()
        persistence = InMemoryPersistence()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)

        apiClient = APIClient(baseURL: URL(string: "https://api.example.com")!, session: session, tokenProvider: { "token" })
        syncManager = SyncManager(context: persistence.container.newBackgroundContext(), api: apiClient)
    }

    override func tearDown() {
        persistence = nil
        apiClient = nil
        syncManager = nil
        session = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testSyncSuccessMarksEntriesSynced() throws {
        // Insert an unsynced entry
        let ctx = persistence.container.viewContext
        let entry = NSEntityDescription.insertNewObject(forEntityName: "MoodEntry", into: ctx) as! MoodEntry
        entry.id = UUID()
        entry.timestamp = Date()
        entry.rating = 4
        entry.note = "Great"
        entry.synced = false
        try ctx.save()

        // Mock successful response
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 201, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        let exp = expectation(description: "sync")
        syncManager.syncPending { result in
            switch result {
            case .success(let count):
                XCTAssertEqual(count, 1)
                // Verify persisted flag
                let fetch: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
                fetch.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
                let fetched = try! ctx.fetch(fetch)
                XCTAssertEqual(fetched.first?.synced, true)
            case .failure(let err):
                XCTFail("Expected success but got error: \(err)")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testSyncFailureLeavesEntriesUnsynced() throws {
        // Insert an unsynced entry
        let ctx = persistence.container.viewContext
        let entry = NSEntityDescription.insertNewObject(forEntityName: "MoodEntry", into: ctx) as! MoodEntry
        entry.id = UUID()
        entry.timestamp = Date()
        entry.rating = 2
        entry.note = "Tired"
        entry.synced = false
        try ctx.save()

        // Mock server error
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        let exp = expectation(description: "sync-fail")
        syncManager.syncPending { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to 500")
            case .failure:
                // ensure unsynced remains
                let fetch: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
                fetch.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
                let fetched = try! ctx.fetch(fetch)
                XCTAssertEqual(fetched.first?.synced, false)
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
