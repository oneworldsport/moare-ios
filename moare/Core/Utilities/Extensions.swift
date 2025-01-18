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
