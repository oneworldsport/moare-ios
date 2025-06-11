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
    let barHeight: CGFloat = 50
    
    /* ---------------------
       ui state
       --------------------- */
    @FocusState var focusState: Bool
    
    @State private var dragOffset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    @State private var isNoticeIconVisible = false
    @State private var isNoticeOpened = false
    
    var body: some View {
        ZStack {
            if let searchStore = searchStore {
                /* ---------------------
                   back button
                   --------------------- */
                VStack {
                    HStack {
                        Button(action: {
                            searchStore.send(.goBack)
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 22))
                                .frame(width: 30, height: barHeight)
                                .padding(.leading, 10)
                        }
                        .foregroundStyle(.moare)
                        
                        Spacer()
                    }

                    Spacer()
                }
                .zIndex(1)
                
                /* ---------------------
                   notice
                   - notice about providing data
                   --------------------- */
                if isNoticeIconVisible {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            NoticeBox(noticeList: searchStore.noticeList)
                                .opacity(isNoticeOpened ? 1 : 0)
                            
                            Button(action: {
                                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                                    isNoticeOpened.toggle()
                                }
                            }) {
                                Image(systemName: "info.circle")
                                    .tint(.secondary)
                                    .padding(.leading, 8)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.trailing, 12)
                    }
                    .offset(x: 0, y: -113)
                    .zIndex(1)
                    // y: 전체 박스 높이(100 + 20 + 4) / 2 + (검색창 높이(50) + 트렌딩 키워드 높이(40)) / 2 + 추가 패딩 6
                }
                
                VStack(spacing: 0) {
                    /* ---------------------
                       search bar
                       --------------------- */
                    AnimatingSearchBar(
                        searchStore: searchStore,
                        focusState: $focusState
                    )
                    
                    /* ---------------------
                       trending keywords
                       --------------------- */
                    if searchStore.trendingKeyowrdsVisibleState {
                        TrendingKeywordList(keywords: searchStore.trendingKeywordList) { keyword in
                            // update bar's text
                            searchStore.send(.updateTextField(keyword, false))
                            
                            // remove textfield for bar animation
                            searchStore.send(.updateTextFieldVisibleState(false))
                            
                            searchStore.send(.performSearch(searchType: .trendingKeyword, aniDuration: AnimationConstants.Duration.medium))
                        }
                    }
                    
                    ZStack {
                        /* ---------------------
                           autocomplete list
                           --------------------- */
                        if !searchStore.autoCompleteList.isEmpty {
                            AutoCompleteList(autoCompleteList: searchStore.autoCompleteList, onItemSelected: { words in
                                // update bar's text
                                searchStore.send(.updateTextField(words, false))
                                
                                // remove textfield for bar animation
                                searchStore.send(.updateTextFieldVisibleState(false))
                                
                                // remove autocomplete after bar's animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.medium) {
                                    searchStore.send(.removeAutoCompleteWithAni)
                                }
                                
                                // search
                                searchStore.send(.performSearch(searchType: .autoComplete, aniDuration: AnimationConstants.Duration.medium * 2))
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
                                let views = viewsToRender()
                                ForEach(views.indices, id: \.self) { index in
                                    views[index]
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
                    .onChange(of: searchStore.isFocused) {
                        if searchStore.isFocused {
                            focusState.toggle()
                            searchStore.send(.updateIsFocused(false)) // Reset searchStore's isFocused to ensure this .onChange() triggered when isFocused set true.
                        }
                    }
                } // VStack
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle()) // for .onTapGesture{}
                // TODO: has to think about better structure
                .onChange(of: searchStore.searchState) {
                    if searchStore.searchState {
                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                            isNoticeOpened = false
                            isNoticeIconVisible = false
                            searchStore.send(.updateTrendingKeywordsVisibleState(false))
                        }
                    } else {
                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                            isNoticeIconVisible = true
                            searchStore.send(.updateTrendingKeywordsVisibleState(true))
                        }
                    }
                }
                // TODO: has to think about better structure
                .onChange(of: searchStore.autoCompleteList) {
                    if searchStore.autoCompleteList.isEmpty && !searchStore.searchState {
                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                            isNoticeIconVisible = true
                            searchStore.send(.updateTrendingKeywordsVisibleState(true))
                        }
                    } else {
                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                            isNoticeOpened = false
                            isNoticeIconVisible = false
                            searchStore.send(.updateTrendingKeywordsVisibleState(false))
                        }
                    }
                }
                .onChange(of: searchStore.firstOpened) {
                    if searchStore.firstOpened {
                        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.medium) {
                            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                                isNoticeIconVisible = true
                                searchStore.send(.updateTrendingKeywordsVisibleState(true))
                            }
                        }
                    }
                }
                .onTapGesture {
                    if isNoticeOpened {
                        withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                            isNoticeOpened = false
                        }
                    } else {
                        focusState = false
                    }
                }
                .gesture(
                    // custom back handler
                    DragGesture(minimumDistance: 3)
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
            let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) ?? {
                let newStore = Store(initialState: SearchStore.State()) { SearchStore() }
                
                storeManager.setStore(newStore, forKey: StoreKeys.searchStore)
                
                return newStore
            }()
            
            self.searchStore = searchStore
            
            if searchStore.poppedView == nil {
                searchStore.send(.initData)
            }
            
//            if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
//                self.searchStore = searchStore
//            } else {
//                storeManager.setStore(Store(initialState: SearchStore.State()) { SearchStore() }, forKey: StoreKeys.searchStore)
//                searchStore = storeManager.getStore(forKey: StoreKeys.searchStore)
//                
//                searchStore?.send(.initData)
//            }
            
            // test
//            searchStore?.send(.initForTest)
        }
    }
    
    // NOTE: VStack안에 if let 조건문 너무 많아서 생긴 런타임 에러(EXC_BAD_ACCESS)로 인해 추가. 정확한 원인 및 해결 방법은 더 조사 필요.
    func viewsToRender() -> [AnyView] {
        var views: [AnyView] = []
        
        // football
        if let data = searchStore?.fbPlayerInfoData {
            views.append(AnyView(FBPlayerInfoView(displayModel: data)))
        }
        if let data = searchStore?.fbPlayerStatsData {
            views.append(AnyView(FBPlayerStatsView(displayModel: data)))
        }
        if let data = searchStore?.fbPlayerStandingsData {
            views.append(AnyView(FBPlayerStandingsView(displayModel: data)))
        }
        if let data = searchStore?.fbTeamInfoData {
            views.append(AnyView(FBTeamInfoView(displayModel: data)))
        }
        if let data = searchStore?.fbTeamStatsData {
            views.append(AnyView(FBTeamStatsView(displayModel: data)))
        }
        if let data = searchStore?.fbTeamStandingsData {
            views.append(AnyView(FBTeamStandingsView(displayModel: data)))
        }
        if let data = searchStore?.fbTeamScheduleData {
            views.append(AnyView(FBTeamScheduleView(displayModel: data)))
        }
        if let data = searchStore?.fbLeagueScheduleData {
            views.append(AnyView(FBLeaugeScheduleView(displayModel: data)))
        }
        if let data = searchStore?.fbGameStatsData {
            views.append(AnyView(FBGameStatsView(displayModel: data)))
        }

        // basketball
        if let data = searchStore?.nbaPlayerInfoData {
            views.append(AnyView(NBAPlayerInfoView(displayModel: data)))
        }
        if let data = searchStore?.nbaPlayerStatsData {
            views.append(AnyView(NBAPlayerStatsView(displayModel: data)))
        }
        if let data = searchStore?.nbaPlayerStandingsData {
            views.append(AnyView(NBAPlayerStandingsView(displayModel: data)))
        }
        if let data = searchStore?.nbaTeamInfoData {
            views.append(AnyView(NBATeamInfoView(displayModel: data)))
        }
        if let data = searchStore?.nbaTeamStatsData {
            views.append(AnyView(NBATeamStatsView(displayModel: data)))
        }
        if let data = searchStore?.nbaTeamStandingsData {
            views.append(AnyView(NBATeamStandingsView(displayModel: data)))
        }
        if let data = searchStore?.nbaTeamScheduleData {
            views.append(AnyView(NBATeamScheduleView(displayModel: data)))
        }
        if let data = searchStore?.nbaLeagueScheduleData {
            views.append(AnyView(NBALeagueScheduleView(displayModel: data)))
        }
        if let data = searchStore?.nbaGameStatsData {
            views.append(AnyView(NBAGameStatsView(displayModel: data)))
        }
        if let data = searchStore?.nbaLeagueTournamentData {
            views.append(AnyView(NBALeagueTournamentView(displayModel: data)))
        }
        
        // kbo
        if let data = searchStore?.kboPlayerInfoData {
            views.append(AnyView(KBOPlayerInfoView(displayModel: data)))
        }
//        if let data = searchStore?.kboPlayerStatsData {
//            views.append(AnyView(KBOPlayerStatsView(displayModel: data)))
//        }
//        if let data = searchStore?.kboPlayerStandingsData {
//            views.append(AnyView(KBOPlayerStandingsView(displayModel: data)))
//        }
        if let data = searchStore?.kboTeamInfoData {
            views.append(AnyView(KBOTeamInfoView(displayModel: data)))
        }
//        if let data = searchStore?.kboTeamStatsData {
//            views.append(AnyView(KBOTeamStatsView(displayModel: data)))
//        }
        if let data = searchStore?.kboTeamStandingsData {
            views.append(AnyView(KBOTeamStandingsView(displayModel: data)))
        }
        if let data = searchStore?.kboLeagueScheduleData {
            views.append(AnyView(KBOLeagueScheduleView(displayModel: data)))
        }
        if let data = searchStore?.kboGameStatsData {
            views.append(AnyView(KBOGameStatsView(displayModel: data)))
        }
        
        // mlb
        if let data = searchStore?.mlbPlayerInfoData {
            views.append(AnyView(MLBPlayerInfoView(displayModel: data)))
        }
        if let data = searchStore?.mlbPlayerStatsData {
            views.append(AnyView(MLBPlayerStatsView(displayModel: data)))
        }
//        if let data = searchStore?.mlbPlayerStandingsData {
//            views.append(AnyView(MLBPlayerStandingsView(displayModel: data)))
//        }
        if let data = searchStore?.mlbTeamInfoData {
            views.append(AnyView(MLBTeamInfoView(displayModel: data)))
        }
//        if let data = searchStore?.mlbTeamStatsData {
//            views.append(AnyView(MLBTeamStatsView(displayModel: data)))
//        }
        if let data = searchStore?.mlbTeamStandingsData {
            views.append(AnyView(MLBTeamStandingsView(displayModel: data)))
        }
        if let data = searchStore?.mlbLeagueScheduleData {
            views.append(AnyView(MLBLeagueScheduleView(displayModel: data)))
        }
        if let data = searchStore?.mlbGameStatsData {
            views.append(AnyView(MLBGameStatsView(displayModel: data)))
        }

        return views
    }
}
