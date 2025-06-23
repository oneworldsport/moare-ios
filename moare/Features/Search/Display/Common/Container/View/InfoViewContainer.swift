//
//  InfoViewContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

import SwiftUI

struct InfoViewContainer<MeasureContent: View, DisplayContent: View>: View {
    let itemCount: Int
    @ViewBuilder let measureContent: (InfoViewScope) -> MeasureContent
    @ViewBuilder let displayContent: (InfoViewScope) -> DisplayContent
    
    private let coordinateSpaceName = "InfoViewContainerCoordinateSpace"
    
    @State private var itemPositions: [Int: CGPoint] = [:]
    @State private var containerSize: CGSize = .zero
    @State private var itemSizes: [Int: CGSize] = [:]
    
    @State private var animatePositions = false
    @State private var showContents = false

//    init(
//        itemCount: Int,
//        @ViewBuilder measureContent: @escaping () -> MeasureContent,
//        @ViewBuilder displayContent: @escaping () -> DisplayContent
//    ) {
//        self.itemCount = itemCount
//        self.measureContent = measureContent
//        self.displayContent = displayContent
//    }

    var body: some View {
        let scope = InfoViewScope(
            coordinateSpaceName: coordinateSpaceName,
            itemPositions: itemPositions,
            containerSize: containerSize,
            itemSizes: itemSizes,
            animatePositions: animatePositions,
            showContents: showContents,
            updateItemSize: { index, size in
                itemSizes[index] = size
            },
            updateItemPosition: { index, offset in
                itemPositions[index] = offset
            }
        )
        
        ZStack(alignment: .topLeading) {
            Spacer() // empty space for smooth animation effect
                .frame(maxWidth: .infinity, maxHeight: 0)
            
            VStack(spacing: 20) {
                measureContent(scope)
            }
            .opacity(0)
            
            displayContent(scope)
        }
        .padding(.top, 6)
        .coordinateSpace(name: coordinateSpaceName)
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    DispatchQueue.main.async {
                        containerSize = proxy.size
                    }
                }
            }
        )
        .onAppear {
            triggerAnimation()
        }
    }
    
    private func triggerAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.short) {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
//            withAnimation(.spring(response: AnimationConstants.Duration.medium)) {
                animatePositions = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.short + AnimationConstants.Duration.medium) {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                showContents = true
            }
        }
    }
}
