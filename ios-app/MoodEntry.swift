import Foundation
import CoreData

@objc(MoodEntry)
public class MoodEntry: NSManagedObject {}

extension MoodEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodEntry> {
        return NSFetchRequest<MoodEntry>(entityName: "MoodEntry")
    }

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var rating: Int16
    @NSManaged public var note: String?
    @NSManaged public var synced: Bool
}
