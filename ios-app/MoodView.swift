import SwiftUI

public struct MoodView: View {
    @StateObject var vm: MoodViewModel

    public init(viewModel: MoodViewModel? = nil) {
        if let vm = viewModel {
            _vm = StateObject(wrappedValue: vm)
        } else {
            // Provide a default API client -- override in real app
            let client = APIClient(baseURL: URL(string: "https://api.example.com")!, tokenProvider: { return nil })
            _vm = StateObject(wrappedValue: MoodViewModel(api: client))
        }
    }

    var emoji: String {
        switch Int(vm.rating) {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "🙂"
        case 4: return "😃"
        default: return "🤩"
        }
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("How are you feeling?")
                .font(.title2)
                .bold()

            Text(emoji).font(.system(size: 64))

            Slider(value: $vm.rating, in: 1...5, step: 1)
                .padding(.horizontal)

            TextEditor(text: $vm.note)
                .frame(height: 120)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                .padding(.horizontal)

            HStack {
                Button(action: {
                    vm.manualSync { result in
                        // optional feedback handling
                    }
                }) {
                    Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                }
                .padding()

                Spacer()

                Button(action: {
                    vm.saveMood { _ in }
                }) {
                    Text(vm.isSaving ? "Saving..." : "Save")
                        .bold()
                        .padding()
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(vm.isSaving)
            }
            .padding(.horizontal)

            if vm.unsyncedCount > 0 {
                Text("Unsynced entries: \(vm.unsyncedCount)")
                    .font(.footnote)
                    .foregroundColor(.orange)
            }

            Spacer()
        }
        .padding(.top)
    }
}

#if DEBUG
struct MoodView_Previews: PreviewProvider {
    static var previews: some View {
        MoodView()
    }
}
#endif
