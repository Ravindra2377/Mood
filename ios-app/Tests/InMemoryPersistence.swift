import Foundation
import CoreData

/// Helper to create an in-memory Core Data stack with a programmatic `MoodEntry` model.
public struct InMemoryPersistence {
    public let container: NSPersistentContainer

    public init() {
        let model = InMemoryPersistence.makeModel()
        container = NSPersistentContainer(name: "MoodModel", managedObjectModel: model)
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]

        container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let moodEntity = NSEntityDescription()
        moodEntity.name = "MoodEntry"
        moodEntity.managedObjectClassName = "MoodEntry"

        // id: UUID
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        // timestamp: Date
        let tsAttr = NSAttributeDescription()
        tsAttr.name = "timestamp"
        tsAttr.attributeType = .dateAttributeType
        tsAttr.isOptional = false

        // rating: Int16
        let ratingAttr = NSAttributeDescription()
        ratingAttr.name = "rating"
        ratingAttr.attributeType = .integer16AttributeType
        ratingAttr.isOptional = false

        // note: String
        let noteAttr = NSAttributeDescription()
        noteAttr.name = "note"
        noteAttr.attributeType = .stringAttributeType
        noteAttr.isOptional = true

        // synced: Bool
        let syncedAttr = NSAttributeDescription()
        syncedAttr.name = "synced"
        syncedAttr.attributeType = .booleanAttributeType
        syncedAttr.isOptional = false
        syncedAttr.defaultValue = false

        moodEntity.properties = [idAttr, tsAttr, ratingAttr, noteAttr, syncedAttr]
        model.entities = [moodEntity]
        return model
    }
}
