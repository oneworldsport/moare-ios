//
//  KeychainManager.swift
//  moare
//
//  Created by Mohwa Yoon on 12/7/25.
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    func set(_ value: String, for key: String) {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)

        let add: [String: Any] = query.merging([
            kSecValueData as String: data
        ]) { $1 }

        SecItemAdd(add as CFDictionary, nil)
    }

    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    func deleteAllTokens() {
        delete("accessToken")
        delete("refreshToken")
        delete("idToken")
    }
}
