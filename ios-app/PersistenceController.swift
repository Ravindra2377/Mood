import Foundation
import CoreData

public struct PersistenceController {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MoodModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        // Allow automatic lightweight migration
        let desc = container.persistentStoreDescriptions.first
        desc?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        desc?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved CoreData error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
