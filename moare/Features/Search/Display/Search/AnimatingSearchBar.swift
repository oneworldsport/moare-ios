//
//  AnimatingSearchBar.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/4/24.
//

import SwiftUI
import ComposableArchitecture

struct AnimatingSearchBar: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @Bindable var searchStore: StoreOf<SearchStore>
    
    /* ---------------------
       constants
       --------------------- */
    let barHeight: CGFloat = 50
    let paddingForBackButton: CGFloat = 40
    
    /* ---------------------
       ui state
       --------------------- */
    @FocusState.Binding var focusState: Bool
    
    @State private var startPathAni = false
    @State private var barVisibleState = false
    
    var body: some View {
        let barWidth = UIConstants.Width.screenWidth - 20
        
        ZStack {
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    ZStack {
                        // first show: yes ani, no delay
                        // gone: no ani, no delay
                        // show: no ani, yes delay
                        //                            TextField(" \(searchStore.trendingKeywordList.first ?? "")", text: $query)
                        TextField(" \(searchStore.trendingKeywordList.first ?? "")", text: $searchStore.query)
                            .focused($focusState)
                            .accentColor(.primary)
                            .disabled(!barVisibleState)
                            .uiState(visibleState: searchStore.textFieldVisibleState)
                            .submitLabel(.search)
                            .onSubmit {
                                Task {
                                    // NOTE: 키보드 버튼으로 검색했을때 자동완성 리스트가 안사라지는 버그 있는데, performSearch()에서 .removeAutoCompleteWithAni로 자동완성 리스트 지우고 나서
                                    // focusState바뀌면서 binding(\.query)가 실행되어 자동완성이 나오는 것 같아, 먼저 focusState = false 설정해줌.
                                    // 그리고 바로 performSearch()하면 또 안돼서 0.1초 delay줌.
                                    focusState = false
                                    try await Task.sleep(for: .seconds(0.1))
                                    performSearch()
                                }
                            }
                        
                        Text(searchStore.query)
                            .frame(maxWidth: searchStore.searchState ? nil : .infinity, alignment: .leading)
                            .opacity(searchStore.textFieldVisibleState ? 0 : 1)
                            .uiState(visibleState: barVisibleState) // always showing after first open
                    }
                    
                    Button(action: {
                        if !searchStore.firstOpened {
                            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                                startPathAni = true
                                searchStore.send(.updateTextFieldVisibleState(true))
                                searchStore.send(.firstOpen)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.medium) {
                                barVisibleState = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.medium + 0.1) {
                                focusState.toggle()
                            }
                        } else {
                            if searchStore.searchState {
                                searchStore.send(.toggleSearchBar)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.medium) {
                                    searchStore.send(.updateTextFieldVisibleState(true))
                                    focusState.toggle()
                                }
                            } else {
                                performSearch()
                            }
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                            .tint(Color.primary)
                            .padding(.leading, searchStore.firstOpened ? 10 : 0)
                    }
                }
                .frame(height: barHeight)
                .padding(EdgeInsets(top: 0, leading: searchStore.firstOpened ? 20 : 0, bottom: 0, trailing: searchStore.firstOpened ? 10 : 0))
                .overlay(
                    RoundedRectangle(cornerRadius: UIConstants.CornerRadius.medium)
                        .stroke(searchStore.searchState ? .gray : .moare, lineWidth: UIConstants.StrokeWidth.defaultWidth)
                        .uiState(visibleState: barVisibleState)
                )
                .onTapGesture {
                    if searchStore.searchState {
                        searchStore.send(.toggleSearchBar)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.medium) {
                            focusState.toggle()
                        }
                    }
                }
                .padding(.horizontal, searchStore.searchState ? UIConstants.Padding.defaultHPadding + paddingForBackButton : UIConstants.Padding.defaultHPadding)
                
                Spacer()
                    .uiState(visibleState: searchStore.searchState)
            }
            
            // searchBar with animation on first open
            RoundedRectWithPathAni(
                width: barWidth,
                height: barHeight,
                startPoint: CGPoint(x: barWidth / 2, y: barHeight),
                cornerRadius: UIConstants.CornerRadius.medium,
                strokeWidth: UIConstants.StrokeWidth.defaultWidth,
                drawPath: startPathAni
            )
            .uiState(visibleState: !barVisibleState)
        }
    }
    
    private func performSearch() {
        let isBlank = searchStore.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if isBlank {
            if let firstTrendingKeyword = searchStore.trendingKeywordList.first {
                // update bar's text
                searchStore.send(.updateTextField(firstTrendingKeyword, false))
                
                // remove textfield for bar animation
                searchStore.send(.updateTextFieldVisibleState(false))
                
                // search
                searchStore.send(.performSearch(searchType: .trendingKeyword, aniDuration: AnimationConstants.Duration.medium))
                searchStore.send(.removeAutoCompleteWithAni)
            }
        } else {
            searchStore.send(.updateTextFieldVisibleState(false))
            
            searchStore.send(.performSearch(aniDuration: AnimationConstants.Duration.medium))
            searchStore.send(.removeAutoCompleteWithAni)
        }
    }
}
