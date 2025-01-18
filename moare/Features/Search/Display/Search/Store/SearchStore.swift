//
//  SearchDataStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/4/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import AWSTranslate

@Reducer
struct SearchStore {
    let searchClient = SearchClient()
    let modelConverter = ModelConverter()
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var searchDataState: SearchDataState = .idle
        
        var fbPlayerInfoData: FBPlayerInfoDisplayModel? = nil
        var fbPlayerStatsData: FBPlayerStatsDisplayModel? = nil
        var fbPlayerStandingsData: FBPlayerStandingsDisplayModel? = nil
        var fbTeamInfoData: FBTeamInfoDisplayModel? = nil
        var fbTeamStatsData: FBTeamStatsDisplayModel? = nil
        var fbTeamStandingsData: FBTeamStandingsDisplayModel? = nil
        var fbTeamScheduleData: FBTeamScheduleDisplayModel? = nil
        var fbLeagueScheduleData: FBLeagueScheduleDisplayModel? = nil
        var fbGameStatsData: FBGameStatsDisplayModel? = nil
        
        var fbPlayerInfoResponseModel: FBPlayerInfoResponseModel? = nil
        var fbTeamInfoResponseModel: FBTeamInfoResponseModel? = nil
        
        var autoCompleteList: [String] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var query = ""
        var searchState = false
        var isFocused = false
        
        // visible state
        var textFieldVisibleState = false
        var resultVisibleState = false
        
        /* ---------------------
           etc
           --------------------- */
        let trie = Trie()
        var viewStack: [SportDecodableModel] = []
    }
    
    enum Action {
        /* ---------------------
           ui action
           --------------------- */
        case toggleSearchBar
        case updateTextField(String, Bool = true)
        case updateTextFieldVisibleState(Bool)
        case performSearch(CGFloat = 0)
        case selectFBGame(FBGame)
        case showPlayerStats(Int)
        case showTeamStats(Int)
        case showGameStats(Bool)
        
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
        case initTrie
        case updateSearchDataState(SearchDataState)
        case translate(String, (Result<String, Error>) -> Void)
        case updateIsFocused(Bool)
        case goBack
        case updateAutoCompleteList
        case updateResultVisibleState
        
        /* ---------------------
           test
           --------------------- */
        case initForTest
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initTrie:
                return .run { [trie = state.trie] send in
                    do {
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let savedFileURL = documentsDirectory.appendingPathComponent("autocomplete.json")
                        
                        if FileManager.default.fileExists(atPath: savedFileURL.path) {
                            let data = try Data(contentsOf: savedFileURL)
                            
                            let autoCompleteData = try JSONDecoder().decode([AutoComplete].self, from: data)
                            
                            for autoComplete in autoCompleteData {
                                trie.insert(word: autoComplete.word)
                                trie.insert(word: getChosung(from: autoComplete.word), originalWord: autoComplete.word, weight: autoComplete.weight)
                            }
                        }
                    } catch {
                        print("\(error)")
                    }
                }
                
            case .initForTest:
                state.resultVisibleState = true
                
                return .run { [query = state.query] send in
                    let data = try await searchClient.fetchDataByQuery(query: "프리미어리그 일정")
                    await send(.searchResultsReceived(data))
                }
                
            case .toggleSearchBar:
                if state.searchState {
                    withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                        state.searchState = false
                        state.resultVisibleState = false
                    }
                    
                    return .run { [query = state.query] send in
                        await send(.updateSearchDataState(.idle))
                        await send(.updateTextField(query))
                    }
                } else {
                    withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                        state.searchState = true
                    }
                    
                    return .none
                }
                
            case .updateTextField(let query, let updateAutoCompleteList):
                state.query = query
                
                if updateAutoCompleteList {
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
                
                var result: [String] = []
                result.append(contentsOf: state.trie.search(prefix: getChosung(from: state.query)))
                
                let searchResult = state.trie.search(prefix: state.query)
                
                for word in searchResult {
                    if !result.contains(word) {
                        result.append(word)
                    }
                }
                
                withAnimation {
                    state.autoCompleteList = result
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
                
            case .performSearch(let aniDuration):
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    state.searchState = true 
                    
                }
                
                return .run { [query = state.query] send in
                    let tracker = TaskCompletionTracker()
                    
                    do {
                        let dataFetchTask = Task {
                            //                        try await Task.sleep(for: .seconds(5)) // delay for test
                            let result = try await searchClient.fetchDataByQuery(query: query)
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
                
                switch model.data {
                case .fbPlayerInfo(let responseModel, let displayModel):
                    state.fbPlayerInfoData = displayModel
                    state.fbPlayerInfoResponseModel = responseModel
                case .fbPlayerStats(_, let data):
                    state.fbPlayerStatsData = data
                case .fbPlayerStandings(_, let data):
                    state.fbPlayerStandingsData = data
                case .fbTeamInfo(let responseModel, let displayModel):
                    state.fbTeamInfoData = displayModel
                    state.fbTeamInfoResponseModel = responseModel
                case .fbTeamStats(_, let data):
                    state.fbTeamStatsData = data
                case .fbTeamStandings(_, let data):
                    state.fbTeamStandingsData = data
                case .fbTeamSchedule(_, let data):
                    state.fbTeamScheduleData = data
                case .fbLeagueSchedule(_, let data):
                    state.fbLeagueScheduleData = data
                case .fbGameStats(_, let data):
                    state.fbGameStatsData = data
                default:
                    // TODO: animation is applied by the animation below. Should be modified
                    state.searchDataState = .failure("검색 결과가 없습니다.")
                    return .none
                }
                
                // add viewStack
                state.viewStack.append(model.data)
                
                // NOTE: if apply animation here, it is not applied because of allocating each view's store at onAppear()
                state.resultVisibleState = true
                
                return .none
                
            case .goBack:
                guard !state.viewStack.isEmpty else { return .none }
                
                let lastView = state.viewStack.popLast()
                let viewToShow = state.viewStack.last
                
//                withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                    state.resultVisibleState = false
//                }
                
                if let viewToShow = viewToShow {
                    state.fbPlayerInfoData = nil
                    state.fbPlayerStatsData = nil
                    state.fbPlayerStandingsData = nil
                    state.fbTeamInfoData = nil
                    state.fbTeamStatsData = nil
                    state.fbTeamStandingsData = nil
                    state.fbTeamScheduleData = nil
                    state.fbLeagueScheduleData = nil
                    state.fbGameStatsData = nil
                    
                    switch viewToShow {
                    case .fbPlayerInfo(let responseModel, let displayModel):
                        state.fbPlayerInfoData = displayModel
                        state.fbPlayerInfoResponseModel = responseModel
                    case .fbPlayerStats(_, let displayModel):
                        state.fbPlayerStatsData = displayModel
                    case .fbPlayerStandings(_, let displayModel):
                        state.fbPlayerStandingsData = displayModel
                    case .fbTeamInfo(let responseModel, let displayModel):
                        state.fbTeamInfoData = displayModel
                        state.fbTeamInfoResponseModel = responseModel
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
                    default:
                        break
                    }
                    
                    return .run { send in
                        // wait for before view's removing animation
                        // NOTE: 0.1 for temporary
                        try await Task.sleep(for: .seconds(0.1))
                        
                        await send(.updateResultVisibleState)
                    }
                } else {
                    return .run { send in
                        await send(.toggleSearchBar)
                        
                        try await Task.sleep(for: .seconds(0.5))
                        
                        await send(.updateTextFieldVisibleState(true))
                        await send(.updateIsFocused(true))
                    }
                }
                
            case .updateSearchDataState(let dataState):
                withAnimation(.easeOut(duration: 0.5)) {
                    state.searchDataState = dataState
                }
                return .none
                
            case .translate(let text, let onResult):
                return .run { send in
                    let translateClient = AWSTranslate(forKey: "TranslateClient")
                    let request = AWSTranslateTranslateTextRequest()!
                    request.text = text
                    request.sourceLanguageCode = "en"
                    request.targetLanguageCode = "ko"
                    
                    translateClient.translateText(request) { response, error in
                        if let translatedText = response?.translatedText {
                            onResult(.success(translatedText))
                        }
                    }
                }
                
            case .selectFBGame(let game):
                state.fbGameStatsData = FBGameStatsDisplayModel(game: game)
                
                let dataMdoel = SportDecodableModel.fbGameStats(
                    FBGameStatsReponseModel(stats: game),
                    FBGameStatsDisplayModel(game: game)
                )
                
                state.viewStack.append(dataMdoel)
                
                return .none
                
            case .updateIsFocused(let bool):
                state.isFocused = bool
                
                return .none
                
            case .removeAutoCompleteWithAni:
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    state.autoCompleteList.removeAll()
                }
                
                return .none
                
            case .updateResultVisibleState:
//                withAnimation(.easeOut(duration: 0.5)) {
                    state.resultVisibleState = true
//                }
                
                return .none
                
            case .showPlayerStats(let _):
                guard let playerInfoResponseModel = state.fbPlayerInfoResponseModel else { return .none }
                
                let stats = modelConverter.fbPlayerStatsConverter(response: playerInfoResponseModel)
                
                state.resultVisibleState = false
                
                state.fbPlayerInfoData = nil
                state.fbPlayerStatsData = stats
                state.fbPlayerStandingsData = nil
                state.fbTeamInfoData = nil
                state.fbTeamStatsData = nil
                state.fbTeamStandingsData = nil
                state.fbTeamScheduleData = nil
                state.fbLeagueScheduleData = nil
                state.fbGameStatsData = nil
                
                // TODO: can use viewStack
                let dataModel = SportDecodableModel.fbPlayerStats(playerInfoResponseModel, stats)
                
                state.viewStack.append(dataModel)
                
                return .run { send in
                    // wait for before view's removing animation
                    // NOTE: 0.1 for temporary
                    try await Task.sleep(for: .seconds(0.1))
                    
                    await send(.updateResultVisibleState)
                }
                
            case .showTeamStats(let teamId):
                var teamInfoResponseModel: FBTeamInfoResponseModel? = nil
                var stats: FBTeamStatsDisplayModel? = nil
                
                let viewToShow = state.viewStack.last!
                
                if case .fbTeamStandings(let fBTeamStandingsResponseModel, _) = viewToShow {
                    let team = fBTeamStandingsResponseModel.standings.first { $0.team.id == teamId }
                    
                    teamInfoResponseModel = FBTeamInfoResponseModel(info: team, lastGame: nil, nextGame: nil)
                    
                    stats = modelConverter.fbTeamStatsConverter(response: teamInfoResponseModel!)
                } else {
                    teamInfoResponseModel = state.fbTeamInfoResponseModel
                    stats = modelConverter.fbTeamStatsConverter(response: state.fbTeamInfoResponseModel!)
                }
                
                state.resultVisibleState = false
                
                state.fbPlayerInfoData = nil
                state.fbPlayerStatsData = nil
                state.fbPlayerStandingsData = nil
                state.fbTeamInfoData = nil
                state.fbTeamStatsData = stats
                state.fbTeamStandingsData = nil
                state.fbTeamScheduleData = nil
                state.fbLeagueScheduleData = nil
                state.fbGameStatsData = nil
                
                // TODO: can use viewStack
                let dataModel = SportDecodableModel.fbTeamStats(teamInfoResponseModel!, stats!)
                
                state.viewStack.append(dataModel)
                
                return .run { send in
                    // wait for before view's removing animation
                    // NOTE: 0.1 for temporary
                    try await Task.sleep(for: .seconds(0.1))
                    
                    await send(.updateResultVisibleState)
                }
                
            case .showGameStats(let isPrevious):
                var gameStatsResponseModel: FBGameStatsReponseModel? = nil
                var stats: FBGameStatsDisplayModel? = nil
                
                let viewToShow = state.viewStack.last!
                if case .fbPlayerInfo(let fbPlayerInfoResponseModel, _) = viewToShow {
                    if isPrevious {
                        gameStatsResponseModel = FBGameStatsReponseModel(stats: fbPlayerInfoResponseModel.lastGame)
                    } else {
                        gameStatsResponseModel = FBGameStatsReponseModel(stats: fbPlayerInfoResponseModel.nextGame)
                    }
                    
                    stats = modelConverter.fbGameStatsConverter(response: gameStatsResponseModel!)
                } else if case .fbTeamInfo(let fBTeamInfoResponseModel, let _) = viewToShow {
                    if isPrevious {
                        gameStatsResponseModel = FBGameStatsReponseModel(stats: fBTeamInfoResponseModel.lastGame)
                    } else {
                        gameStatsResponseModel = FBGameStatsReponseModel(stats: fBTeamInfoResponseModel.nextGame)
                    }
                    
                    stats = modelConverter.fbGameStatsConverter(response: gameStatsResponseModel!)
                }
                
                state.resultVisibleState = false
                
                state.fbPlayerInfoData = nil
                state.fbPlayerStatsData = nil
                state.fbPlayerStandingsData = nil
                state.fbTeamInfoData = nil
                state.fbTeamStatsData = nil
                state.fbTeamStandingsData = nil
                state.fbTeamScheduleData = nil
                state.fbLeagueScheduleData = nil
                state.fbGameStatsData = stats
                
                // TODO: can use viewStack
                let dataModel = SportDecodableModel.fbGameStats(gameStatsResponseModel!, stats!)
                
                state.viewStack.append(dataModel)
                
                return .run { send in
                    // wait for before view's removing animation
                    // NOTE: 0.1 for temporary
                    try await Task.sleep(for: .seconds(0.1))
                    
                    await send(.updateResultVisibleState)
                }

            }
        }
    }
}
