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
