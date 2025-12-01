//
//  MoatSearchForm.swift
//  moare
//
//  Created by Mohwa Yoon on 12/1/25.
//

import SwiftUI

struct MoatSearchForm: View {
    @Binding var text: String
    
    private let selectedHashTags: [String]
    private let hashtagList: [String]
    
    private let onItemSelect: (String) -> Void
    private let onComplete: () -> Void
    
    @State private var filteredHashtagList: [String] = []
    
    private let rows: [GridItem] = Array(repeating: .init(.fixed(40), spacing: 0), count: 3)
    
    init(
        text: Binding<String>,
        selectedHashTags: [String],
        onItemSelect: @escaping (String) -> Void,
        onComplete: @escaping () -> Void
    ) {
        self._text = text
        self.selectedHashTags = selectedHashTags
        self.hashtagList = StringConstants.sportList.map { "# \($0)" }
        self.filteredHashtagList = self.hashtagList
        self.onItemSelect = onItemSelect
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows, spacing: 8) {
                    ForEach(filteredHashtagList, id: \.self) { hashtag in
                        let isSelected = selectedHashTags.contains(hashtag)
                        
                        Button(action: {
                            onItemSelect(hashtag)
                        }) {
                            VStack(spacing: 0) {
                                HCapsuleBar(color: .secondary)
                                    .opacity(isSelected ? 0 : 0.8)
                                
                                Text(hashtag)
                                    .padding(.vertical, 6)
                            }
                            .padding(.horizontal, 10)
                        }
                        .overlay {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(.moare, lineWidth: 2)
                            }
                        }
                        .buttonStyle(KeywordButtonStyle())
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 40) // 마지막 아이템 완료 버튼에 안가려지게 스크롤에 여유 공간 줌.
                .onChange(of: text) {
                    filteredHashtagList = text.isEmpty ? hashtagList : hashtagList.filter { $0.contains(text) }
                }
            }
            
            Button(action: onComplete) {
                Text("완료")
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(.white)
                    )
                    .overlay(
                        Capsule()
                            .stroke(.moare, lineWidth: 1)
                    )
            }
            .foregroundStyle(.moare)
            .padding(.top, 4)
            .padding(.trailing, 8)
        }
        .frame(height: 120)
        .padding(.top, 8)
    }
}
