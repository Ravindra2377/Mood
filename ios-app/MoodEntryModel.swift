import Foundation

public struct MoodEntryModel: Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let rating: Int
    public let note: String?
    public let synced: Bool

    public init(id: UUID, timestamp: Date, rating: Int, note: String?, synced: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.rating = rating
        self.note = note
        self.synced = synced
    }

    public init(from managed: MoodEntry) {
        self.id = managed.id
        self.timestamp = managed.timestamp
        self.rating = Int(managed.rating)
        self.note = managed.note
        self.synced = managed.synced
    }
}
