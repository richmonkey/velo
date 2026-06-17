import Foundation
import Security

final class KeychainService {
    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.velo.chat") {
        self.service = service
    }

    func saveData(_ data: Data, forKey key: String) throws {
        var query = baseQuery(forKey: key)
        SecItemDelete(query as CFDictionary)

        query[kSecValueData as String] = data
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status)
        }
    }

    func loadData(forKey key: String) -> Data? {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    private func baseQuery(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
    }
}

enum KeychainError: Error {
    case unhandled(OSStatus)
}
