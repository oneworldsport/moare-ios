//
//  StandingsCategory.swift
//  moare
//
//  Created by Mohwa Yoon on 6/9/25.
//

import SwiftUI

struct StandingsFirstCategoryItem: View {
    var text: String = StringConstants.standingsFirstCategory
    var width: CGFloat? = 132
    var height: CGFloat = 40
    
    var body: some View {
        HStack(spacing: 0) {
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
            
            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
        .frame(width: width ?? 132, height: height)
    }
}
