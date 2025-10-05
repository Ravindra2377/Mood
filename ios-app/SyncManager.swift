import Foundation
import CoreData
import Combine

/// SyncManager uploads unsynced MoodEntry objects, marking them synced on success.
/// Improvements: retries with exponential backoff and token refresh support.
public class SyncManager {
    private let context: NSManagedObjectContext
    private let api: APIClient
    private var cancellables = Set<AnyCancellable>()

    /// Max attempts per entry (including initial try)
    private let maxAttempts = 3

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
                var overallError: Error?

                for entry in pending {
                    group.enter()
                    self.uploadWithRetries(entry: entry) { result in
                        switch result {
                        case .success:
                            successCount += 1
                        case .failure(let err):
                            overallError = err
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    do {
                        try self.context.save()
                        if let err = overallError {
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

    private func uploadWithRetries(entry: MoodEntry, attempt: Int = 1, completion: @escaping (Result<Void, Error>) -> Void) {
        let upload = APIClient.MoodUpload(
            id: entry.id,
            timestamp: entry.timestamp,
            rating: Int(entry.rating),
            note: entry.note
        )

        let cancellable = self.api.upload(mood: upload)
            .sink(receiveCompletion: { completionResult in
                switch completionResult {
                case .finished:
                    entry.synced = true
                    completion(.success(()))
                case .failure(let err):
                    // If 401, try token refresh once and retry
                    if let apiErr = err as? APIClient.APIError, case .clientError(let status) = apiErr, status == 401 {
                        self.api.tokenProvider.refreshToken { refreshResult in
                            switch refreshResult {
                            case .success:
                                if attempt < self.maxAttempts {
                                    // Retry immediately after refresh
                                    self.uploadWithRetries(entry: entry, attempt: attempt + 1, completion: completion)
                                } else {
                                    completion(.failure(err))
                                }
                            case .failure:
                                completion(.failure(err))
                            }
                        }
                    } else if attempt < self.maxAttempts {
                        // Retry with exponential backoff for transient errors
                        let delay = pow(2.0, Double(attempt))
                        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                            self.uploadWithRetries(entry: entry, attempt: attempt + 1, completion: completion)
                        }
                    } else {
                        completion(.failure(err))
                    }
                }
            }, receiveValue: { })

        self.cancellables.insert(cancellable)
    }
}
