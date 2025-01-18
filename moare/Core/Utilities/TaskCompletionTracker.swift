//
//  TaskCompletionTracker.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/3/25.
//

import Foundation

actor TaskCompletionTracker {
    private(set) var isCompleted = false
    
    func markCompleted() {
        isCompleted = true
    }
    
    func getStatus() -> Bool {
        return isCompleted
    }
}
