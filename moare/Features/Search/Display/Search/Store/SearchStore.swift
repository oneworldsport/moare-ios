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
    let searchClient = SearchClient()
    let keywordsClient = KeywordsClient()
    let modelConverter = ModelConverter()
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var searchDataState: ApiFetchState = .idle
        
        // football
        var fbPlayerInfoData: FBPlayerInfoDisplayModel? = nil
        var fbPlayerStatsData: FBPlayerStatsDisplayModel? = nil
        var fbPlayerStandingsData: FBPlayerStandingsDisplayModel? = nil
        var fbTeamInfoData: FBTeamInfoDisplayModel? = nil
        var fbTeamStatsData: FBTeamStatsDisplayModel? = nil
        var fbTeamStandingsData: FBTeamStandingsDisplayModel? = nil
        var fbTeamScheduleData: FBTeamScheduleDisplayModel? = nil
        var fbLeagueScheduleData: FBLeagueScheduleDisplayModel? = nil
        var fbGameStatsData: FBGameStatsDisplayModel? = nil
        
        var initialFBLeagueScheduleData: FBLeagueScheduleDisplayModel? = nil
        var initialNBALeagueScheduleData: NBALeagueScheduleDisplayModel? = nil
        
        // nba
        var nbaPlayerInfoData: NBAPlayerInfoDisplayModel? = nil
        var nbaPlayerStatsData: NBAPlayerStatsDisplayModel? = nil
        var nbaPlayerStandingsData: NBAPlayerStandingsDisplayModel? = nil
        var nbaTeamInfoData: NBATeamInfoDisplayModel? = nil
        var nbaTeamStatsData: NBATeamStatsDisplayModel? = nil
        var nbaTeamStandingsData: NBATeamStandingsDisplayModel? = nil
        var nbaTeamScheduleData: NBATeamScheduleDisplayModel? = nil
        var nbaLeagueScheduleData: NBALeagueScheduleDisplayModel? = nil
        var nbaGameStatsData: NBAGameStatsDisplayModel? = nil
        var nbaLeagueTournamentData: NBALeagueScheduleDisplayModel? = nil
        
        var autoCompleteList: [String] = []
        var trendingKeywordList: [String] = []
        var autoCompleteDataDic: [String: KeywordInfo] = [:]
        
        /* ---------------------
           ui state
           --------------------- */
        var firstOpened = false
        var query = ""
        var searchState = false // NOTE: Has to be animated when changing. SearchBar animation is effected by this property. TODO: Store 개선할때 개선 필요
        var isFocused = false // NOTE: Doesn't have do be synchronized with SearchView's focusState. Because it is only used for updating focusState in .onChange().
        
        // visible state
        var textFieldVisibleState = false
        var resultVisibleState = false
        var trendingKeyowrdsVisibleState = false
        
        /* ---------------------
           etc
           --------------------- */
        var trie: Trie?
        // NOTE: viewStack should always be up to date
        var viewStack: [SportDecodableModel] = []
        var poppedView: SportDecodableModel? = nil
        var trendingKeywords: OrderedDictionary<String, KeywordInfo> = [:]
        var noticeList: [NoticeModel] = []
    }
    
    enum SearchType {
        case query, trendingKeyword, autoComplete
    }
    
    enum Action: BindableAction {
        /* ---------------------
           ui action
           --------------------- */
        case binding(BindingAction<State>)
        case firstOpen
        case toggleSearchBar
        case updateTextField(String, Bool = true)
        case updateTextFieldVisibleState(Bool)
        case performSearch(searchType: SearchType = .query, aniDuration: CGFloat = 0)
        case selectFBGame(game: FBGame)
        case selectNBAGame(game: NBAGame)
        case showPlayerStats(category: String? = nil, playerId: Int)
        case showTeamStats(teamId: Int)
        case showGameStats(gameType: String)
        case updateTrendingKeywordsVisibleState(Bool)
        case refreshGame(category: String)
        case selectNBATournamentRound(gameList: [NBAGame])
        
        /* ---------------------
           api request action
           --------------------- */
        
        /* ---------------------
           private
           --------------------- */
        case searchResultsReceived(DataModel)
        case removeAutoCompleteWithAni
        
        /* ---------------------
           etc
           --------------------- */
        case initData
        case initTrendingKeywords([KeywordInfo])
        case initTrieTuple(trieTuple: (Trie, [KeywordInfo]))
        case initNoticeList([NoticeModel])
        case updateSearchDataState(ApiFetchState)
        case updateIsFocused(Bool)
        case goBack
        case updateAutoCompleteList
        case updateResultVisibleState(bool: Bool)
//        case fetchTrendingKeywords
        case updateMainDisplayModel(data: SportDecodableModel?, shouldReset: Bool = true)
        case updateLastViewStack(data: SportDecodableModel)
        case updateSearchStateWithAni(bool: Bool)
        case addViewStack(data: SportDecodableModel)
        
        /* ---------------------
           test
           --------------------- */
        case initForTest
    }
    
    @Dependency(\.trendingKeywordsClient) var trendingKeywordsClient
    @Dependency(\.trieTupleClient) var trieTupleClient
    @Dependency(\.noticeListClient) var noticeListClient
    
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
                    async let trendingKeywords = trendingKeywordsClient.wait()
                    async let trieTuple = trieTupleClient.wait()
                    async let noticeList = noticeListClient.wait()
                    
                    // NOTE: 아직 완전 병렬은 아님. 완벽하게 병렬로 처리하고 싶으면 각각 따로 .run{}을 실행해 줘야함(.onAppear에서 따로 실행).
                    // 위처럼 완전 병렬로 처리하면 UI에서 각각 따로 반영 되겠지만, 한 UI의 높이가 변경될때 동시에 해당 UI에 영향을 미치는 다른 UI가 그려지면 충돌 가능성이 있을수도 있음.
                    // 하지만 해당 충돌은 이전에 xcode, iOS 버전 업데이트 하기 전에 이상하게(원인불명) 발생했던 오류로 인해 겪었던 것이고, 지금은 발생할지 미지수임.
                    let trendingKeyowrdsResult = try await trendingKeywords
                    let trieTupleResult = try await trieTuple
                    let noticeListResult = try await noticeList
                    
                    await send(.initTrendingKeywords(trendingKeyowrdsResult.keywords))
                    await send(.initTrieTuple(trieTuple: trieTupleResult))
                    await send(.initNoticeList(noticeListResult))
                }
                
            case .initTrieTuple(let trieTuple):
                state.trie = trieTuple.0
                state.autoCompleteDataDic = Dictionary(uniqueKeysWithValues: trieTuple.1.map { ($0.keyword, $0) })
                
                return .none
                
            case .initTrendingKeywords(let keywords):
                state.trendingKeywords = OrderedDictionary(uniqueKeysWithValues: keywords.map { ($0.keyword, $0) })
                state.trendingKeywordList = Array(state.trendingKeywords.keys)
                
                return .none
                
            case .initNoticeList(let noticeList):
                state.noticeList = noticeList
                
                return .none
                
            case .initForTest:
//                state.resultVisibleState = true
                
                return .run { [query = state.query] send in
//                    let data = try await searchClient.fetchDataByQuery(query: "프리미어리그 일정")
//                    await send(.searchResultsReceived(data))
                    
//                    let result = try await trendingKeywordsClient.wait()
                }
                
            case .firstOpen:
                state.firstOpened = true
                return .none
                
//            case .fetchTrendingKeywords:
//                return .run { send in
//                    
//                    do {
//                        let data = try await keywordsClient.fetchTrendingKeywords()
//                        
//                        await send(.setTrendingKeywords(data))
//                    } catch {
//                        print("\(error)")
//                    }
//                }
                
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
                // TODO: temporary logic. Should update logic to adjust weight and filter when collecting words in trie. Not after collecting all words.
//                var result = Set<String>()
//                result.formUnion(state.trie.search(prefix: state.query))
//                result.formUnion(state.trie.search(prefix: getChosung(from: state.query)))
                
                if let trie = state.trie {
                    var result: [String] = []
                 
                    result.append(contentsOf: trie.search(prefix: getChosung(from: state.query)))
                    
                    let additionalResult = trie.search(prefix: state.query)
                    
                    for word in additionalResult {
                        if !result.contains(word) {
                            result.append(word)
                        }
                    }
                    
                    withAnimation {
                        state.autoCompleteList = result
                    }
                }
                
//                var result = [String: Int]()
//                
//                for word in state.trie.search(prefix: state.query) {
//                    result[word] = state.trie.getWeight(for: word)
//                }
//
//                for word in state.trie.search(prefix: getChosung(from: state.query)) {
//                    if result[word] == nil {
//                        result[word] = state.trie.getWeight(for: word)
//                    }
//                }
////
//                withAnimation {
//                    state.autoCompleteList = result.sorted {
//                        if $0.value == $1.value {
//                            return $0.key < $1.key
//                        }
//                        return $0.value > $1.value
//                    }.prefix(10).map { $0.key }
//                }
                
                return .none
                
            case .performSearch(let searchType, let aniDuration):
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    state.searchState = true 
                    
                }
                
                return .run { [query = state.query, keywords = state.trendingKeywords, autoCompleteDataDic = state.autoCompleteDataDic] send in
                    let tracker = TaskCompletionTracker()
                    
                    do {
                        let dataFetchTask = Task {
                            //                        try await Task.sleep(for: .seconds(5)) // delay for test
                            let result: DataModel
                            
                            switch searchType {
                            case .query:
                                result = try await searchClient.fetchDataByQuery(query: query)
                                
                            case .trendingKeyword:
                                if let keyword = keywords[query] {
                                    result = try await searchClient.fetchDataByKeyword(keyword: keyword)
                                } else {
                                    throw NSError(domain: "SearchError", code: 1)
                                }
                                
                            case .autoComplete:
                                if var keywordInfo = autoCompleteDataDic[query] {
                                    keywordInfo.weight = nil // To exclude field "weight" in the request body
                                    result = try await searchClient.fetchDataByKeyword(keyword: keywordInfo)
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
                state.fbPlayerInfoData = nil
                state.fbPlayerStatsData = nil
                state.fbPlayerStandingsData = nil
                state.fbTeamInfoData = nil
                state.fbTeamStatsData = nil
                state.fbTeamStandingsData = nil
                state.fbTeamScheduleData = nil
                state.fbLeagueScheduleData = nil
                state.fbGameStatsData = nil
                
                state.nbaPlayerInfoData = nil
                state.nbaPlayerStatsData = nil
                state.nbaPlayerStandingsData = nil
                state.nbaTeamInfoData = nil
                state.nbaTeamStatsData = nil
                state.nbaTeamStandingsData = nil
                state.nbaTeamScheduleData = nil
                state.nbaLeagueScheduleData = nil
                state.nbaGameStatsData = nil
                state.nbaLeagueTournamentData = nil
                
                switch model.data {
                case .fbPlayerInfo(_, let displayModel):
                    state.fbPlayerInfoData = displayModel
                case .fbPlayerStats(_, let displayModel):
                    state.fbPlayerStatsData = displayModel
                case .fbPlayerStandings(_, let displayModel):
                    state.fbPlayerStandingsData = displayModel
                case .fbTeamInfo(_, let displayModel):
                    state.fbTeamInfoData = displayModel
                case .fbTeamStats(_, let displayModel):
                    state.fbTeamStatsData = displayModel
                case .fbTeamStandings(_, let displayModel):
                    state.fbTeamStandingsData = displayModel
                case .fbTeamSchedule(_, let displayModel):
                    state.fbTeamScheduleData = displayModel
                case .fbLeagueSchedule(_, let displayModel):
                    state.fbLeagueScheduleData = displayModel
                    state.initialFBLeagueScheduleData = displayModel
                case .fbGameStats(_, let displayModel):
                    state.fbGameStatsData = displayModel
                    
                case .nbaPlayerInfo(_, let displayModel):
                    state.nbaPlayerInfoData = displayModel
                case .nbaPlayerStats(_, let displayModel):
                    state.nbaPlayerStatsData = displayModel
                case .nbaPlayerStandings(_, let displayModel):
                    state.nbaPlayerStandingsData = displayModel
                case .nbaTeamInfo(_, let displayModel):
                    state.nbaTeamInfoData = displayModel
                case .nbaTeamStats(_, let displayModel):
                    state.nbaTeamStatsData = displayModel
                case .nbaTeamStandings(_, let displayModel):
                    state.nbaTeamStandingsData = displayModel
                case .nbaTeamSchedule(_, let displayModel):
                    state.nbaTeamScheduleData = displayModel
                case .nbaLeagueSchedule(_, let displayModel):
                    state.nbaLeagueScheduleData = displayModel
                    state.initialNBALeagueScheduleData = displayModel
                case .nbaGameStats(_, let displayModel):
                    state.nbaGameStatsData = displayModel
                case .nbaLeagueTournament(_, let displayModel):
                    state.nbaLeagueTournamentData = displayModel
                    
                default:
                    // TODO: animation is applied by the animation below. Should be modified
                    state.searchDataState = .failure("검색 결과가 없습니다.")
                    return .none
                }
                
                // add viewStack
                // TODO: has to make it as action
                state.viewStack.append(model.data)
                state.poppedView = nil
                
                // NOTE: if apply animation here, it is not applied because of allocating each view's store at onAppear()
                state.resultVisibleState = true
                
                return .none
                
            case .goBack:
                guard !state.viewStack.isEmpty else { return .none }
                
                if !state.searchState {
                    // If searchBar is Opened and there are viewStack, show the lastView.
                    state.textFieldVisibleState = false
                    
                    return .run { send in
                        await send(.updateSearchStateWithAni(bool: true), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                        try await Task.sleep(for: .seconds(0.1)) // NOTE: Due to crash
                        await send(.updateSearchDataState(.success))
                        await send(.updateResultVisibleState(bool: true))
                        await send(.removeAutoCompleteWithAni)
                    }
                } else {
                    // After state.viewStack.popLast(), it ensures triggering onChange(viewStack) after all view is shown in below code.
                    // Maybe because of TCA Reduce feature?
                    let lastView = state.viewStack.popLast()
                    state.poppedView = lastView
                    
                    let viewToShow = state.viewStack.last
                    
                    if let viewToShow = viewToShow {
                        return .run { send in
                            await send(.updateResultVisibleState(bool: false))
                            await send(.updateMainDisplayModel(data: viewToShow))
                            
                            // wait for previous view's removing animation
                            // NOTE: 0.1 for temporary
                            try await Task.sleep(for: .seconds(0.1))
                            
                            await send(.updateResultVisibleState(bool: true))
                        }
                    } else {
                        return .run { send in
                            await send(.updateMainDisplayModel(data: nil))
                            await send(.toggleSearchBar)
                            
//                            try await Task.sleep(for: .seconds(0.5))
                            try await Task.sleep(for: .seconds(AnimationConstants.Duration.medium))
                            
                            await send(.updateTextFieldVisibleState(true))
                            await send(.updateIsFocused(true))
                        }
                    }
                }
                
            case .updateSearchDataState(let dataState):
                withAnimation(.easeOut(duration: 0.5)) {
                    state.searchDataState = dataState
                }
                return .none
                
            case .selectFBGame(let game):
                let dataMdoel = SportDecodableModel.fbGameStats(
                    FBGameStatsReponseModel(game: game),
                    FBGameStatsDisplayModel(game: game)
                )
                
                state.viewStack.append(dataMdoel)
                state.poppedView = nil
                
                state.fbGameStatsData = FBGameStatsDisplayModel(game: game)
                
                return .none
                
            case .selectNBAGame(let game):
                let dataMdoel = SportDecodableModel.nbaGameStats(
                    NBAGameStatsReponseModel(game: game),
                    NBAGameStatsDisplayModel(game: game)
                )
                
                state.viewStack.append(dataMdoel)
                state.poppedView = nil
                
                state.nbaGameStatsData = NBAGameStatsDisplayModel(game: game)
                
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
                
            case .showPlayerStats(let category, let playerId):
                state.resultVisibleState = false
                
                return .run { [viewStack = state.viewStack] send in
                    let dataModel: SportDecodableModel
                    
                    switch viewStack.last {
                    case .fbPlayerStandings(let responseModel, let displayModel):
                        if let category = category {
                            let leagueId = responseModel.standings.first?.statistics.first?.league.id ?? 39
                            
                            // TODO: Has to add loading
                            let result = try await searchClient.fetchById(
                                category: category,
                                dataType: "\(category)_player_stats",
                                leagueId: leagueId,
                                id: String(playerId)
                            )
                            
                            if case .fbPlayerStats = result.data {
                                dataModel = result.data
                            } else {
                                return
                            }
                        } else {
                            let player = responseModel.standings.first { $0.player.id == playerId }
                            
                            let playerInfoResponseModel = FBPlayerInfoResponseModel(info: player, lastGame: nil, nextGame: nil)
                            dataModel = .fbPlayerStats(
                                playerInfoResponseModel,
                                modelConverter.fbPlayerStatsConverter(response: playerInfoResponseModel)
                            )
                        }
                        
                    case .fbPlayerInfo(let responseModel, let displayModel):
                        dataModel = .fbPlayerStats(
                            responseModel,
                            modelConverter.fbPlayerStatsConverter(response: responseModel)
                        )
                        
                    case .nbaPlayerStandings(let responseModel, let displayModel):
                        // NOTE: nba player stats data in standings has all the stats for now, so doesn't has to fetchById like football above.
                        let player = responseModel.standings.first { $0.player.personId == playerId }
                        
                        let playerInfoResponseModel = NBAPlayerInfoResponseModel(info: player, lastGame: nil, nextGame: nil)
                        dataModel = .nbaPlayerStats(
                            playerInfoResponseModel,
                            modelConverter.nbaPlayerStatsConverter(response: playerInfoResponseModel)
                        )
                        
                    case .nbaPlayerInfo(let responseModel, let displayModel):
                        dataModel = .nbaPlayerStats(
                            responseModel,
                            modelConverter.nbaPlayerStatsConverter(response: responseModel)
                        )
                        
                    default: return // Make it do nothing
                    }
                    
                    
                    await send(.updateMainDisplayModel(data: dataModel))
                    await send(.addViewStack(data: dataModel))
                    
                    // wait for before view's removing animation
                    // NOTE: 0.1 for temporary
                    try await Task.sleep(for: .seconds(0.1))
                    
                    await send(.updateResultVisibleState(bool: true))
                }
                
            case .showTeamStats(let teamId):
                let dataModel: SportDecodableModel
                
                switch state.viewStack.last {
                case .fbTeamStandings(let responseModel, let displayModel):
                    let team = responseModel.standings.first { $0.team.id == teamId }
                    
                    let teamInfoResponseModel = FBTeamInfoResponseModel(info: team, lastGame: nil, nextGame: nil)
                    dataModel = .fbTeamStats(
                        teamInfoResponseModel,
                        modelConverter.fbTeamStatsConverter(response: teamInfoResponseModel)
                    )
                    
                case .fbTeamInfo(let responseModel, let displayModel):
                    dataModel = .fbTeamStats(
                        responseModel,
                        modelConverter.fbTeamStatsConverter(response: responseModel)
                    )
                    
                case .nbaTeamStandings(let responseModel, let displayModel):
                    let team = responseModel.standings.first { $0.team.id == teamId }
                    
                    let teamInfoResponseModel = NBATeamInfoResponseModel(info: team, lastGame: nil, nextGame: nil)
                    dataModel = .nbaTeamStats(
                        teamInfoResponseModel,
                        modelConverter.nbaTeamStatsConverter(response: teamInfoResponseModel)
                    )
                    
                case .nbaTeamInfo(let responseModel, let displayModel):
                    dataModel = .nbaTeamStats(
                        responseModel,
                        modelConverter.nbaTeamStatsConverter(response: responseModel)
                    )
                    
                default: return .none // Make it do nothing
                }
                
                state.resultVisibleState = false
                
                return .run { send in
                    await send(.updateMainDisplayModel(data: dataModel))
                    await send(.addViewStack(data: dataModel))
                    
                    // wait for before view's removing animation
                    // NOTE: 0.1 for temporary
                    try await Task.sleep(for: .seconds(0.1))
                    
                    await send(.updateResultVisibleState(bool: true))
                }
                
            case .showGameStats(let gameType):
                let dataModel: SportDecodableModel
                
                switch state.viewStack.last {
                case .fbPlayerInfo(let responseModel, let displayModel):
                    let gameStatsResponseModel = gameType == "previous" ? FBGameStatsReponseModel(game: responseModel.lastGame) : FBGameStatsReponseModel(game: responseModel.nextGame)
                    
                    dataModel = .fbGameStats(
                        gameStatsResponseModel,
                        modelConverter.fbGameStatsConverter(response: gameStatsResponseModel)
                    )
                    
                case .fbTeamInfo(let responseModel, let displayModel):
                    let gameStatsResponseModel = gameType == "previous" ? FBGameStatsReponseModel(game: responseModel.lastGame) : FBGameStatsReponseModel(game: responseModel.nextGame)
                    
                    dataModel = .fbGameStats(
                        gameStatsResponseModel,
                        modelConverter.fbGameStatsConverter(response: gameStatsResponseModel)
                    )
                    
                case .nbaPlayerInfo(let responseModel, let displayModel):
                    let gameStatsResponseModel = gameType == "previous" ? NBAGameStatsReponseModel(game: responseModel.lastGame) : NBAGameStatsReponseModel(game: responseModel.nextGame)
                    
                    dataModel = .nbaGameStats(
                        gameStatsResponseModel,
                        modelConverter.nbaGameStatsConverter(response: gameStatsResponseModel)
                    )
                    
                case .nbaTeamInfo(let responseModel, let displayModel):
                    let gameStatsResponseModel = gameType == "previous" ? NBAGameStatsReponseModel(game: responseModel.lastGame) : NBAGameStatsReponseModel(game: responseModel.nextGame)
                    
                    dataModel = .nbaGameStats(
                        gameStatsResponseModel,
                        modelConverter.nbaGameStatsConverter(response: gameStatsResponseModel)
                    )
                    
                default: return .none // Make it do nothing
                }
                
                state.resultVisibleState = false
                
                return .run { send in
                    await send(.updateMainDisplayModel(data: dataModel))
                    await send(.addViewStack(data: dataModel))
                    
                    // wait for before view's removing animation
                    // NOTE: 0.1 for temporary
                    try await Task.sleep(for: .seconds(0.1))
                    
                    await send(.updateResultVisibleState(bool: true))
                }
                
            case .refreshGame(let category):
                return .run { [viewStack = state.viewStack, fbGameStatsData = state.fbGameStatsData, nbaGameStatsData = state.nbaGameStatsData] send in
                    switch viewStack.last {
                    case .fbGameStats(let responseModel, let displayModel):
                        if let game = fbGameStatsData?.game {
                            let result = try await searchClient.fetchById(
                                category: category,
                                date: game.fixture.date,
                                dataType: "\(category)_game_stats",
                                leagueId: game.league.id,
                                id: String(game.fixture.id)
                            )
                            
                            await send(.updateMainDisplayModel(data: result.data, shouldReset: false))
                            await send(.updateLastViewStack(data: result.data))
                        }
                        
                    case .nbaGameStats(let responseModel, let displayModel):
                        if let gameSummary = nbaGameStatsData?.game.gameSummary,
                           let boxScoreTraditional = nbaGameStatsData?.game.boxScoreTraditional {
                            let result = try await searchClient.fetchById(
                                category: category,
                                date: gameSummary.date,
                                dataType: "\(category)_game_stats",
                                leagueId: 90001,
                                id: boxScoreTraditional.gameId
                            )
                            
                            await send(.updateMainDisplayModel(data: result.data, shouldReset: false))
                            await send(.updateLastViewStack(data: result.data))
                        }
                        
                    default: return // Make it do nothing
                    }
                }
                
            case .selectNBATournamentRound(let gameList):
                let dataModel: SportDecodableModel
                
                switch state.viewStack.last {
                case .nbaLeagueTournament(let responseModel, let displayModel):
                    let teamScheduleResponseModel = NBAGameScheduleResponseModel(scheduledMonths: nil, schedule: gameList)
                    
                    dataModel = .nbaTeamSchedule(
                        teamScheduleResponseModel,
                        modelConverter.nbaTeamScheduleConverter(response: teamScheduleResponseModel)
                    )
                    
                default: return .none // Make it do nothing
                }
                
                state.resultVisibleState = false
                
                return .run { send in
                    await send(.updateMainDisplayModel(data: dataModel))
                    await send(.addViewStack(data: dataModel))
                    
                    // wait for before view's removing animation
                    // NOTE: 0.1 for temporary
                    try await Task.sleep(for: .seconds(0.1))
                    
                    await send(.updateResultVisibleState(bool: true))
                }
                
            case .updateMainDisplayModel(let data, let shouldReset):
                if shouldReset {
                    state.fbPlayerInfoData = nil
                    state.fbPlayerStatsData = nil
                    state.fbPlayerStandingsData = nil
                    state.fbTeamInfoData = nil
                    state.fbTeamStatsData = nil
                    state.fbTeamStandingsData = nil
                    state.fbTeamScheduleData = nil
                    state.fbLeagueScheduleData = nil
                    state.fbGameStatsData = nil
                    
                    state.nbaPlayerInfoData = nil
                    state.nbaPlayerStatsData = nil
                    state.nbaPlayerStandingsData = nil
                    state.nbaTeamInfoData = nil
                    state.nbaTeamStatsData = nil
                    state.nbaTeamStandingsData = nil
                    state.nbaTeamScheduleData = nil
                    state.nbaLeagueScheduleData = nil
                    state.nbaGameStatsData = nil
                    state.nbaLeagueTournamentData = nil
                }
                
                switch data {
                case .fbPlayerInfo(let responseModel, let displayModel):
                    state.fbPlayerInfoData = displayModel
                case .fbPlayerStats(_, let displayModel):
                    state.fbPlayerStatsData = displayModel
                case .fbPlayerStandings(_, let displayModel):
                    state.fbPlayerStandingsData = displayModel
                case .fbTeamInfo(let responseModel, let displayModel):
                    state.fbTeamInfoData = displayModel
                case .fbTeamStats(_, let displayModel):
                    state.fbTeamStatsData = displayModel
                case .fbTeamStandings(_, let displayModel):
                    state.fbTeamStandingsData = displayModel
                case .fbTeamSchedule(_, let displayModel):
                    state.fbTeamScheduleData = displayModel
                case .fbLeagueSchedule(_, let displayModel):
                    state.fbLeagueScheduleData = displayModel
                case .fbGameStats(_, let displayModel):
                    state.fbGameStatsData = displayModel
                    
                case .nbaPlayerInfo(_, let displayModel):
                    state.nbaPlayerInfoData = displayModel
                case .nbaPlayerStats(_, let displayModel):
                    state.nbaPlayerStatsData = displayModel
                case .nbaPlayerStandings(_, let displayModel):
                    state.nbaPlayerStandingsData = displayModel
                case .nbaTeamInfo(_, let displayModel):
                    state.nbaTeamInfoData = displayModel
                case .nbaTeamStats(_, let displayModel):
                    state.nbaTeamStatsData = displayModel
                case .nbaTeamStandings(_, let displayModel):
                    state.nbaTeamStandingsData = displayModel
                case .nbaTeamSchedule(_, let displayModel):
                    state.nbaTeamScheduleData = displayModel
                case .nbaLeagueSchedule(_, let displayModel):
                    state.nbaLeagueScheduleData = displayModel
                case .nbaGameStats(_, let displayModel):
                    state.nbaGameStatsData = displayModel
                case .nbaLeagueTournament(_, let displayModel):
                    state.nbaLeagueTournamentData = displayModel
                    
                default:
                    break
                }
                
                return .none
                
            case .updateLastViewStack(let data):
                var newViewStack = state.viewStack
                newViewStack.popLast()
                newViewStack.append(data)
                state.viewStack = newViewStack
                
                return .none
                
            case .updateSearchStateWithAni(let bool):
//                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    state.searchState = bool
//                }
                
                return .none
                
            case .addViewStack(let data):
                state.viewStack.append(data)
                state.poppedView = nil
                
                return .none
            }
        }
    }
}
