//
//  ContentView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var searchStore: StoreOf<SearchStore>? = nil
    
    /* ---------------------
       constants
       --------------------- */
    private let dragMaxOffset = UIConstants.Width.screenWidth / 3 + 20
    
    /* ---------------------
       ui state
       --------------------- */
    @FocusState var focusState: Bool
    
    @State private var dragOffset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    @State private var isInfoIconVisible = true
    @State private var isInfoOpened = false
    
    var body: some View {
        ZStack {
            if let searchStore = searchStore {
                /* ---------------------
                   info icon
                   - info about currently providing data
                   --------------------- */
                if isInfoIconVisible {
                    if isInfoOpened {
                        HStack {
                            Spacer()
                            
                            ScrollView {
                                VStack(alignment: .leading) {
                                    Text("현재 제공중인 스포츠 데이터:")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                    Text("• 프리미어리그 24/25")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                    Text("\n제공 예정 스포츠 데이터:")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                    Text("• 라리가 24/25\n• 분데스리가 24/25\n• 리그 1 24/25\n• 챔피언스리그 24/25")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(10)
                            }
                            .frame(maxHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: UIConstants.CornerRadius.small)
                                    .stroke(.secondary, lineWidth: UIConstants.StrokeWidth.thin)
                            )
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, 210)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isInfoOpened.toggle()
                        }) {
                            Image(systemName: "info.circle")
                                .tint(.secondary)
                        }
                    }
                    .padding(.trailing, 12)
                    .padding(.bottom, 80)
                }
            
                VStack(spacing: 0) {
                    Spacer()
                    
                    /* ---------------------
                     search bar
                     --------------------- */
                    AnimatingSearchBar(
                        focusState: $focusState
                    )
                    
                    ZStack {
                        /* ---------------------
                           autocomplete list
                           --------------------- */
                        if !searchStore.autoCompleteList.isEmpty {
                            AutoCompleteList(autoCompleteList: searchStore.autoCompleteList, onItemSelected: { words in
                                focusState.toggle()
                                
                                // update bar's text
                                searchStore.send(.updateTextField(words, false))
                                
                                // remove textfield for bar animation
                                searchStore.send(.updateTextFieldVisibleState(false))
                                
                                // remove autocomplete after bar's animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.medium) {
                                    searchStore.send(.removeAutoCompleteWithAni)
                                }
                                
                                // search
                                searchStore.send(.performSearch(AnimationConstants.Duration.medium * 2))
                            })
                        }
                        
                        /* ---------------------
                           loading
                           --------------------- */
                        if searchStore.searchDataState == .fetching {
                            ProgressView()
                                .padding(.top, UIConstants.Padding.defaultPadding)
                        }
                        
                        /* ---------------------
                           search result
                           --------------------- */
                        if searchStore.resultVisibleState {
                            VStack {
                                // football_player_info
                                if let data = searchStore.fbPlayerInfoData {
                                    FBPlayerInfoView(displayModel: data)
                                }
                                
                                // football_player_stats
                                if let data = searchStore.fbPlayerStatsData {
                                    FBPlayerStatsView(displayModel: data)
                                }
                                
                                // football_player_standings
                                if let data = searchStore.fbPlayerStandingsData {
                                    FBPlayerStandingsView(displayModel: data)
                                }
                                
                                // football_team_info
                                if let data = searchStore.fbTeamInfoData {
                                    FBTeamInfoView(displayModel: data)
                                }
                                
                                // football_team_stats
                                if let data = searchStore.fbTeamStatsData {
                                    FBTeamStatsView(displayModel: data)
                                }
                                
                                // football_team_standings
                                if let data = searchStore.fbTeamStandingsData {
                                    FBTeamStandingsView(displayModel: data)
                                }
                                
                                // football_team_schedule
                                if let data = searchStore.fbTeamScheduleData {
                                    FBTeamScheduleView(displayModel: data)
                                }
                                
                                // football_league_schedule
                                if let data = searchStore.fbLeagueScheduleData {
                                    FBLeaugScheduleView(displayModel: data)
                                }
                                
                                // football_game_stats
                                if let data = searchStore.fbGameStatsData {
                                    FBGameStatsView(displayModel: data)
                                }
                            } // VStack
                            .padding(.top, UIConstants.Padding.defaultPadding)
                        } // if searchStore.resultVisibleState
                        
                        /* ---------------------
                           error
                           --------------------- */
                        if case .failure(let message) = searchStore.searchDataState {
                            Text(message)
                                .padding(.top, UIConstants.Padding.defaultPadding)
                        }
                    } // ZStack
                    .onChange(of: searchStore.isFocused) { newValue in
                        //                        focusState = newValue
                    }
                    
                    Spacer()
                } // VStack
                // TODO: has to think about better structure
                .onChange(of: searchStore.searchState) { newVaue in
                    if newVaue {
                        withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                            isInfoOpened = false
                            isInfoIconVisible = false
                        }
                    } else {
                        withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                            isInfoIconVisible = true
                        }
                    }
                }
                // TODO: has to think about better structure
                .onChange(of: searchStore.autoCompleteList) { newValue in
                    if newValue.isEmpty && !searchStore.searchState {
                        withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                            isInfoIconVisible = true
                        }
                    } else {
                        withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                            isInfoOpened = false
                            isInfoIconVisible = false
                        }
                    }
                }
                .gesture(
                    // custom back handler
                    DragGesture()
                        .onChanged { value in
                            if !searchStore.viewStack.isEmpty {
                                dragOffset = value.translation.width
                                
                                if dragOffset > 0 {
                                    opacity = max(1 - Double(dragOffset / dragMaxOffset), 0.2)
                                }
                            }
                        }
                        .onEnded { _ in
                            if !searchStore.viewStack.isEmpty {
                                if dragOffset > dragMaxOffset {
                                    searchStore.send(.goBack)
                                }
                                
                                dragOffset = 0
                                
                                withAnimation(.easeOut(duration: 0.5)) {
                                    opacity = 1.0
                                }
                            }
                        }
                )
            } // if let searchStore
        } // ZStack
        .opacity(opacity)
        .onAppear {
            // init SearchStore
            if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
                self.searchStore = searchStore
            } else {
                storeManager.setStore(Store(initialState: SearchStore.State()) { SearchStore() }, forKey: StoreKeys.searchStore)
                searchStore = storeManager.getStore(forKey: StoreKeys.searchStore)
                
                // init Trie
                searchStore?.send(.initTrie)
            }
            
            // test
//            searchStore?.send(.initForTest)
        }
    }
}
