//
//  InfoViewContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

import SwiftUI

struct InfoViewContainer<MeasureContent: View, DisplayContent: View>: View {
    let itemCount: Int
    let shouldShowMeasureContent: Bool
    @ViewBuilder let measureContent: (InfoViewScope) -> MeasureContent
    @ViewBuilder let displayContent: (InfoViewScope) -> DisplayContent
    
    private let coordinateSpaceName = "InfoViewContainerCoordinateSpace"
    
    @State private var itemPositions: [Int: CGPoint] = [:]
    @State private var containerSize: CGSize = .zero
    @State private var itemSizes: [Int: CGSize] = [:]
    
    @State private var animatePositions = false
    @State private var showContents = false
    @State private var isMeasureContentVisible = false

    init(
        itemCount: Int,
        shouldShowMeasureContent: Bool = false,
        @ViewBuilder measureContent: @escaping (InfoViewScope) -> MeasureContent,
        @ViewBuilder displayContent: @escaping (InfoViewScope) -> DisplayContent
    ) {
        self.itemCount = itemCount
        self.shouldShowMeasureContent = shouldShowMeasureContent
        self.measureContent = measureContent
        self.displayContent = displayContent
    }

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
            
            if !shouldShowMeasureContent || !isMeasureContentVisible {
                displayContent(scope)
            }
            
            VStack(spacing: 20) {
                measureContent(scope)
            }
            .opacity(isMeasureContentVisible ? 1 : 0)
        }
//        .padding(.top, 6)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.short) { // after 0.3 seconds
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
//            withAnimation(.spring(response: AnimationConstants.Duration.medium)) {
                animatePositions = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.short + AnimationConstants.Duration.medium) { // after 1 seconds
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                showContents = true
            }
        }
        
        if shouldShowMeasureContent {
            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.short + AnimationConstants.Duration.medium + AnimationConstants.Duration.defaultDuration) { // after 1.5 seconds
                isMeasureContentVisible = true
                showContents = false
            }
        }
    }
}
