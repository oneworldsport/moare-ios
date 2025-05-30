//
//  InfoViewScope.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

import SwiftUI

struct InfoViewScope {
    let coordinateSpaceName: String
    let itemPositions: [Int: CGPoint]
    let containerSize: CGSize
    let itemSizes: [Int: CGSize]
    let animatePositions: Bool
    let showContents: Bool
    
    let updateItemSize: (Int, CGSize) -> Void
    let updateItemPosition: (Int, CGPoint) -> Void
    
    func updateItemFrame(
        index: Int,
        geometry: GeometryProxy
    ) {
        updateItemPosition(index, geometry.frame(in: .named(coordinateSpaceName)).origin)
        updateItemSize(index, geometry.size)
    }
    
    func computedOffset(for index: Int) -> CGSize {
        if animatePositions, let position = itemPositions[index] {
            return CGSize(width: position.x, height: position.y)
        } else if let size = itemSizes[index] {
            return CGSize(
                width: containerSize.width / 2 - size.width / 2,
                height: containerSize.height / 2
            )
        } else {
            return .zero
        }
    }
}
