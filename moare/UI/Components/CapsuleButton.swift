//
//  CapsuleButton.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/7/25.
//

import SwiftUI

struct CapsuleButton: View {
    let text: String
    let color: Color
    let onClick: () -> Void
    
    init(text: String, color: Color = .moare, onClick: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.onClick = onClick
    }
    
    var body: some View {
        Button(action: {
            onClick()
        }) {
            Text(text)
                .font(.system(size: 12))
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 1)
                }
        }
        .foregroundStyle(color)
    }
}

#Preview {
    CapsuleButton(text: "test", onClick: {})
}
