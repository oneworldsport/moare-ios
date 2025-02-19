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
    func rounded(to decimalPlaces: Int) -> Double {
        let multiplier = pow(10.0, Double(decimalPlaces))
        return (self * multiplier).rounded() / multiplier
    }
}

extension Int {
    func percentage(of total: Int, to decimalPlaces: Int) -> Double {
        guard total != 0 else { return 0 }
        let percentage = (Double(self) / Double(total)) * 100
        let roundedPercentage = percentage.rounded(to: decimalPlaces)
        return roundedPercentage
    }
}
