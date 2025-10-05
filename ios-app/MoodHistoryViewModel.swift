import Foundation
import CoreData
import Combine

public class MoodHistoryViewModel: ObservableObject {
    @Published public private(set) var entries: [MoodEntryModel] = []
    @Published public var isLoading: Bool = false

    private let context: NSManagedObjectContext
    private let pageSize: Int
    private var currentPage: Int = 0

    public init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext, pageSize: Int = 20) {
        self.context = context
        self.pageSize = pageSize
    }

    public func loadFirstPage() {
        currentPage = 0
        entries = []
        loadPage(page: 0)
    }

    public func loadNextPage() {
        loadPage(page: currentPage + 1)
    }

    private func loadPage(page: Int) {
        isLoading = true
        context.perform {
            let req: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            let sort = NSSortDescriptor(key: "timestamp", ascending: false)
            req.sortDescriptors = [sort]
            req.fetchLimit = self.pageSize
            req.fetchOffset = page * self.pageSize

            do {
                let results = try self.context.fetch(req)
                let models = results.map { MoodEntryModel(from: $0) }
                DispatchQueue.main.async {
                    if page == 0 {
                        self.entries = models
                    } else {
                        self.entries.append(contentsOf: models)
                    }
                    self.currentPage = page
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    public func refresh() {
        loadFirstPage()
    }

    public func delete(id: UUID, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let bg = PersistenceController.shared.container.newBackgroundContext()
        bg.perform {
            let req: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            req.fetchLimit = 1
            do {
                if let obj = try bg.fetch(req).first {
                    bg.delete(obj)
                    try bg.save()
                }
                DispatchQueue.main.async {
                    self.refresh()
                    completion?(.success(()))
                }
            } catch {
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }

    public func update(id: UUID, newNote: String?, newRating: Int, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let bg = PersistenceController.shared.container.newBackgroundContext()
        bg.perform {
            let req: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            req.fetchLimit = 1
            do {
                if let obj = try bg.fetch(req).first {
                    obj.note = newNote
                    obj.rating = Int16(newRating)
                    try bg.save()
                }
                DispatchQueue.main.async {
                    self.refresh()
                    completion?(.success(()))
                }
            } catch {
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }
}
