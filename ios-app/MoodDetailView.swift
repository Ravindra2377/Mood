import SwiftUI

public struct MoodDetailView: View {
    @State private var note: String
    @State private var rating: Int
    public var entry: MoodEntryModel
    public var onSave: (String?, Int) -> Void
    public var onDelete: () -> Void

    public init(entry: MoodEntryModel, onSave: @escaping (String?, Int) -> Void, onDelete: @escaping () -> Void) {
        self.entry = entry
        self._note = State(initialValue: entry.note ?? "")
        self._rating = State(initialValue: entry.rating)
        self.onSave = onSave
        self.onDelete = onDelete
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    Stepper(value: $rating, in: 1...5) {
                        Text("\(rating) — \(emoji(for: rating))")
                    }
                }
                Section(header: Text("Note")) {
                    TextEditor(text: $note).frame(height: 120)
                }
                Section {
                    Button(role: .destructive, action: onDelete) {
                        Text("Delete Entry")
                    }
                }
            }
            .navigationTitle("Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { onSave(note.isEmpty ? nil : note, rating) }
                }
            }
        }
    }

    private func emoji(for rating: Int) -> String {
        switch rating {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "🙂"
        case 4: return "😃"
        default: return "🤩"
        }
    }
}
