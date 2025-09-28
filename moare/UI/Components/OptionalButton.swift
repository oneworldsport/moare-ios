//
//  OptionalButton.swift
//  moare
//
//  Created by Mohwa Yoon on 9/27/25.
//

import SwiftUI

struct OptionalButton<Label: View>: View {
    var action: (() -> Void)? = nil
    let label: () -> Label
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            label()
        }
        .foregroundStyle(.primary)
        .disabled(action == nil)
    }
}
