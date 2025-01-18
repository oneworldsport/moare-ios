//
//  RecommendQueryList.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/18/24.
//

import SwiftUI

struct KeywordList: View {
    let data: [String]
    
    let itemHeight:CGFloat = 40
    
    @State var selectedKeyword = ""
    @State var itemWidths: [Int: CGFloat] = [:]
    
    let onItemSelected: (String) -> ()
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(data.indices, id: \.self) { index in
                    let keyword = data[index]
                    
                    KeywordItem(keyword: keyword, height: itemHeight, selectedKeyword: $selectedKeyword) {
                        if selectedKeyword != keyword {
                            selectedKeyword = keyword
                            onItemSelected(keyword)
                        }
                    }
                }
            }            
        }
        .frame(height: itemHeight)
    }
}

struct KeywordItem: View {
    let keyword: String
    let height: CGFloat
    
    @Binding var selectedKeyword: String
    
    let onItemSelected: () -> ()
    
    var body: some View {
        Button(action: {
            onItemSelected()
        }) {
            VStack(spacing: 7) {
                Text(keyword)
                    .padding(.horizontal)
                    .foregroundColor(keyword == selectedKeyword ? .moare : .primary)
                
                Capsule()
                    .frame(width: 20, height: 2)
                    .foregroundColor(keyword == selectedKeyword ? .moare : .secondary)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    let data = ["test", "test1", "test2"]
    return KeywordList(data: data, onItemSelected: {_ in })
}
