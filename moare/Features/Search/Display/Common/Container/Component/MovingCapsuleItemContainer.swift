//
//  MovingCapsuleItemContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

import SwiftUI

struct MovingCapsuleItemContainer<Content: View>: View {
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let startOffset: CGSize
    let horizontalAlignment: HorizontalAlignment
    
    let updateItemPosition: ((GeometryProxy) -> Void)?
    let onClick: (() -> Void)?
    
    let content: () -> Content

    init(
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        startOffset: CGSize = .zero,
        horizontalAlignment: HorizontalAlignment = .center,
        updateItemPosition: ((GeometryProxy) -> Void)? = nil,
        onClick: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isAniItem = isAniItem
        self.itemSize = itemSize
        self.itemOffset = itemOffset
        self.startOffset = startOffset
        self.horizontalAlignment = horizontalAlignment
        self.updateItemPosition = updateItemPosition
        self.onClick = onClick
        self.content = content
    }

    var body: some View {
        Button(action: {
            onClick?()
        }) {
            VStack {
                HCapsuleBar()
                
                VStack(alignment: horizontalAlignment) {
                    content()
                }
            }
        }
        .foregroundStyle(.primary)
        .disabled(!(isAniItem && onClick != nil)) // Enable when onClick is not nil and item is ani item.
        .frame(maxWidth: itemSize?.width, maxHeight: itemSize?.height)
        .background(
            GeometryReader { geometry in
                if (!isAniItem && updateItemPosition != nil) {
                    Color.clear.onAppear {
                        updateItemPosition?(geometry)
                    }
                }
            }
        )
        .offset(
            isAniItem ? itemOffset ?? startOffset : .zero
        )
    }
}
