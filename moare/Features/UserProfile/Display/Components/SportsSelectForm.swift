//
//  SportsSelectForm.swift
//  moare
//
//  Created by Mohwa Yoon on 11/16/25.
//

import SwiftUI

struct SportsSelectForm: View {
    let sportsInterests: [String]
    
    let onItemSelect: (String) -> Void
    
    @State private var text = ""
    @State private var isSearchBarOpened = false
    @State private var filteredSportList: [String] = ["축구", "야구", "농구", "테니스", "F1", "배구", "골프", "미식축구", "럭비", "MMA", "복싱", "하키", "수영", "육상"]
    
    @FocusState var focusState: Bool
    
    private let sportList = ["축구", "야구", "농구", "테니스", "F1", "배구", "골프", "미식축구", "럭비", "MMA", "복싱", "하키", "수영", "육상"]
    private let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if isSearchBarOpened {
                    Button(action: {
                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                            text = ""
                            isSearchBarOpened = false
                        }
                    }) {
                        Text("닫기")
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(.primary)
                }
                
                if !isSearchBarOpened {
                    Spacer()
                }
                
                HStack {
                    if isSearchBarOpened {
                        TextField(" 스포츠 검색", text: $text)
                            .focused($focusState)
                            .font(.system(size: 15))
                            .padding(.leading, 4)
                    }
                    
                    Button(action: {
                        if !isSearchBarOpened {
                            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                                isSearchBarOpened = true
                                focusState = true
                            }
                        }
                    }) {
                       Image(systemName: "magnifyingglass")
                    }
                    .foregroundStyle(.primary)
                }
                .frame(height: 32)
                .padding(.horizontal, 8)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.moare, lineWidth: 2)
                )
            }
            .zIndex(1)
            
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows, spacing: 16) {
                    ForEach(filteredSportList, id: \.self) { sport in
                        Button(action: {
                            onItemSelect(sport)
                        }) {
                            VStack(spacing: 0) {
                                HCapsuleBar(color: .secondary)
                                    .opacity(sportsInterests.contains(sport) ? 0 : 0.8)
                                
                                Text(sport)
                                    .padding(.vertical, 4)
                            }
                            .padding(.horizontal, 10)
                        }
                        .overlay {
                            if sportsInterests.contains(sport) {
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(.moare, lineWidth: 2)
                            }
                        }
                        .buttonStyle(KeywordButtonStyle())
                    }
                }
                .padding(.trailing, 30) // 마지막 아이템 검색 버튼에 안가려지게 스크롤에 여유 공간 줌.
                .onChange(of: text) {
                    filteredSportList = text.isEmpty ? sportList : sportList.filter { $0.contains(text) }
                }
            }
            .frame(maxHeight: 80)
            .offset(x: 0, y: isSearchBarOpened ? 8 : -32)
        }
    }
}
