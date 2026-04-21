//
//  Utilities.swift
//  moare
//
//  Created by Mohwa Yoon on 3/10/25.
//

import Foundation

func getOffsetOfAniCapsuleBar(
    itemWidth: CGFloat,
    barWidth: CGFloat = 20,
    spacing: CGFloat = 0,
    index: Int = 0
) -> CGFloat {
    return (itemWidth * CGFloat(index)) + ((itemWidth - barWidth) / 2) + (spacing * CGFloat(index))
}

/// Calculates the offset position of the capsule bar for a given index,
/// taking into account varying item widths.
///
/// - Parameters:
///   - itemWidths: An array of widths for each item.
///   - barWidth: The width of the capsule bar (default is 20).
///   - index: The index of the item for which to calculate the offset.
///
/// - Returns: The `CGFloat` offset from the start.
///
/// ### Example (barWidth = 20):
/// - Index 0: (itemWidths[0] - 20) / 2
/// - Index 1: itemWidths[0] + (itemWidths[1] - 20) / 2
/// - Index 2: itemWidths[0] + itemWidths[1] + (itemWidths[2] - 20) / 2
/// - Index 3: itemWidths[0] + itemWidths[1] + itemWidths[2] + (itemWidths[3] - 20) / 2
/// --- by GPT
func getOffsetOfAniCapsuleBar(
    itemWidths: [CGFloat],
    barWidth: CGFloat = 20,
    index: Int = 0
) -> CGFloat {
    // 이전 아이템들의 너비 합
    let totalPreviousWidth = itemWidths.prefix(max(0, index)).reduce(0, +) // index에 음수값 안들어가져서 수정
    
    // 현재 아이템의 가운데에 bar 정렬
    let centerOffset = ((itemWidths[safe: index] ?? 0) - barWidth) / 2
    
    return totalPreviousWidth + centerOffset
}

//func getOffsetOfAniCapsuleBar(
//    itemWidths: [CGFloat],
//    barWidth: CGFloat = 20,
//    spacing: CGFloat = 0,
//    index: Int
//) -> CGFloat {
//    let totalPreviousWidth = itemWidths.prefix(index).reduce(0, +)
//    let totalSpacing = spacing * CGFloat(index)
//    let centerOffset = ((itemWidths[safe: index] ?? 0) - barWidth) / 2
//    return totalPreviousWidth + totalSpacing + centerOffset
//}
