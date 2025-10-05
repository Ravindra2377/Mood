import Foundation
import Combine
import CoreData

public class MoodViewModel: ObservableObject {
    @Published public var rating: Double = 3
    @Published public var note: String = ""
    @Published public var isSaving: Bool = false
    @Published public var unsyncedCount: Int = 0

    private let context: NSManagedObjectContext
    private let api: APIClient
    private let syncManager: SyncManager
    private var cancellables = Set<AnyCancellable>()

    public init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext, api: APIClient) {
        self.context = context
        self.api = api
        self.syncManager = SyncManager(context: PersistenceController.shared.container.newBackgroundContext(), api: api)
        observeUnsyncedCount()
    }

    private func observeUnsyncedCount() {
        let req: NSFetchRequest<NSFetchRequestResult> = MoodEntry.fetchRequest()
        req.predicate = NSPredicate(format: "synced == NO")

        let controller = NSFetchedResultsController(fetchRequest: req as! NSFetchRequest<MoodEntry>, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
            updateUnsyncedCount(from: controller)
        } catch {
            print("Failed to fetch unsynced count: \(error)")
        }
    }

    private func updateUnsyncedCount(from controller: NSFetchedResultsController<MoodEntry>) {
        let count = controller.fetchedObjects?.count ?? 0
        DispatchQueue.main.async { self.unsyncedCount = count }
    }

    public func saveMood(completion: ((Result<Void, Error>) -> Void)? = nil) {
        isSaving = true
        context.perform {
            let entry = MoodEntry(context: self.context)
            entry.id = UUID()
            entry.timestamp = Date()
            entry.rating = Int16(self.rating)
            entry.note = self.note
            entry.synced = false
            do {
                try self.context.save()
                DispatchQueue.main.async {
                    self.isSaving = false
                    completion?(.success(()))
                }
                self.scheduleBackgroundSync()
            } catch {
                DispatchQueue.main.async {
                    self.isSaving = false
                    completion?(.failure(error))
                }
            }
        }
    }

    private func scheduleBackgroundSync() {
        // For simplicity we call syncManager directly; production should use BGTaskScheduler or URLSession background uploads.
        syncManager.syncPending { _ in }
    }

    public func manualSync(completion: ((Result<Int, Error>) -> Void)? = nil) {
        syncManager.syncPending(completion: completion)
    }
}

extension MoodViewModel: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let ctrl = controller as? NSFetchedResultsController<MoodEntry> else { return }
        updateUnsyncedCount(from: ctrl)
    }
}
