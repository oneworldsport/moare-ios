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
    
    /* ---------------------
       constants
       --------------------- */
    let barHeight = 50.0
    
    /* ---------------------
       ui state
       --------------------- */
    @FocusState.Binding var focusState: Bool
    
    @State private var query = ""
    
    @State private var startPathAni = false
    @State private var barVisibleState = false
    @State private var textFieldVisibleState = false
    
    var body: some View {
        let barWidth = UIConstants.Width.screenWidth - 20
        
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ZStack {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ZStack {
                            // first show: yes ani, no delay
                            // gone: no ani, no delay
                            // show: no ani, yes delay
                            TextField(" \(searchStore.trendingKeywordList.first ?? "")", text: $query)
                                .focused($focusState)
                                .accentColor(.primary)
                                .disabled(!barVisibleState)
                                .uiState(visibleState: searchStore.textFieldVisibleState)
                            
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
                                    let isBlank = searchStore.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    
                                    if isBlank {
                                        if let firstTrendingKeyword = searchStore.trendingKeywordList.first {
                                            focusState.toggle()
                                            
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
                                        
                                        focusState.toggle()
                                    }
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
                    .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    
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
            .onChange(of: query) { newValue in
                if searchStore.query != query {
                    searchStore.send(.updateTextField(query))
                }
            }
            .onChange(of: searchStore.query) { newValue in
                // if self.query == newValue -> doesn't trigger onChange(of: query)
                self.query = newValue
            }
        }
    }
}

//#Preview {
//    @State var isSearched = false
//    return AnimatingSearchBar(store: Store(initialState: SearchFeature.State()) {
//        SearchFeature()
//    }, isSearched: $isSearched)
//}
