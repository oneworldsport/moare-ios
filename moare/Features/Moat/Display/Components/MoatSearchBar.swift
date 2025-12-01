//
//  MoatSearchBar.swift
//  moare
//
//  Created by Mohwa Yoon on 12/1/25.
//

import SwiftUI

struct MoatSearchBar: View {
    @Binding var text: String
    @Binding var isSearchBarOpened: Bool
    
    @FocusState private var focusState: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if isSearchBarOpened {
                Text("#")
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
                
                TextField(" 스포츠 입력", text: $text)
                    .focused($focusState)
                    .padding(.trailing, 4)
            }
            
            if isSearchBarOpened {
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle")
                    }
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 8)
                }
                
                Button(action: {
                    // TODO: 이때 selected된거 다 지워야함
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
        .frame(height: 36)
        .padding(.horizontal, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.moare, lineWidth: 2)
        )
    }
}
