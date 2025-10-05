import XCTest
@testable import Mood

final class KeychainTokenProviderTests: XCTestCase {
    let testService = "com.mood.tests"
    var session: URLSession!
    var provider: KeychainTokenProvider!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        provider = KeychainTokenProvider(service: testService, session: session, refreshEndpoint: URL(string: "https://api.example.com/auth/refresh")!)

        // Ensure clean state
        try? KeychainSeeder.delete(key: "com.mood.token.access", service: testService)
        try? KeychainSeeder.delete(key: "com.mood.token.refresh", service: testService)
    }

    override func tearDown() {
        try? KeychainSeeder.delete(key: "com.mood.token.access", service: testService)
        try? KeychainSeeder.delete(key: "com.mood.token.refresh", service: testService)
        MockURLProtocol.requestHandler = nil
        session = nil
        provider = nil
        super.tearDown()
    }

    func testRefreshTokenSuccessUpdatesAccessToken() throws {
        // Seed refresh token
        try KeychainSeeder.saveString("seed-refresh-token", forKey: "com.mood.token.refresh", service: testService)

        // Mock refresh response
        MockURLProtocol.requestHandler = { request in
            let payload = ["access_token": "new-access-123", "refresh_token": "new-refresh-456"]
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let exp = expectation(description: "refresh")
        provider.refreshToken { result in
            switch result {
            case .success(let tok):
                XCTAssertEqual(tok, "new-access-123")
                // getToken should now return new token
                let stored = self.provider.getToken()
                XCTAssertEqual(stored, "new-access-123")
            case .failure(let err):
                XCTFail("Expected success but got: \(err)")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testRefreshTokenMissingRefreshTokenFails() throws {
        // Ensure no refresh token present
        try? KeychainSeeder.delete(key: "com.mood.token.refresh", service: testService)

        let exp = expectation(description: "refresh-fail")
        provider.refreshToken { result in
            switch result {
            case .success:
                XCTFail("Expected failure when refresh token missing")
            case .failure:
                XCTAssertNil(self.provider.getToken())
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}
