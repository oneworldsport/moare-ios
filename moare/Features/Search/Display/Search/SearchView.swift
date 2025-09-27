//
//  ContentView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    let appStore: StoreOf<AppStore>
    let searchStore: StoreOf<SearchStore>

    private let dragMaxOffset = UIConstants.Width.screenWidth / 3 + 20
    let barHeight: CGFloat = 50
    
    @FocusState var focusState: Bool
    
    @State private var dragOffset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    @State private var isNoticeIconVisible = false
    @State private var isNoticeOpened = false
    @State private var isSearchExampleButtonVisible = false
    @State private var isSearchExampleOpened = false
    @State var noticeBoxHeight: CGFloat = 0
    
    var viewForTest: SportDisplayType? = nil
    
    var body: some View {
        // notice 아이콘 y 위치
        // y: (전체 컨텐츠 높이(박스 높이(noticeBoxHeight) + 아이콘 높이(17) + spacing(6))) / 2 + (검색창 높이(50) + 트렌딩 키워드 높이(40)) / 2 + 추가 패딩 6
        let noticeYOffset = ((noticeBoxHeight + 17 + 6) / 2) + ((50 + 40) / 2) + 6
        
        ZStack {
            /* ---------------------
             back button
             --------------------- */
            VStack {
                HStack {
                    Button(action: {
                        searchStore.send(.pop)
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
             notice, search example
             --------------------- */
            HStack(alignment: .bottom) {
                if isSearchExampleButtonVisible {
                    VStack(alignment: .leading, spacing: 6) {
                        SearchExampleBox(text: searchStore.searchExample)
                            .opacity(isSearchExampleOpened ? 1 : 0)
                            .padding(.trailing, 25)
                        
                        Button(action: {
                            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                                isSearchExampleOpened.toggle()
                            }
                        }) {
                            Text("검색 예시")
                                .font(.system(size: 13))
                                .tint(.secondary)
                                .opacity(0.7)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if isNoticeIconVisible {
                    VStack(alignment: .trailing, spacing: 6) {
                        NoticeBox(noticeList: searchStore.noticeList, height: $noticeBoxHeight)
                            .opacity(isNoticeOpened ? 1 : 0)
                        
                        Button(action: {
                            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                                isNoticeOpened.toggle()
                            }
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 17))
                                .tint(.secondary)
                                .opacity(0.7)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .offset(x: 0, y: -noticeYOffset)
            .zIndex(1)
            
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
                        VStack(spacing: 0) {
                            if appStore.includesPreviousView {
                                if let id = appStore.path.ids.suffix(2).first {
                                  if let store = appStore.scope(
                                    state: \.path[id: id],
                                    action: \.path[id: id]
                                  ) {
                                      PathView(
                                        searchStore: searchStore,
                                        store: store,
                                        didPop: true,
                                        isCombinedView: true
                                      )
                                  }
                                }
                            }
                            
                            if let id = appStore.path.ids.last {
                              if let store = appStore.scope(
                                state: \.path[id: id],
                                action: \.path[id: id]
                              ) {
                                PathView(
                                  searchStore: searchStore,
                                  store: store,
                                  didPop: appStore.didPop,
                                  isCombinedView: appStore.includesPreviousView
                                )
                              }
                            }
                        }
                        .padding(.top, UIConstants.Padding.defaultPadding)
                    }
                    
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
                        isSearchExampleOpened = false
                        isSearchExampleButtonVisible = false
                        searchStore.send(.updateTrendingKeywordsVisibleState(false))
                    }
                } else {
                    withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                        isNoticeIconVisible = true
                        isSearchExampleButtonVisible = true
                        searchStore.send(.updateTrendingKeywordsVisibleState(true))
                    }
                }
            }
            // TODO: has to think about better structure
            .onChange(of: searchStore.autoCompleteList) {
                if searchStore.autoCompleteList.isEmpty && !searchStore.searchState {
                    withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                        isNoticeIconVisible = true
                        isSearchExampleButtonVisible = true
                        searchStore.send(.updateTrendingKeywordsVisibleState(true))
                    }
                } else {
                    withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                        isNoticeOpened = false
                        isNoticeIconVisible = false
                        isSearchExampleOpened = false
                        isSearchExampleButtonVisible = false
                        searchStore.send(.updateTrendingKeywordsVisibleState(false))
                    }
                }
            }
            .onChange(of: searchStore.firstOpened) {
                if searchStore.firstOpened {
                    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.medium) {
                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                            isNoticeIconVisible = true
                            isSearchExampleButtonVisible = true
                            searchStore.send(.updateTrendingKeywordsVisibleState(true))
                        }
                    }
                }
            }
            .onTapGesture {
                if isNoticeOpened || isSearchExampleOpened {
                    withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                        isNoticeOpened = false
                        isSearchExampleOpened = false
                    }
                } else {
                    focusState = false
                }
            }
            .gesture(
                // custom back handler
                DragGesture(minimumDistance: 3)
                    .onChanged { value in
                        if !appStore.path.ids.isEmpty {
                            dragOffset = value.translation.width
                            
                            if dragOffset > 0 {
                                opacity = max(1 - Double(dragOffset / dragMaxOffset), 0.2)
                            }
                        }
                    }
                    .onEnded { _ in
                        if !appStore.path.ids.isEmpty {
                            if dragOffset > dragMaxOffset {
                                searchStore.send(.pop)
                            }
                            
                            dragOffset = 0
                            
                            withAnimation(.easeOut(duration: 0.5)) {
                                opacity = 1.0
                            }
                        }
                    }
            )
        } // ZStack
        .opacity(opacity)
        .onAppear {
            searchStore.send(.initData)
            
            // test
//            searchStore.send(.initForTest)
            
            if let viewForTest {
                self.searchStore.send(.testSearch(viewForTest: viewForTest))
            }
        }
    }
}

struct PathView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<AppStore.Path>
//    let previousStore: StoreOf<AppStore.Path>?
    let didPop: Bool
    let isCombinedView: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        store: StoreOf<AppStore.Path>,
        didPop: Bool,
        isCombinedView: Bool = false
    ) {
        self.searchStore = searchStore
        self.store = store
        self.didPop = didPop
        self.isCombinedView = isCombinedView
    }
    
    var body: some View {
        switch store.state {
        case .fbPlayerInfo:
            if let s = store.scope(state: \.fbPlayerInfo, action: \.fbPlayerInfo) { FBPlayerInfoView(searchStore: searchStore, store: s, didPop: didPop) }
        case .fbPlayerStats:
            if let s = store.scope(state: \.fbPlayerStats, action: \.fbPlayerStats) { FBPlayerStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .fbPlayerStandings:
            if let s = store.scope(state: \.fbPlayerStandings, action: \.fbPlayerStandings) { FBPlayerStandingsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .fbTeamInfo:
            if let s = store.scope(state: \.fbTeamInfo, action: \.fbTeamInfo) { FBTeamInfoView(searchStore: searchStore, store: s, didPop: didPop) }
        case .fbTeamStats:
            if let s = store.scope(state: \.fbTeamStats, action: \.fbTeamStats) { FBTeamStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .fbTeamStandings:
            if let s = store.scope(state: \.fbTeamStandings, action: \.fbTeamStandings) { FBTeamStandingsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .fbLeagueSchedule:
            if let s = store.scope(state: \.fbLeagueSchedule, action: \.fbLeagueSchedule) { FBLeagueScheduleView(searchStore: searchStore, store: s, didPop: didPop, isCombinedView: isCombinedView) }
        case .fbGameStats:
            if let s = store.scope(state: \.fbGameStats, action: \.fbGameStats) { FBGameStatsView(searchStore: searchStore, store: s, didPop: didPop, isCombinedView: isCombinedView) }
        case .fbTournament:
            if let s = store.scope(state: \.fbTournament, action: \.fbTournament) { FBTournamentView(searchStore: searchStore, store: s, didPop: didPop) }
            
        case .nbaPlayerInfo:
            if let s = store.scope(state: \.nbaPlayerInfo, action: \.nbaPlayerInfo) { NBAPlayerInfoView(searchStore: searchStore, store: s, didPop: didPop) }
        case .nbaPlayerStats:
            if let s = store.scope(state: \.nbaPlayerStats, action: \.nbaPlayerStats) { NBAPlayerStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .nbaPlayerStandings:
            if let s = store.scope(state: \.nbaPlayerStandings, action: \.nbaPlayerStandings) { NBAPlayerStandingsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .nbaTeamInfo:
            if let s = store.scope(state: \.nbaTeamInfo, action: \.nbaTeamInfo) { NBATeamInfoView(searchStore: searchStore, store: s, didPop: didPop) }
        case .nbaTeamStats:
            if let s = store.scope(state: \.nbaTeamStats, action: \.nbaTeamStats) { NBATeamStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .nbaTeamStandings:
            if let s = store.scope(state: \.nbaTeamStandings, action: \.nbaTeamStandings) { NBATeamStandingsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .nbaLeagueSchedule:
            if let s = store.scope(state: \.nbaLeagueSchedule, action: \.nbaLeagueSchedule) { NBALeagueScheduleView(searchStore: searchStore, store: s, didPop: didPop) }
        case .nbaGameStats:
            if let s = store.scope(state: \.nbaGameStats, action: \.nbaGameStats) { NBAGameStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .nbaTournament:
            if let s = store.scope(state: \.nbaTournament, action: \.nbaTournament) { NBATournamentView(searchStore: searchStore, store: s, didPop: didPop) }
            
        case .kboPlayerInfo:
            if let s = store.scope(state: \.kboPlayerInfo, action: \.kboPlayerInfo) { KBOPlayerInfoView(searchStore: searchStore, store: s, didPop: didPop) }
        case .kboPlayerStats:
            if let s = store.scope(state: \.kboPlayerStats, action: \.kboPlayerStats) { KBOPlayerStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .kboTeamInfo:
            if let s = store.scope(state: \.kboTeamInfo, action: \.kboTeamInfo) { KBOTeamInfoView(searchStore: searchStore, store: s, didPop: didPop) }
        case .kboTeamStats:
            if let s = store.scope(state: \.kboTeamStats, action: \.kboTeamStats) { KBOTeamStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .kboTeamStandings:
            if let s = store.scope(state: \.kboTeamStandings, action: \.kboTeamStandings) { KBOTeamStandingsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .kboLeagueSchedule:
            if let s = store.scope(state: \.kboLeagueSchedule, action: \.kboLeagueSchedule) { KBOLeagueScheduleView(searchStore: searchStore, store: s, didPop: didPop) }
        case .kboGameStats:
            if let s = store.scope(state: \.kboGameStats, action: \.kboGameStats) { KBOGameStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .kboTournament:
            if let s = store.scope(state: \.kboTournament, action: \.kboTournament) { KBOTournamentView(searchStore: searchStore, store: s, didPop: didPop) }
            
        case .mlbPlayerInfo:
            if let s = store.scope(state: \.mlbPlayerInfo, action: \.mlbPlayerInfo) { MLBPlayerInfoView(searchStore: searchStore, store: s, didPop: didPop) }
        case .mlbPlayerStats:
            if let s = store.scope(state: \.mlbPlayerStats, action: \.mlbPlayerStats) { MLBPlayerStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .mlbTeamInfo:
            if let s = store.scope(state: \.mlbTeamInfo, action: \.mlbTeamInfo) { MLBTeamInfoView(searchStore: searchStore, store: s, didPop: didPop) }
        case .mlbTeamStats:
            if let s = store.scope(state: \.mlbTeamStats, action: \.mlbTeamStats) { MLBTeamStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .mlbTeamStandings:
            if let s = store.scope(state: \.mlbTeamStandings, action: \.mlbTeamStandings) { MLBTeamStandingsView(searchStore: searchStore, store: s, didPop: didPop) }
        case .mlbLeagueSchedule:
            if let s = store.scope(state: \.mlbLeagueSchedule, action: \.mlbLeagueSchedule) { MLBLeagueScheduleView(searchStore: searchStore, store: s, didPop: didPop) }
        case .mlbGameStats:
            if let s = store.scope(state: \.mlbGameStats, action: \.mlbGameStats) { MLBGameStatsView(searchStore: searchStore, store: s, didPop: didPop) }
        }
    }
}
