//
//  UserHandleValidator.swift
//  moare
//
//  Created by Mohwa Yoon on 12/5/25.
//

import Foundation

enum UserHandleValidationError: Error, Equatable {
    case empty
    case tooShort(min: Int)
    case tooLong(max: Int)
    case invalidCharacters
    case startsWithUnderscore
    case endsWithUnderscore
    case containsDoubleUnderscore
}

struct UserHandleValidator {
    static let minLength = 3
    static let maxLength = 20
    
    static func validate(_ handle: String) -> UserHandleValidationError? {
        // 0) empty check
        if handle.isBlank { return .empty }
        
        // 1) length check
        let count = handle.count
        if count < minLength { return .tooShort(min: minLength) }
        if count > maxLength { return .tooLong(max: maxLength) }
        
        // 2) allowed characters check: lowercase a-z, digits 0-9, underscore _
        let allowedRegex = "^[a-z0-9_]+$"
        if handle.range(of: allowedRegex, options: .regularExpression) == nil {
            return .invalidCharacters
        }
        
        // 3) starts/ends with underscore check
        if handle.hasPrefix("_") { return .startsWithUnderscore }
        if handle.hasSuffix("_") { return .endsWithUnderscore }
        
        // 4) no double underscore
        if handle.contains("__") { return .containsDoubleUnderscore }
        
        return nil
    }
    
    static func isValid(_ handle: String) -> Bool {
        return validate(handle) == nil
    }
}
