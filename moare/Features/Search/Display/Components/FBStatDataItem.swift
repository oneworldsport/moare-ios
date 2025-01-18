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
    let customFontSize: CGFloat?
    let customWidth: CGFloat?
    
    init(category: String, data: String, customFontSize: CGFloat? = nil, customWidth: CGFloat? = nil) {
        self.category = category
        self.data = data
        self.customFontSize = customFontSize
        self.customWidth = customWidth
    }
    
    var body: some View {
        VStack {
            Text(category)
                .font(.system(size: customFontSize ?? 15))
            
            Text(data)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .frame(maxHeight: 30) // make it feature constants
        }
        .frame(maxWidth: customWidth ?? 50)
    }
}

//#Preview {
//    FBStatDataItem()
//}
