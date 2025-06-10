//
//  StandingsCategory.swift
//  moare
//
//  Created by Mohwa Yoon on 6/9/25.
//

import SwiftUI

struct StandingsFirstCategoryItem: View {
    
    var body: some View {
        HStack(spacing: 0) {
            Text(StringConstants.standingsFirstCategory)
                .font(.system(size: 15, weight: .medium))
                .frame(minWidth: 130)
            
            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
    }
}
