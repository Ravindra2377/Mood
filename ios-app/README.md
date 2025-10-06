iOS Module Scaffold — SOUL (SwiftUI)

Overview

This folder contains a lightweight scaffold for a native iOS app module that implements an offline-first SOUL tracking screen and sync logic. The code is intentionally Xcode-friendly: copy these files into an Xcode SwiftUI project (recommended) or use them as a reference when creating your iOS app target.

What is included

- `PersistenceController.swift` — Core Data stack with lightweight migration enabled.
- `MoodEntry.swift` — NSManagedObject typed extension for the `MoodEntry` entity (create the model in Xcode).
- `APIClient.swift` — small URLSession + Combine based API client for uploading mood entries.
- `SyncManager.swift` — queries unsynced Core Data rows and uploads them, marking `synced = true` on success.
- `MoodViewModel.swift` — MVVM ViewModel (ObservableObject) exposing state and save/sync operations.
- `MoodView.swift` — SwiftUI view implementing the emoji slider, note field, save button and manual sync UI.

How to use

1. Create a new Xcode project (App) using SwiftUI and Swift. Set the minimum deployment target to iOS 13 or 14 depending on needs.
2. Copy the files from this folder into the new app target.
3. Create a Core Data model file named `MoodModel.xcdatamodeld` and add entity `MoodEntry` with attributes:
   - `id` (UUID, non-optional)
   - `timestamp` (Date, non-optional)
   - `rating` (Integer 16, non-optional)
   - `note` (String, optional)
   - `synced` (Boolean, non-optional, default `NO`)

4. Wire `PersistenceController.shared.container` into your app. Example in `@main` App:

```swift
@main
struct SOULApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            MoodView().environment(\._managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

5. Add Background Modes in your project Capabilities if you want BG processing or Background Fetch. If you plan to use BGTaskScheduler, add the identifier `com.yourapp.mood.sync` to Info.plist under `Permitted background task scheduler identifiers`.

6. Replace the `APIClient` base URL and token provider with your backend specifics.

Testing

- Unit test `SyncManager` with an in-memory Core Data stack and a mocked `APIClient`.
- UI-test `MoodView` using `XCTest` and the simulator.

Next steps I can take for you

- Create a complete Xcode project (requires binary .xcodeproj scaffolding) and include the Core Data model file.
- Add sample unit tests (in-memory Core Data + mock API) and a GitHub Actions macOS workflow.

Tell me which of those you'd like me to do next.
