#if DEBUG
import SwiftUI

/// A small developer-only view to inspect and manipulate tokens in the Keychain.
/// This view is only compiled in DEBUG builds.
public struct TokenDebugView: View {
    @State private var access: String = ""
    @State private var refresh: String = ""
    @State private var message: String = ""

    private let provider = KeychainTokenProvider(service: Bundle.main.bundleIdentifier ?? "com.mood")

    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Text("Token Debug").font(.headline)
            HStack {
                Button("Show Access") {
                    access = provider.getToken() ?? "(none)"
                }
                Button("Show Refresh") {
                    // read via KeychainSeeder helper (production provider doesn't expose read refresh)
                    if let r = try? KeychainSeeder.readString(forKey: "com.mood.token.refresh", service: Bundle.main.bundleIdentifier ?? "com.mood") {
                        refresh = r
                    } else {
                        refresh = "(none)"
                    }
                }
            }
            HStack {
                Button("Set Demo Tokens") {
                    do {
                        try provider.setTokens(accessToken: "demo-access-\(Int.random(in: 1000...9999))", refreshToken: "demo-refresh-\(Int.random(in: 1000...9999))")
                        message = "Set demo tokens"
                    } catch {
                        message = "Set failed: \(error)"
                    }
                }
                Button("Clear Tokens") {
                    do {
                        try provider.clearTokens()
                        access = ""
                        refresh = ""
                        message = "Cleared"
                    } catch {
                        message = "Clear failed: \(error)"
                    }
                }
            }
            VStack(alignment: .leading) {
                Text("Access: \(access)")
                Text("Refresh: \(refresh)")
                Text("Status: \(message)")
            }.font(.caption)
            Spacer()
        }
        .padding()
    }
}

struct TokenDebugView_Previews: PreviewProvider {
    static var previews: some View {
        TokenDebugView()
    }
}
#endif
