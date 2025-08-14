//
//  MovingCapsuleItemContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

import SwiftUI

struct MovingCapsuleItemContainer<Content: View>: View {
    let isButton: Bool // NOTE: content()안에 버튼이 있는데, 외부 버튼 기능은 필요 없고 content() 내부 버튼 기능만 필요할때 일반 뷰를 사용하기 위해 추가.
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let startOffset: CGSize
    let horizontalAlignment: HorizontalAlignment
    
    let updateItemPosition: ((GeometryProxy) -> Void)?
    let onClick: (() -> Void)?
    
    let content: () -> Content

    init(
        isButton: Bool = true,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        startOffset: CGSize = .zero,
        horizontalAlignment: HorizontalAlignment = .center,
        updateItemPosition: ((GeometryProxy) -> Void)? = nil,
        onClick: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isButton = isButton
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
        if isButton {
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
        } else {
            VStack {
                HCapsuleBar()
                
                VStack(alignment: horizontalAlignment) {
                    content()
                }
            }
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
}
