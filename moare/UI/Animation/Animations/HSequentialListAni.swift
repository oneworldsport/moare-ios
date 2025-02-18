//
//  HSequentialListAni.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/12/24.
//

import SwiftUI

struct HSequentialListItem: ViewModifier {
    let index: Int
    let itemHeight: CGFloat
    let itemWidth: CGFloat
    let aniDelay: Double
    let aniDuration: Double
    
    @State private var offset: CGSize
    
    init(index: Int, itemHeight: CGFloat, itemWidth: CGFloat, aniDelay: Double, aniDuration: Double) {
        self.index = index
        self.itemHeight = itemHeight
        self.itemWidth = itemWidth
        self.aniDelay = Double(index) * aniDelay
        self.aniDuration = aniDuration
        _offset = State(initialValue: CGSize(width: -itemWidth, height: 0))
    }
    
    func body(content: Content) -> some View {
        HStack {
            if offset.width == 0 {
                content
                    .offset(offset)
            }
        }
        .frame(height: itemHeight)
        .onAppear {
            animateItem()
        }
    }
    
    private func animateItem() {
        withAnimation(.easeInOut(duration: aniDuration).delay(aniDelay)) {
            offset = CGSize(width: 0, height: 0)
        }
    }
}

extension View {
    public func hSequentialListAni(
        index: Int,
//        itemCount: Int,
        itemHeight: CGFloat,
        itemWidth: CGFloat,
        aniDelay: Double,
        aniDuration: Double
    ) -> some View {
        self.modifier(
            HSequentialListItem(
                index: index,
                itemHeight: itemHeight,
                itemWidth: itemWidth,
                aniDelay: aniDelay,
                aniDuration: aniDuration
            )
        )
    }
}
