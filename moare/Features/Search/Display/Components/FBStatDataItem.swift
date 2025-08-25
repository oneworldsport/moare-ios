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
        // customWidth가 있을때는 customWidth로 너비 고정. 없을때는 maxWidth: 50으로 너비 자동 조정.
        if let customWidth {
            VStack(spacing: 0) {
                Text(category)
                    .font(.system(size: customCategoryFontSize ?? 15))
                    .frame(height: customCategoryHeight ?? 30)
                
                Text(data)
                    .font(.system(size: customDataFontSize ?? 16))
                    .fontWeight(.medium)
                    .frame(height: 30)
            }
            .frame(width: customWidth)
        } else {
            VStack(spacing: 0) {
                Text(category)
                    .font(.system(size: customCategoryFontSize ?? 15))
                    .frame(height: customCategoryHeight ?? 30)
                
                Text(data)
                    .font(.system(size: customDataFontSize ?? 16))
                    .fontWeight(.medium)
                    .frame(height: 30)
            }
            .frame(maxWidth: 50)
        }
    }
}

struct EmptyStatDataItem: View {
    let customCategoryFontSize: CGFloat?
    let customDataFontSize: CGFloat?
    let customWidth: CGFloat?
    let customCategoryHeight: CGFloat?
    
    init(
        customCategoryFontSize: CGFloat? = nil,
        customDataFontSize: CGFloat? = nil,
        customWidth: CGFloat? = nil,
        customCategoryHeight: CGFloat? = nil
    ) {
        self.customCategoryFontSize = customCategoryFontSize
        self.customDataFontSize = customDataFontSize
        self.customWidth = customWidth
        self.customCategoryHeight = customCategoryHeight
    }
    
    var body: some View {
        FBStatDataItem(
            category: "",
            data: "",
            customCategoryFontSize: customCategoryFontSize,
            customDataFontSize: customDataFontSize,
            customWidth: customWidth,
            customCategoryHeight: customCategoryHeight
        )
    }
}

//#Preview {
//    FBStatDataItem()
//}
