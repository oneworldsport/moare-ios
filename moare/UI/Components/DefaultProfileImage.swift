//
//  DefaultProfileImage.swift
//  moare
//
//  Created by Mohwa Yoon on 11/13/25.
//

import SwiftUI

enum DefaultProfileImageSize {
    case small, medium, big
}

struct DefaultProfileImage: View {
    private let imageSize: CGFloat
    
    init(size: DefaultProfileImageSize = .big, customSize: CGFloat? = nil) {
        if let customSize {
            self.imageSize = customSize
        } else {
            self.imageSize = switch size {
            case .small: 30
            case .medium: 50
            case .big: 80
            }
        }
    }
    
    var body: some View {
        Image(systemName: "person")
            .font(.system(size: imageSize))
            .foregroundStyle(.secondary)
            .offset(x: 0, y: 13)
        .background(
            Circle()
                .strokeBorder(.secondary, lineWidth: 2)
        )
        .mask {
            Circle()
        }
    }
}

