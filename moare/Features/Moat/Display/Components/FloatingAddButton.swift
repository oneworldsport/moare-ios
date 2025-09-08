//
//  FloatingAddButton.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI

struct FloatingAddButton: View {
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Button(action: action) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.moare)
                    .shadow(color: .moare, radius: 2, x: 1, y: 1)
            }
        }
    }
}

#Preview {
    FloatingAddButton(action: {})
}
