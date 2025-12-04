//
//  SportsSelectForm.swift
//  moare
//
//  Created by Mohwa Yoon on 11/16/25.
//

import SwiftUI

struct SportsSelectForm: View {
    private let sportsInterests: [String] // 내가 선택한 것만 색깔이 들어감.. 추후 이름 변경 필요
    private let isHashTag: Bool
    private let sportList: [String]
    
    private let onItemSelect: (String) -> Void
    
    @State private var text = ""
    @State private var isSearchBarOpened = false
    @State private var filteredSportList: [String]
    
    @FocusState private var focusState: Bool
    
    private let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    init(
        sportsInterests: [String],
        isHashTag: Bool = false,
        onItemSelect: @escaping (String) -> Void
    ) {
        self.sportsInterests = sportsInterests
        self.isHashTag = isHashTag
        self.onItemSelect = onItemSelect
        
        if isHashTag {
            self.sportList = StringConstants.sportList.map { "# \($0)" }
        } else {
            self.sportList = StringConstants.sportList
        }
        
        _filteredSportList = State(initialValue: self.sportList)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if !isSearchBarOpened {
                    Spacer()
                }
                
                // SearchBar
                HStack {
                    if isSearchBarOpened {
                        TextField(" 스포츠 입력", text: $text)
                            .focused($focusState)
                            .font(.system(size: 15))
                            .padding(.leading, 4)
                    }
                    
                    if isSearchBarOpened {
                        Button(action: {
                            text = ""
                        }) {
                            Image(systemName: "xmark.circle")
                        }
                        
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
                    } else {
                        Button(action: {
                            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                                isSearchBarOpened = true
                                focusState = true
                            }
                        }) {
                           Image(systemName: "magnifyingglass")
                        }
                        .foregroundStyle(.primary)
                    }
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
                    filteredSportList = text.isBlank ? sportList : sportList.filter { $0.contains(text) }
                }
            }
            .frame(maxHeight: 80)
            .offset(x: 0, y: isSearchBarOpened ? 8 : -32)
        }
    }
}
