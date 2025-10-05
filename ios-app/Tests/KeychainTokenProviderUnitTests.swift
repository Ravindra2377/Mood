import XCTest
@testable import Mood

final class KeychainTokenProviderUnitTests: XCTestCase {
    let testService = "com.mood.tests"
    var session: URLSession!
    var provider: KeychainTokenProvider!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        provider = KeychainTokenProvider(service: testService, session: session, refreshEndpoint: URL(string: "https://api.example.com/auth/refresh")!, accessTokenKey: "test.access", refreshTokenKey: "test.refresh")

        // Clean
        try? provider.clearTokens()
    }

    override func tearDown() {
        try? provider.clearTokens()
        MockURLProtocol.requestHandler = nil
        session = nil
        provider = nil
        super.tearDown()
    }

    func testSetAndGetTokens() throws {
        try provider.setTokens(accessToken: "abc123", refreshToken: "ref123")
        let token = provider.getToken()
        XCTAssertEqual(token, "abc123")
    }

    func testClearTokens() throws {
        try provider.setTokens(accessToken: "abc", refreshToken: "ref")
        try provider.clearTokens()
        XCTAssertNil(provider.getToken())
    }

    func testRefreshParsesCustomKeys() throws {
        // Seed refresh token in keychain
        try KeychainSeeder.saveString("seed-refresh-token", forKey: "test.refresh", service: testService)

        MockURLProtocol.requestHandler = { request in
            let payload = ["access_token_custom": "new-access-777", "refresh_token_custom": "new-refresh-888"]
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let customProvider = KeychainTokenProvider(service: testService, session: session, refreshEndpoint: URL(string: "https://api.example.com/auth/refresh")!, accessTokenKey: "test.access", refreshTokenKey: "test.refresh", accessTokenJSONKey: "access_token_custom", refreshTokenJSONKey: "refresh_token_custom")

        let exp = expectation(description: "refresh-custom")
        customProvider.refreshToken { result in
            switch result {
            case .success(let tok):
                XCTAssertEqual(tok, "new-access-777")
                XCTAssertEqual(customProvider.getToken(), "new-access-777")
            case .failure(let err):
                XCTFail("Expected success but got \(err)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
}
