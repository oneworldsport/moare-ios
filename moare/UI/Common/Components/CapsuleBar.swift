//
//  CapsuleBar.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/14/24.
//

import SwiftUI

enum HCapsuleBarSize {
    case small, medium, large
}

struct HCapsuleBar: View {
    let size: HCapsuleBarSize
    let customWidth: CGFloat?
    let color: Color
    
    init(size: HCapsuleBarSize = .small, customWidth: CGFloat? = nil, color: Color = .moare) {
        self.size = size
        self.customWidth = customWidth
        self.color = color
    }
    
    var barSize: CGFloat {
        customWidth ?? {
            switch size {
            case .small: 20
            case .medium: 50
            case .large: 80
            }
        }()
    }
    
    var body: some View {
        Capsule()
            .frame(width: barSize, height: 2)
            .foregroundColor(color)
    }
}

struct VCapsuleBar: View {
    let customHeight: CGFloat?
    let color: Color
    
    init(customHeight: CGFloat? = nil, color: Color = .secondary) {
        self.customHeight = customHeight
        self.color = color
    }
    
    var body: some View {
        Capsule()
            .frame(maxWidth: 2, maxHeight: customHeight ?? .infinity)
            .foregroundColor(color)
    }
}

//#Preview {
//    HCapsuleBar()
//}
