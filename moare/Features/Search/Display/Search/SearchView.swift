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
    
    var viewForTest: SportDisplayType? = nil
    
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
                                // by gpt
                                // STUDY: searchStore.displayModels의 타입인 Dictionary는 순서가 보장되지 않기 때문에, 배열로 변환후 sortOrder를 사용해 정렬 후 view를 그려준다.
                                ForEach(Array(searchStore.displayModels).sorted(by: { $0.key.sortOrder < $1.key.sortOrder }), id: \.key) { type, model in
                                    if type == .kboPlayerStandings {
                                        Text(StringConstants.viewPreparingAdviseText(type: "KBO 선수 순위"))
                                    } else if type == .mlbPlayerStandings {
                                        Text(StringConstants.viewPreparingAdviseText(type: "MLB 선수 순위"))
                                    } else if let builder = viewBuilderMap[type], let model {
                                        builder(model)
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
            
            if let viewForTest = viewForTest {
                self.searchStore?.send(.testSearch(viewForTest: viewForTest))
            }
        }
    }
    
    // NOTE: VStack안에 if let 조건문 너무 많아서 생긴 런타임 에러(EXC_BAD_ACCESS)로 인해 추가. 정확한 원인 및 해결 방법은 더 조사 필요.
    func viewsToRender() -> [AnyView] {
        guard let searchStore else { return [] }
        var views: [AnyView] = []

        for (type, model) in searchStore.displayModels {
            guard let model else { continue }

            if type == .kboPlayerStandings {
                views.append(AnyView(Text(StringConstants.viewPreparingAdviseText(type: "KBO 선수 순위"))))
            } else if type == .mlbPlayerStandings {
                views.append(AnyView(Text(StringConstants.viewPreparingAdviseText(type: "MLB 선수 순위"))))
            } else if let builder = viewBuilderMap[type] {
                views.append(builder(model))
            }
        }

        return views
    }
    
    let viewBuilderMap: [SportDisplayType: (any SportDisplayModel) -> AnyView] = [
        .fbPlayerInfo: { AnyView(FBPlayerInfoView(displayModel: $0 as! FBPlayerInfoDisplayModel)) },
        .fbPlayerStats: { AnyView(FBPlayerStatsView(displayModel: $0 as! FBPlayerStatsDisplayModel)) },
        .fbPlayerStandings: { AnyView(FBPlayerStandingsView(displayModel: $0 as! FBPlayerStandingsDisplayModel)) },
        .fbTeamInfo: { AnyView(FBTeamInfoView(displayModel: $0 as! FBTeamInfoDisplayModel)) },
        .fbTeamStats: { AnyView(FBTeamStatsView(displayModel: $0 as! FBTeamStatsDisplayModel)) },
        .fbTeamStandings: { AnyView(FBTeamStandingsView(displayModel: $0 as! FBTeamStandingsDisplayModel)) },
        .fbLeagueSchedule: { AnyView(FBLeaugeScheduleView(displayModel: $0 as! FBLeagueScheduleDisplayModel)) },
        .fbGameStats: { AnyView(FBGameStatsView(displayModel: $0 as! FBGameStatsDisplayModel)) },
        
            .nbaPlayerInfo: { AnyView(NBAPlayerInfoView(displayModel: $0 as! NBAPlayerInfoDisplayModel)) },
        .nbaPlayerStats: { AnyView(NBAPlayerStatsView(displayModel: $0 as! NBAPlayerStatsDisplayModel)) },
        .nbaPlayerStandings: { AnyView(NBAPlayerStandingsView(displayModel: $0 as! NBAPlayerStandingsDisplayModel)) },
        .nbaTeamInfo: { AnyView(NBATeamInfoView(displayModel: $0 as! NBATeamInfoDisplayModel)) },
        .nbaTeamStats: { AnyView(NBATeamStatsView(displayModel: $0 as! NBATeamStatsDisplayModel)) },
        .nbaTeamStandings: { AnyView(NBATeamStandingsView(displayModel: $0 as! NBATeamStandingsDisplayModel)) },
        .nbaLeagueSchedule: { AnyView(NBALeagueScheduleView(displayModel: $0 as! NBALeagueScheduleDisplayModel)) },
        .nbaGameStats: { AnyView(NBAGameStatsView(displayModel: $0 as! NBAGameStatsDisplayModel)) },
        .nbaLeagueTournament: { AnyView(NBALeagueTournamentView(displayModel: $0 as! NBATournamentDisplayModel)) },
        
            .kboPlayerInfo: { AnyView(KBOPlayerInfoView(displayModel: $0 as! KBOPlayerInfoDisplayModel)) },
        .kboPlayerStats: { AnyView(KBOPlayerStatsView(displayModel: $0 as! KBOPlayerStatsDisplayModel)) },
        .kboTeamInfo: { AnyView(KBOTeamInfoView(displayModel: $0 as! KBOTeamInfoDisplayModel)) },
        .kboTeamStats: { AnyView(KBOTeamStatsView(displayModel: $0 as! KBOTeamStatsDisplayModel)) },
        .kboTeamStandings: { AnyView(KBOTeamStandingsView(displayModel: $0 as! KBOTeamStandingsDisplayModel)) },
        .kboLeagueSchedule: { AnyView(KBOLeagueScheduleView(displayModel: $0 as! KBOLeagueScheduleDisplayModel)) },
        .kboGameStats: { AnyView(KBOGameStatsView(displayModel: $0 as! KBOGameStatsDisplayModel)) },
        
            .mlbPlayerInfo: { AnyView(MLBPlayerInfoView(displayModel: $0 as! MLBPlayerInfoDisplayModel)) },
        .mlbPlayerStats: { AnyView(MLBPlayerStatsView(displayModel: $0 as! MLBPlayerStatsDisplayModel)) },
        .mlbTeamInfo: { AnyView(MLBTeamInfoView(displayModel: $0 as! MLBTeamInfoDisplayModel)) },
        .mlbTeamStats: { AnyView(MLBTeamStatsView(displayModel: $0 as! MLBTeamStatsDisplayModel)) },
        .mlbTeamStandings: { AnyView(MLBTeamStandingsView(displayModel: $0 as! MLBTeamStandingsDisplayModel)) },
        .mlbLeagueSchedule: { AnyView(MLBLeagueScheduleView(displayModel: $0 as! MLBLeagueScheduleDisplayModel)) },
        .mlbGameStats: { AnyView(MLBGameStatsView(displayModel: $0 as! MLBGameStatsDisplayModel)) },
    ]
}
