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
    
    init(
        size: HCapsuleBarSize = .small,
        customWidth: CGFloat? = nil,
        color: Color = .moare
    ) {
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

// TODO: corner 별로 round 적용할 수 있게 해야함.
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
        if let customHeight {
            Capsule()
                .frame(width: customWidth, height: customHeight)
                .foregroundColor(color)
        } else {
            Capsule()
                .frame(width: customWidth)
                .frame(maxHeight: .infinity)
                .foregroundColor(color)
        }
    }
}

struct StatsDivider: View {
    
    var body: some View {
        VCapsuleBar(customHeight: 40, customWidth: 1)
            .opacity(0.5)
    }
}

struct HDivider: View {
    let height: CGFloat
    let color: Color
    
    init(height: CGFloat = 1, color: Color = .moare) {
        self.height = height
        self.color = color
    }
    
    var body: some View {
        Capsule()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .padding(.horizontal, 8)
            .foregroundColor(color)
    }
}

#Preview {
    StatsDivider()
//    HCapsuleBar()
}
