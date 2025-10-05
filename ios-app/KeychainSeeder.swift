import Foundation
import Security

/// Small helper to seed Keychain items for development and tests.
public struct KeychainSeeder {
    public static func saveString(_ value: String, forKey key: String, service: String, accessGroup: String? = nil) throws {
        let data = value.data(using: .utf8)!
        var dict: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrService as String: service,
                                   kSecAttrAccount as String: key]
        if let group = accessGroup {
            dict[kSecAttrAccessGroup as String] = group
        }

        // If exists, update
        let statusExists = SecItemCopyMatching(dict as CFDictionary, nil)
        if statusExists == errSecSuccess {
            let update: [String: Any] = [kSecValueData as String: data]
            let status = SecItemUpdate(dict as CFDictionary, update as CFDictionary)
            guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil) }
            return
        }

        // Add
        dict[kSecValueData as String] = data
        let status = SecItemAdd(dict as CFDictionary, nil)
        guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil) }
    }

    public static func delete(key: String, service: String, accessGroup: String? = nil) throws {
        var dict: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrService as String: service,
                                   kSecAttrAccount as String: key]
        if let group = accessGroup {
            dict[kSecAttrAccessGroup as String] = group
        }
        let status = SecItemDelete(dict as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil) }
    }

    public static func readString(forKey key: String, service: String, accessGroup: String? = nil) throws -> String {
        var dict: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrService as String: service,
                                   kSecAttrAccount as String: key,
                                   kSecReturnData as String: true,
                                   kSecMatchLimit as String: kSecMatchLimitOne]
        if let group = accessGroup {
            dict[kSecAttrAccessGroup as String] = group
        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(dict as CFDictionary, &item)
        guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil) }
        guard let data = item as? Data, let str = String(data: data, encoding: .utf8) else { throw NSError(domain: "Keychain", code: -1, userInfo: nil) }
        return str
    }
}
