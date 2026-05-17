//
//  FBPlayerStandingsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBPlayerStandingsStore {
    typealias BaseStandings = BasePlayerStandingsStore<FBPlayerStandingsDisplayModel>
    
    @Dependency(\.searchClient) var searchClient
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let categoryItemHeight: CGFloat = 40
        let firstCategoryItemWidth: CGFloat = 132
        let itemWidth: CGFloat = 70
        let barWidth: CGFloat = 2
        let categoryFontSize: CGFloat = 15
        let dataFontSize: CGFloat = 15
        
        /* ---------------------
           data state
           --------------------- */
        var baseStandings: BaseStandings.State
        
        var filteredStandings: [FBPlayerStandingsDisplay] = []
        var league: FBLeague? = nil
        var standings: [FBPlayerStandingsDisplay] = []
        
        init(displayModel: FBPlayerStandingsDisplayModel) {
            self.baseStandings = BaseStandings.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseStandings(BaseStandings.Action)
        
        /* ---------------------
           view action
           --------------------- */
        case showMoreStandings(isUp: Bool)
        case showPlayerStats(id: Int)
        
        /* ---------------------
           private
           --------------------- */
        case filterStandings
        case sortStandings
        case fetchStandings(category: String)
        case setDisplayModel(data: SportDecodableModel)
        case updateDisplayDataState(fetchState: ApiFetchState)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showPlayerStats(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseStandings, action: \.baseStandings) { BaseStandings() }
        
        Reduce { state, action in
            switch action {
            case .baseStandings(.initData):
                // init with default value
                state.filteredStandings = []
                state.league = nil
                state.standings = []
                
                // init data
                state.standings = state.baseStandings.displayModel.standings
                state.league = state.baseStandings.displayModel.standings.first?.stats.league
                
                return .send(.filterStandings)
                
            case let .baseStandings(.selectCategory(_, category)):
                return .send(.fetchStandings(category: category))
                
            case .filterStandings:
                // Get the first entity(player) matching with the standings.(Checking in the order of standings)
                let index = state.standings.firstIndex { player in
                    let entity = state.baseStandings.displayModel.entityInfo.first { $0.playerId == player.player.id }
                    if entity != nil {
                        state.baseStandings.selectedEntity = entity
                    }
                    return entity != nil
                }
                
                guard let index = index else {
                    return .none
                }
                
                state.baseStandings.entityIndex = index
                
                let rangeSize = 20
                let startIndex = max(0, index - (rangeSize / 2) + 1) // previous 9 players from entity player
                let endIndex = min(state.standings.count, startIndex + rangeSize - 1) // next 10 players from entity player
                
                let newStandings = Array(state.standings[startIndex...endIndex])
                
                state.baseStandings.filteredStandingsEndIndex = endIndex
                state.baseStandings.filteredStandingsStartIndex = startIndex
                state.filteredStandings = newStandings
                
                return .send(.updateDisplayDataState(fetchState: .success))
                
            case .showMoreStandings(let isUp):
                // get 10 more standings
                if isUp {
                    let newStartIndex = max(0, state.baseStandings.filteredStandingsStartIndex - 10)
                    
                    if newStartIndex == state.baseStandings.filteredStandingsStartIndex {
                        return .none
                    }
                    
                    let newStandings = Array(state.standings[newStartIndex...state.baseStandings.filteredStandingsEndIndex])
                    
                    state.baseStandings.filteredStandingsStartIndex = newStartIndex
                    state.filteredStandings = newStandings
                } else {
                    let newEndIndex = min(state.standings.count - 1, state.baseStandings.filteredStandingsEndIndex + 10)
                    
                    if newEndIndex == state.baseStandings.filteredStandingsEndIndex {
                        return .none
                    }
                    
                    let newStandings = Array(state.standings[state.baseStandings.filteredStandingsStartIndex...newEndIndex])
                    
                    state.baseStandings.filteredStandingsEndIndex = newEndIndex
                    state.filteredStandings = newStandings
                }
                
                return .none
                
            case .fetchStandings(let category):
                return .run { [displayModel = state.baseStandings.displayModel, selectedEntity = state.baseStandings.selectedEntity] send in
                    await send(.updateDisplayDataState(fetchState: .fetching))
                    
                    do {
                        // TODO: Structure should be updated(Temporary code)
                        let standingsKeyword = displayModel.keywords.first { $0.id == "standings" }
                        let keywords = [standingsKeyword!, Keyword(keyword: category, id: "", priority: 100)]
                        let entities = selectedEntity != nil ? [selectedEntity!] : []
                        let keywordInfo = KeywordInfo(
                            keyword: category,
                            keywords: keywords,
                            entities: entities
                        )
                        
                        let data = try await searchClient.fetchDataByKeyword(keywordInfo, displayModel.season)
                        
                        await send(.setDisplayModel(data: data.data))
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")))
                        print("\(error)")
                    }
                }
                
            case .setDisplayModel(let data):
                if case let .fbPlayerStandings(_, displayModel) = data {
                    state.baseStandings.displayModel = displayModel
                    state.standings = displayModel.standings
                    
                    return .send(.filterStandings)
                }
                
                return .none
                
            case .updateDisplayDataState(let fetchState):
                withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                    state.baseStandings.displayDataState = fetchState
                }
                
                return .none
                
            case .sortStandings:
                var standings = state.filteredStandings
                
                switch state.baseStandings.categorySelectedIndex {
                case 0:
                    standings.sort { $0.stats.goals.total > $1.stats.goals.total }
                case 1:
                    standings.sort { $0.stats.goals.assists > $1.stats.goals.assists }
                case 2:
                    standings.sort { $0.stats.goals.total + $0.stats.goals.assists > $1.stats.goals.total + $1.stats.goals.assists }
                case 3:
                    standings.sort { $0.stats.shots.total > $1.stats.shots.total }
                case 4:
                    standings.sort { $0.stats.shots.on > $1.stats.shots.on }
                case 5:
                    standings.sort { $0.stats.passes.key > $1.stats.passes.key }
                case 6:
                    standings.sort { $0.stats.dribbles.success > $1.stats.dribbles.success }
                case 7:
                    standings.sort { $0.stats.penalty.scored > $1.stats.penalty.scored }
                case 8:
                    standings.sort { $0.stats.tackles.total > $1.stats.tackles.total }
                case 9:
                    standings.sort { $0.stats.duels.won > $1.stats.duels.won }
                case 10:
                    standings.sort { $0.stats.passes.total > $1.stats.passes.total }
                case 11:
                    standings.sort { $0.stats.fouls.committed > $1.stats.fouls.committed }
                case 12:
                    standings.sort { $0.stats.cards.yellow > $1.stats.cards.yellow }
                case 13:
                    standings.sort { $0.stats.cards.red > $1.stats.cards.red }
                case 14:
                    standings.sort { $0.stats.games.appearences > $1.stats.games.appearences }
                case 15:
                    standings.sort { $0.stats.games.lineups > $1.stats.games.lineups }
                case 16:
                    standings.sort { $0.stats.substitutes.substituteIn > $1.stats.substitutes.substituteIn }
                case 17:
                    standings.sort { $0.stats.games.minutes > $1.stats.games.minutes }
                case 18:
                    standings.sort { Double($0.stats.games.rating) ?? 0 > Double($1.stats.games.rating) ?? 0 }
                default:
                    break
                }
                
                state.filteredStandings = Array(standings.prefix(20))
                
                return .none
                
            case let .showPlayerStats(id):
                return .run { [league = state.league, displayModel = state.baseStandings.displayModel] send in
                    let leagueId = league?.id ?? Constants.Ids.epl
                    
                    // TODO: Has to add loading
                    let result = try await searchClient.fetchById(
                        displayModel.season,
                        "football",
                        nil,
                        "football_player_stats",
                        leagueId,
                        String(id)
                    )
                    
                    await send(.delegate(.showPlayerStats(model: result.data)))
//                    let player = responseModel.standings.first { $0.player.id == playerId }
//                    
//                    let playerInfoResponseModel = FBPlayerInfoResponseModel(info: player, lastGame: nil, nextGame: nil)
//                    dataModel = .fbPlayerStats(
//                        playerInfoResponseModel,
//                        modelConverter.fbPlayerStatsConverter(response: playerInfoResponseModel)
//                    )
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
