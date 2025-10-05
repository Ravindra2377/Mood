import Foundation
import Security

/// Simple Keychain helper for storing/retrieving string tokens.
fileprivate enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
    case missingData
}

public class KeychainTokenProvider: TokenProvider {
    private let service: String
    private let accessGroup: String?
    private let session: URLSession
    private let refreshEndpoint: URL

    /// Keys stored in Keychain
    private let accessTokenKey = "com.mood.token.access"
    private let refreshTokenKey = "com.mood.token.refresh"

    public init(service: String = Bundle.main.bundleIdentifier ?? "com.mood",
                accessGroup: String? = nil,
                session: URLSession = .shared,
                refreshEndpoint: URL = URL(string: "https://api.example.com/auth/refresh")!) {
        self.service = service
        self.accessGroup = accessGroup
        self.session = session
        self.refreshEndpoint = refreshEndpoint
    }

    public func getToken() -> String? {
        return try? read(key: accessTokenKey)
    }

    public func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        // Read refresh token from Keychain
        guard let refreshToken = try? read(key: refreshTokenKey) else {
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }

        var req = URLRequest(url: refreshEndpoint)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["refresh_token": refreshToken]
        do {
            req.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        let task = session.dataTask(with: req) { data, response, error in
            if let err = error {
                completion(.failure(err))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            guard (200..<300).contains(http.statusCode), let data = data else {
                completion(.failure(APIError.unexpectedStatus(status: http.statusCode)))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let newToken = json?["access_token"] as? String {
                    try? self.save(key: self.accessTokenKey, value: newToken)
                    if let newRefresh = json?["refresh_token"] as? String {
                        try? self.save(key: self.refreshTokenKey, value: newRefresh)
                    }
                    completion(.success(newToken))
                } else {
                    completion(.failure(APIError.missingToken))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Keychain CRUD
    private func queryDict(for key: String) -> [String: Any] {
        var dict: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrService as String: service,
                                   kSecAttrAccount as String: key]
        if let group = accessGroup {
            dict[kSecAttrAccessGroup as String] = group
        }
        return dict
    }

    private func save(key: String, value: String) throws {
        let data = value.data(using: .utf8)!
        var dict = queryDict(for: key)

        // If exists, update
        let statusExists = SecItemCopyMatching(dict as CFDictionary, nil)
        if statusExists == errSecSuccess {
            let update: [String: Any] = [kSecValueData as String: data]
            let status = SecItemUpdate(dict as CFDictionary, update as CFDictionary)
            guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
            return
        }

        // Add
        dict[kSecValueData as String] = data
        let status = SecItemAdd(dict as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    private func read(key: String) throws -> String {
        var dict = queryDict(for: key)
        dict[kSecReturnData as String] = true
        dict[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(dict as CFDictionary, &item)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
        guard let data = item as? Data, let str = String(data: data, encoding: .utf8) else { throw KeychainError.missingData }
        return str
    }

    private func delete(key: String) throws {
        let dict = queryDict(for: key)
        let status = SecItemDelete(dict as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unexpectedStatus(status) }
    }

    public enum APIError: Error {
        case unexpectedStatus(status: Int)
        case missingToken
    }
}
