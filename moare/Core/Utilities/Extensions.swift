//
//  Extensions.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 9/5/24.
//

import SwiftUI

extension Binding where Value == Bool {
    var not: Binding<Bool> {
        Binding<Bool>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}

extension Double {
    // 반올림해서 decimalPlaces자리까지 표시
    func rounded(to decimalPlaces: Int) -> Double {
        let multiplier = pow(10.0, Double(decimalPlaces))
        return (self * multiplier).rounded() / multiplier
    }
    
    func toKg(decimalPlaces: Int = 0) -> Double {
        return (self * 0.453592).rounded(to: decimalPlaces)
    }
}

extension Int {
    func percentage(of total: Int, to decimalPlaces: Int) -> Double {
        guard total != 0 else { return 0 }
        let percentage = (Double(self) / Double(total)) * 100
        let roundedPercentage = percentage.rounded(to: decimalPlaces)
        return roundedPercentage
    }
    
    func toKg(decimalPlaces: Int = 0) -> Double {
        return (Double(self) * 0.453592).rounded(to: decimalPlaces)
    }
}

extension Optional where Wrapped == Int {
    var displayOrDash: String {
        self.map{ "\($0)" } ?? "-"
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// 배열을 지정된 크기(size)만큼 잘라서 2차원 배열로 반환.
    func chunked(by size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension String {
    /// Use when only (possible)last name need
    var dropFirstWord: String {
        let components = self.split(separator: " ")
        return components.count > 1 ? components.dropFirst().joined(separator: " ") : self
    }
}

/// Returns nil when String is Optional
extension StringProtocol {
    func toIntOrNil() -> Int? {
        Int(self)
    }
}

// 코드가 참 어렵구만...
extension Array where Element: Rankable {
    /// 이미 정렬된 상태라고 가정하고, key 값으로 공동순위 부여 (1,2,2,4 방식)
    mutating func assignCompetitionRank<Key: Equatable>(by key: (Element) -> Key) {
        guard !isEmpty else { return }

        var currentRank = 1
        var sameCount = 0
        var lastKey: Key? = nil

        for i in indices {
            let k = key(self[i])

            if lastKey == nil || k != lastKey! {
                // 값이 바뀌면: rank를 "이전 공동순위 개수만큼" 점프
                currentRank += sameCount
                sameCount = 1
                lastKey = k
            } else {
                // 값이 같으면: 같은 rank 유지
                sameCount += 1
            }

            self[i].displayRank = currentRank
        }
    }
}
