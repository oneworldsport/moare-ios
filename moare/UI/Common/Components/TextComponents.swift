//
//  TextComponents.swift
//  moare
//
//  Created by Mohwa Yoon on 3/10/25.
//

import Foundation
import SwiftUI

struct RoundedBorderText: View {
    private let text: String
    private let fontSize: CGFloat
    private let textColor: Color
    private let radius: CGFloat
    private let strokeWidth: CGFloat
    private let strokeColor: Color
    
    init(text: String,
         fontSize: CGFloat = 17,
         textColor: Color = .primary,
         radius: CGFloat = 2,
         strokeWidth: CGFloat = 1,
         strokeColor: Color = .primary
    ) {
        self.text = text
        self.fontSize = fontSize
        self.textColor = textColor
        self.radius = radius
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .foregroundStyle(textColor)
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            }
    }
}
