//
//  SearchDataStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/4/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Collections

@Reducer
struct SearchStore {
    let modelConverter = ModelConverter.shared
    
    @Dependency(\.trendingKeywordsClient) var trendingKeywordsClient
    @Dependency(\.autoCompleteClient) var autoCompleteClient
    @Dependency(\.noticeListClient) var noticeListClient
    
    @Dependency(\.searchClient) var searchClient
    @Dependency(\.keywordsClient) var keywordsClient
    
    @Dependency(\.continuousClock) var clock
    
    @ObservableState
    struct State: Equatable {
        /* ---------------------
           data state
           --------------------- */
        var searchDataState: ApiFetchState = .idle
        
        var autoCompleteList: [String] = []
        var trendingKeywordList: [String] = []
        var leagueKeywords: LeagueKeywords? = nil
        
        /* ---------------------
           ui state
           --------------------- */
        var firstOpened = false
        var query = ""
        var searchState = false // NOTE: Has to be animated when changing. SearchBar animation is effected by this property. TODO: Store 개선할때 개선 필요
        var isFocused: Bool? = nil // NOTE: Doesn't have do be synchronized with SearchView's focusState. Because it is only used for updating focusState in .onChange().
        
        // visible state
        var textFieldVisibleState = false
        var resultVisibleState = false
        var trendingKeyowrdsVisibleState = false
        
        var noticeList: [NoticeModel] = []
        var searchExample = ""
    }
    
    enum SearchType {
        case query, trendingKeyword, autoComplete
        case leagueKeyword(KeywordInfo)
    }
    
    enum Action: BindableAction {
        /* ---------------------
           ui action
           --------------------- */
        case binding(BindingAction<State>) // TODO: State가 모두 바뀔때마다 실행되는건가..? 그럼 query만 binding되게 해야하나?
        case firstOpen
        case toggleSearchBar
        case updateTextField(String, Bool = true)
        case updateTextFieldVisibleState(Bool)
        case performSearch(searchType: SearchType = .query, aniDuration: CGFloat = 0)
        case getLeagueKeywords
        case getLeagueKeywordsSuccess(LeagueKeywords)
        
        case updateTrendingKeywordsVisibleState(Bool)
        
        /* ---------------------
           private
           --------------------- */
        case searchResultsReceived(DataModel)
        case removeAutoCompleteWithAni
        
        /* ---------------------
           etc
           --------------------- */
        case initData
        case initTrendingKeywords([String])
        case initNoticeList([NoticeModel])
        case updateSearchDataState(ApiFetchState)
        case updateIsFocused(Bool?)
        case updateAutoCompleteList
        case updateAutoCompleteListResponse([String])
        case updateResultVisibleState(bool: Bool)

        case updateSearchStateWithAni(bool: Bool)
        
        case showPreviousView
        case popView(lastPath: AppStore.Path.State?, isEmpty: Bool, lastQuery: String)
        case delegate(Delegate)
    }
    
    enum Delegate {
        case push(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.query):
                let isBlank = state.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                
                if isBlank {
                    state.autoCompleteList.removeAll()
                } else {
                    return .run { send in
                        await send(.updateAutoCompleteList)
                    }
                }
                
                return .none
                
            case .binding:
                return .none
                
            case .initData:
                return .run { send in
                    async let keywords = trendingKeywordsClient.load()
                    async let noticeList = noticeListClient.wait()
                    
                    // NOTE: 아직 완전 병렬은 아님. 완벽하게 병렬로 처리하고 싶으면 각각 따로 .run{}을 실행해 줘야함(.onAppear에서 따로 실행).
                    // 위처럼 완전 병렬로 처리하면 UI에서 각각 따로 반영 되겠지만, 한 UI의 높이가 변경될때 동시에 해당 UI에 영향을 미치는 다른 UI가 그려지면 충돌 가능성이 있을수도 있음.
                    // 하지만 해당 충돌은 이전에 xcode, iOS 버전 업데이트 하기 전에 이상하게(원인불명) 발생했던 오류로 인해 겪었던 것이고, 지금은 발생할지 미지수임.
                    // - 셋중 하나만 exception 발생하면 셋다 초기화 안되는 문제 있음.
                    let keywordsResult = try await keywords
                    let noticeListResult = try await noticeList
                    try await autoCompleteClient.load()
                    
                    await send(.initTrendingKeywords(keywordsResult))
                    await send(.initNoticeList(noticeListResult))
                    
                    await send(.getLeagueKeywords)
                }
                
            case .initTrendingKeywords(let keywords):
                state.trendingKeywordList = keywords
                
                return .none
                
            case .initNoticeList(let noticeList):
                state.searchExample = noticeList.first { $0.title == "검색 예시" }?.content ?? ""
                state.noticeList = noticeList.filter { $0.title != "검색 예시" }
                
                return .none
                
            case .firstOpen:
                state.firstOpened = true
                return .none
                
            case .updateTrendingKeywordsVisibleState(let bool):
                // RECORD: Crash occured when animation applied at .onChange to other view and also animation applied hear.
                // So it resolved by applying animation together at .onChange.
                // NOTE: Has to figure out not to change state at the same time in .onChange and store as possible that effect the ui.
//                withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                    state.trendingKeyowrdsVisibleState = bool
//                }
                
                return .none
                
            case .toggleSearchBar:
                if state.searchState {
                    withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                        state.searchState = false
                    }
                    
                    return .run { [query = state.query] send in
                        await send(.updateResultVisibleState(bool: false))
                        await send(.updateSearchDataState(.idle))
                        await send(.updateTextField(query))
                    }
                }
                
                return .none
                
            case .updateTextField(let query, let updateAutoCompleteList):
                state.query = query
                
                if updateAutoCompleteList {
                    // TODO: make it to extension
                    let isBlank = state.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    
                    if isBlank {
                        state.autoCompleteList.removeAll()
                    } else {
                        return .run { send in
                            await send(.updateAutoCompleteList)
                        }
                    }
                }

                return .none
                
            case .updateTextFieldVisibleState(let bool):
                state.textFieldVisibleState = bool
                return .none
                
            case .updateAutoCompleteList:
                return .run { [query = state.query] send in
                    let result = try await autoCompleteClient.search(query)
                    await send(.updateAutoCompleteListResponse(result))
                }
                
            case .updateAutoCompleteListResponse(let autoCompleteList):
                withAnimation {
                    state.autoCompleteList = autoCompleteList
                }
                
                return .none
                
            case .performSearch(let searchType, let aniDuration):
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    state.searchState = true 
                    
                }
                
                return .run { [query = state.query] send in
                    let tracker = TaskCompletionTracker()
                    
                    do {
                        let dataFetchTask = Task {
                            //                        try await Task.sleep(for: .seconds(5)) // delay for test
                            let result: DataModel
                            
                            switch searchType {
                            case .query:
                                result = try await searchClient.fetchDataByQuery(query)
                                
                            case .trendingKeyword:
                                if let keyword = try await trendingKeywordsClient.keywordInfo(query) {
                                    result = try await searchClient.fetchDataByKeyword(keyword, nil)
                                } else {
                                    throw NSError(domain: "SearchError", code: 1)
                                }
                                
                            case .leagueKeyword(let keyword):
                                result = try await searchClient.fetchDataByKeyword(keyword, nil)
                                
                            case .autoComplete:
                                if var keywordInfo = try await autoCompleteClient.keywordInfo(query) {
                                    keywordInfo.weight = nil // To exclude field "weight" in the request body
                                    result = try await searchClient.fetchDataByKeyword(keywordInfo, nil)
                                } else {
                                    throw NSError(domain: "SearchError", code: 1)
                                }
                            }
                            
                            await tracker.markCompleted()
                            return result
                        }
                        
                        try await Task.sleep(for: .seconds(aniDuration))
                        
                        let isCompleted = await tracker.getStatus()
                        
                        if !isCompleted {
                            await send(.updateSearchDataState(.fetching))
                        }
                        
                        let data = try await dataFetchTask.value
                        
                        await send(.updateSearchDataState(.success))
                        
                        await send(.searchResultsReceived(data))
                    } catch {
                        print("\(error)")
                        await send(.updateSearchDataState(.failure("검색 결과가 없습니다.")))
                    }
                }
                                
            case let .searchResultsReceived(model):
                switch model.data {
                case .fbPlayerInfo, .fbPlayerStats, .fbPlayerStandings,
                        .fbTeamInfo, .fbTeamStats, .fbTeamStandings,
                        .fbLeagueSchedule, .fbGameStats, .fbTournament,
                        .nbaPlayerInfo, .nbaPlayerStats, .nbaPlayerStandings,
                        .nbaTeamInfo, .nbaTeamStats, .nbaTeamStandings,
                        .nbaLeagueSchedule, .nbaGameStats, .nbaTournament,
                        .kboPlayerInfo, .kboPlayerStats, .kboPlayerStandings,
                        .kboTeamInfo, .kboTeamStats, .kboTeamStandings,
                        .kboLeagueSchedule, .kboGameStats, .kboTournament,
                        .mlbPlayerInfo, .mlbPlayerStats, .mlbPlayerStandings,
                        .mlbTeamInfo, .mlbTeamStats, .mlbTeamStandings,
                        .mlbLeagueSchedule, .mlbGameStats, .mlbTournament,
                        .tennisLeagueSchedule, .tennisGameStats, .tennisTournament: break
                default:
                    // TODO: animation is applied by the animation below. Should be modified
                    // TODO: 여기서 안하고 AppStore에서 하게 개선 필요
                    state.searchDataState = .failure("검색 결과가 없습니다.")
                    return .none
                }
                
                // NOTE: if apply animation here, it is not applied because of allocating each view's store at onAppear()
                state.resultVisibleState = true
                
                return .send(.delegate(.push(model: model.data)))
                
            case .showPreviousView:
                state.textFieldVisibleState = false
                
                return .run { send in
                    await send(.updateSearchStateWithAni(bool: true), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                    try await Task.sleep(for: .seconds(0.1)) // NOTE: Due to crash
                    await send(.updateSearchDataState(.success))
                    await send(.updateResultVisibleState(bool: true))
                    await send(.removeAutoCompleteWithAni)
                }
                
            case let .popView(lastPath, isEmpty, lastQuery):
                guard lastPath != nil else { return .none } // TODO: 지우기
                
                if isEmpty {
                    return .run { send in
                        await send(.updateTextField(lastQuery, false)) // NOTE: 어짜피 toggleSearchBar에서 updateTextField(query)해줘서 여기서는 두번째 인자를 false로 보냄.
                        await send(.toggleSearchBar)
                        
                        //                            try await Task.sleep(for: .seconds(0.5))
                        try await Task.sleep(for: .seconds(AnimationConstants.Duration.medium))
                        
                        await send(.updateTextFieldVisibleState(true))
                        await send(.updateIsFocused(true))
                    }
                } else {
                    return .send(.updateTextField(lastQuery, false))
                }
                
//                if !state.searchState {
//                } else {
//                        return .run { [poppedView = state.poppedView] send in
//                            await send(.updateResultVisibleState(bool: false))
//                            await send(.updateMainDisplayModel(data: viewToShow))
//                            // wait for previous view's removing animation
//                            // NOTE: 0.1 for temporary
//                            try await Task.sleep(for: .seconds(0.1))
//                            
//                            await send(.updateResultVisibleState(bool: true))
//                        }
//                    } else {
//                        return .run { send in
//                            await send(.updateMainDisplayModel(data: nil))
//                            await send(.toggleSearchBar)
//                            
//                            //                            try await Task.sleep(for: .seconds(0.5))
//                            try await Task.sleep(for: .seconds(AnimationConstants.Duration.medium))
//                            
//                            await send(.updateTextFieldVisibleState(true))
//                            await send(.updateIsFocused(true))
//                        }
//                    }
//                }
                
            case .getLeagueKeywords:
                return .run { send in
                    do {
                        let result = try await keywordsClient.fetchLeagueKeywords()
                        
                        // 처음 magnifyingglass 나타나는 시간 0.5 + firstOpen 애니메이션 시간 0.7 + trendingKeyowrds 나타나는 시간 0.5 + 추가 0.1 = 1.8초 지연
                        try await clock.sleep(for: .seconds(1.8))
                        
                        await send(.getLeagueKeywordsSuccess(result), animation: AnimationConstants.AnimationType.defaultAnimation)
                    } catch {
                    }
                }
                
            case .getLeagueKeywordsSuccess(let keywords):
                state.leagueKeywords = keywords
                return .none
                
            case .updateSearchDataState(let dataState):
                withAnimation(.easeOut(duration: 0.5)) {
                    state.searchDataState = dataState
                }
                return .none
                
            case .updateIsFocused(let bool):
                state.isFocused = bool
                
                return .none
                
            case .removeAutoCompleteWithAni:
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    state.autoCompleteList.removeAll()
                }
                
                return .none
                
            case .updateResultVisibleState(let bool):
                if bool {
                    // NOTE: If apply animation here, it is not applied because of initializing store at each view in .onAppear().
                    // So animation is applied when initializing store at each view.
                    state.resultVisibleState = bool
                } else {
                    withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                        state.resultVisibleState = bool
                    }
                }
                
                return .none
                
            case .updateSearchStateWithAni(let bool):
//                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    state.searchState = bool
//                }
                
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
