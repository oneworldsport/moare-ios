//
//  FBStatDataItem.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/14/25.
//

import SwiftUI

struct FBStatDataItem: View {
    let category: String
    let data: String
    let customCategoryFontSize: CGFloat?
    let customDataFontSize: CGFloat?
    let customWidth: CGFloat?
    let customCategoryHeight: CGFloat?
    
    init(
        category: String,
        data: String,
        customCategoryFontSize: CGFloat? = nil,
        customDataFontSize: CGFloat? = nil,
        customWidth: CGFloat? = nil,
        customCategoryHeight: CGFloat? = nil
    ) {
        self.category = category
        self.data = data
        self.customCategoryFontSize = customCategoryFontSize
        self.customDataFontSize = customDataFontSize
        self.customWidth = customWidth
        self.customCategoryHeight = customCategoryHeight
    }
    
    var body: some View {
        VStack {
            Text(category)
                .font(.system(size: customCategoryFontSize ?? 15))
                .frame(height: customCategoryHeight ?? 25)
            
            Text(data)
                .font(.system(size: customDataFontSize ?? 16))
                .fontWeight(.medium)
                .frame(maxHeight: 30) // make it constant
        }
        .frame(width: customWidth ?? 50, height: 60)
    }
}

//#Preview {
//    FBStatDataItem()
//}
