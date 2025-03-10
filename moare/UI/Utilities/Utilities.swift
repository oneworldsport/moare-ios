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
