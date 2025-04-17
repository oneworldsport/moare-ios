//
//  AsyncPromise.swift
//  moare
//
//  Created by Mohwa Yoon on 4/15/25.
//

// NOTE: actor는 내부 메서드가 동기라도 호출 시 await를 붙여야함
actor AsyncPromise<T> {
    private var continuation: CheckedContinuation<T, Error>?
    private var valueSet = false
    private var storedValue: T?

    func fulfill(with value: T) {
        guard !valueSet else { return }
        valueSet = true
        storedValue = value
        continuation?.resume(returning: value)
    }

    var value: T {
        get async throws {
            if let value = storedValue {
                return value
            }
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
            }
        }
    }
}
