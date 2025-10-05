import SwiftUI
import BackgroundTasks

@main
struct MoodApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            // Create a shared MoodViewModel for the app so badge and mood view stay in sync
            let tokenProvider = KeychainTokenProvider()
            let api = APIClient(baseURL: URL(string: "https://api.example.com")!, tokenProvider: tokenProvider)
            let sharedVM = MoodViewModel(api: api)
            MainTabView(viewModel: sharedVM)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    func registerBackgroundTasks() {
        // Register BG processing task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.mood.sync", using: nil) { task in
            // Ensure we handle expiration and perform work on a background context
            if let bgTask = task as? BGProcessingTask {
                handleSyncTask(task: bgTask)
            } else {
                task.setTaskCompleted(success: false)
            }
        }
    }

    func handleSyncTask(task: BGProcessingTask) {
        scheduleNextSync() // schedule the next one early

        let bgContext = PersistenceController.shared.container.newBackgroundContext()
    let tokenProvider = KeychainTokenProvider()
    let api = APIClient(baseURL: URL(string: "https://api.example.com")!, tokenProvider: tokenProvider)
        let syncManager = SyncManager(context: bgContext, api: api)

        let workQueue = OperationQueue()
        workQueue.maxConcurrentOperationCount = 1

        let op = BlockOperation {
            let sem = DispatchSemaphore(value: 0)
            syncManager.syncPending { _ in sem.signal() }
            _ = sem.wait(timeout: .now() + 25)
        }

        task.expirationHandler = {
            // Cancel operation if it hasn't completed
            workQueue.cancelAllOperations()
        }

        workQueue.addOperation(op)
        op.completionBlock = {
            task.setTaskCompleted(success: !op.isCancelled)
        }
    }

    func scheduleNextSync() {
        let request = BGProcessingTaskRequest(identifier: "com.mood.sync")
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60*15)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to submit BGProcessingTaskRequest: \(error)")
        }
    }
}

// Simple default token provider placeholder. Replace with secure storage + refresh logic.
public class DefaultTokenProvider: TokenProvider {
    public init() {}
    public func getToken() -> String? {
        // Read from Keychain/secure store in production
        return nil
    }
    public func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        // Trigger refresh flow (network call). For now, return failure.
        completion(.failure(URLError(.userAuthenticationRequired)))
    }
}
