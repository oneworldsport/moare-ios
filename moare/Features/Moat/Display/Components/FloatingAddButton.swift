//
//  FloatingAddButton.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI

struct FloatingAddButton: View {
    var body: some View {
        ZStack {
            Button(action: {}) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(.moare)
                    .shadow(color: .moare, radius: 3, x: 2, y: 1)
            }
        }
    }
}

#Preview {
    FloatingAddButton()
}
