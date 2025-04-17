//
//  RecommendQueryList.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/18/24.
//

import SwiftUI

struct TrendingKeywordList: View {
    let keywords: [String]
    
    let onItemSelected: (String) -> ()
    
    var body: some View {
        ScrollView(.horizontal) {
            VStack {
                Spacer()
                
                HStack(spacing: 10) {
                    ForEach(keywords.indices, id: \.self) { index in
                        let keyword = keywords[index]
                        
                        if index != 0 {
                            KeywordItem(keyword: keyword) {
                                onItemSelected(keyword)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 40)
        .simultaneousGesture(DragGesture())
    }
}

struct KeywordItem: View {
    let keyword: String
    
    let onItemSelected: () -> ()
    
    var body: some View {
        Button(action: {
            onItemSelected()
        }) {
            VStack(spacing: 0) {
                Text(keyword)
                    .padding(.vertical, 7)
                
                HCapsuleBar(color: .secondary)
            }
            .padding(.horizontal, 10)
        }
        .buttonStyle(KeywordButtonStyle())
    }
}

//struct PressableButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.9 : 1.0) // 눌릴 때 축소 효과
//            .opacity(configuration.isPressed ? 0.7 : 1.0) // 눌릴 때 투명도 조절
//            .animation(.easeOut(duration: 0.2), value: configuration.isPressed) // 부드러운 애니메이션
//    }
//}

struct KeywordButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(configuration.isPressed ? .moare : .clear, lineWidth: 2)
            }
    }
}

//#Preview {
//    let data = ["test", "test1", "test2", "test2", "test2", "test2", "test2", "test2"]
//    return TrendingKeywords(keywords: data, onItemSelected: {_ in })
//}
