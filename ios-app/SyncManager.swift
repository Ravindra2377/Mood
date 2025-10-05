import Foundation
import CoreData
import Combine

public class SyncManager {
    private let context: NSManagedObjectContext
    private let api: APIClient
    private var cancellables = Set<AnyCancellable>()

    public init(context: NSManagedObjectContext = PersistenceController.shared.container.newBackgroundContext(),
                api: APIClient) {
        self.context = context
        self.api = api
    }

    /// Sync unsynced mood entries. Calls completion with the number of successfully synced entries or an error.
    public func syncPending(completion: ((Result<Int, Error>) -> Void)? = nil) {
        context.perform {
            let req: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
            req.predicate = NSPredicate(format: "synced == NO")
            do {
                let pending = try self.context.fetch(req)
                guard !pending.isEmpty else {
                    DispatchQueue.main.async { completion?(.success(0)) }
                    return
                }

                let group = DispatchGroup()
                var successCount = 0
                var lastError: Error?

                for entry in pending {
                    group.enter()
                    let upload = APIClient.MoodUpload(
                        id: entry.id,
                        timestamp: entry.timestamp,
                        rating: Int(entry.rating),
                        note: entry.note
                    )

                    self.api.upload(mood: upload)
                        .sink(receiveCompletion: { completionResult in
                            switch completionResult {
                            case .finished:
                                entry.synced = true
                                successCount += 1
                            case .failure(let err):
                                lastError = err
                                // keep unsynced for retry
                            }
                            group.leave()
                        }, receiveValue: { })
                        .store(in: &self.cancellables)
                }

                group.notify(queue: .main) {
                    do {
                        try self.context.save()
                        if let err = lastError {
                            completion?(.failure(err))
                        } else {
                            completion?(.success(successCount))
                        }
                    } catch {
                        completion?(.failure(error))
                    }
                }
            } catch {
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }
}
