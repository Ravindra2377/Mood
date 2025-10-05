import XCTest
import CoreData
@testable import Mood

final class MoodHistoryViewModelTests: XCTestCase {
    var persistence: InMemoryPersistence!
    var vm: MoodHistoryViewModel!
    var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistence = InMemoryPersistence()
        ctx = persistence.container.viewContext
        vm = MoodHistoryViewModel(context: ctx, pageSize: 10)

        // seed 25 entries
        for i in 0..<25 {
            let entry = MoodEntry(context: ctx)
            entry.id = UUID()
            entry.timestamp = Date().addingTimeInterval(TimeInterval(-i * 60))
            entry.rating = Int16((i % 5) + 1)
            entry.note = "Note \(i)"
            entry.synced = (i % 3 == 0)
        }
        try! ctx.save()
    }

    override func tearDown() {
        persistence = nil
        vm = nil
        ctx = nil
        super.tearDown()
    }

    func testLoadFirstPageReturnsPageSize() throws {
        let exp = expectation(description: "load first")
        vm.loadFirstPage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.vm.entries.count, 10)
            // first entry should have the most recent timestamp
            XCTAssertTrue(self.vm.entries.first!.timestamp >= self.vm.entries.last!.timestamp)
            exp.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testLoadNextPageAppendsEntries() throws {
        let exp = expectation(description: "load pages")
        vm.loadFirstPage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.vm.loadNextPage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertEqual(self.vm.entries.count, 20)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 3)
    }

    func testDeleteRemovesEntry() throws {
        let exp = expectation(description: "delete")
        vm.loadFirstPage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let toDelete = self.vm.entries.first!
            self.vm.delete(id: toDelete.id) { result in
                switch result {
                case .success:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        XCTAssertFalse(self.vm.entries.contains(where: { $0.id == toDelete.id }))
                        exp.fulfill()
                    }
                case .failure(let err):
                    XCTFail("Delete failed: \(err)")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 4)
    }
}
