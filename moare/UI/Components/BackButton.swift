//
//  BackButton.swift
//  moare
//
//  Created by Mohwa Yoon on 9/10/25.
//

import SwiftUI

struct BackButton: View {
    var height: CGFloat = 30
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 22))
                .frame(width: 30, height: height)
                .padding(.leading, 10)
        }
        .foregroundStyle(.moare)
    }
}
