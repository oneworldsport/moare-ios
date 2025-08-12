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
    let customWidth: CGFloat
    let color: Color
    
    init(
        customHeight: CGFloat? = nil,
        customWidth: CGFloat? = nil,
        color: Color = .secondary
    ) {
        self.customHeight = customHeight
        self.customWidth = customWidth ?? 2
        self.color = color
    }
    
    var body: some View {
        Capsule()
            .frame(width: customWidth)
            .frame(maxHeight: customHeight ?? .infinity)
            .foregroundColor(color)
    }
}

struct StatsDivder: View {
    
    var body: some View {
        VCapsuleBar(customHeight: 40, customWidth: 1)
            .opacity(0.5)
    }
}

#Preview {
    StatsDivder()
//    HCapsuleBar()
}
