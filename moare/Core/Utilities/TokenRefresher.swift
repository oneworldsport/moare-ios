//
//  TokenRefresher.swift
//  moare
//
//  Created by Mohwa Yoon on 11/4/25.
//

import Foundation

actor TokenRefresher {
    static let shared = TokenRefresher()

    private var isRefreshing = false
    private var waiters: [CheckedContinuation<String, Error>] = []

    func refreshedAccessToken() async throws -> String {
        if !isRefreshing {
            isRefreshing = true
            
            do {
                let newToken = try await AWSManager.shared.refreshToken()
                waiters.forEach { $0.resume(returning: newToken) }
                waiters.removeAll()
                isRefreshing = false
                return newToken
            } catch {
                waiters.forEach { $0.resume(throwing: error) }
                waiters.removeAll()
                isRefreshing = false
                throw error
            }
        } else {
            return try await withCheckedThrowingContinuation { cont in
                waiters.append(cont)
            }
        }
    }
}
