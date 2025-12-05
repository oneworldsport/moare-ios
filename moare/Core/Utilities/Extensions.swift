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
    
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Returns nil when String is Optional
extension StringProtocol {
    func toIntOrNil() -> Int? {
        Int(self)
    }
}

extension View {
    @ViewBuilder
    func optionalClickable(_ apply: Bool, onTap: @escaping () -> Void) -> some View {
        if apply {
            self
//                .contentShape(Rectangle()) // 빈 영역도 터치되게 (선택)
                .onTapGesture(perform: onTap)
                .accessibilityAddTraits(.isButton)
        } else {
            self
        }
    }
}
