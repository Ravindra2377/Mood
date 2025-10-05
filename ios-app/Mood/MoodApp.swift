import SwiftUI

@main
struct MoodApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            MoodView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    func registerBackgroundTasks() {
        // Register BG processing task
        #if canImport(BackgroundTasks)
        import BackgroundTasks
        #endif
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.mood.sync", using: nil) { task in
            handleSyncTask(task: task as! BGProcessingTask)
        }
    }

    func handleSyncTask(task: BGProcessingTask) {
        scheduleNextSync()
        let syncManager = SyncManager(api: APIClient(baseURL: URL(string: "https://api.example.com")!, tokenProvider: { nil }))
        let sem = DispatchSemaphore(value: 0)
        syncManager.syncPending { _ in sem.signal() }

        task.expirationHandler = {
            // Cancel if needed
        }

        DispatchQueue.global().async {
            _ = sem.wait(timeout: .now() + 25)
            task.setTaskCompleted(success: true)
        }
    }

    func scheduleNextSync() {
        let request = BGProcessingTaskRequest(identifier: "com.mood.sync")
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60*15)
        try? BGTaskScheduler.shared.submit(request)
    }
}
