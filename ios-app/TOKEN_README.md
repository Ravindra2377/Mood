Token management & local testing

This file explains how to seed test tokens in the Keychain for development and how the refresh flow works.

Key files
- `KeychainTokenProvider.swift` — production TokenProvider using Keychain and refresh endpoint.
- `KeychainSeeder.swift` — small helper to write/read/delete string values in Keychain for tests and dev use.

Seeding test tokens (local development)
- Run a small Swift script or integrate a debug-only helper that calls `KeychainSeeder.saveString("<access>", forKey: "com.mood.token.access", service: "com.mood")` and similarly for the refresh token.

Example (Swift snippet to run in Playground or debug UI):

```swift
try KeychainSeeder.saveString("fake-access-token", forKey: "com.mood.token.access", service: "com.mood.tests")
try KeychainSeeder.saveString("fake-refresh-token", forKey: "com.mood.token.refresh", service: "com.mood.tests")
```

Testing the refresh flow
1. Seed only the refresh token and ensure `KeychainTokenProvider(service: "com.mood.tests", refreshEndpoint: URL(string: "https://api.example.com/auth/refresh")!)` is configured to use the same service string.
2. Mock the refresh endpoint in tests using `MockURLProtocol` (a test helper included in `ios-app/Tests`).
3. Call `refreshToken` and assert `getToken()` returns the new access token after refresh.

Notes
- The Keychain implementation uses the app bundle identifier by default as the `service` value. When running tests, use a separate service string (e.g. `com.mood.tests`) to avoid collisions.
- For real apps, store tokens securely and consider Keychain access groups if sharing with extensions.
- Ensure you replace the placeholder refresh endpoint and JSON parsing to match your backend responses.
