//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBAPlayerStandingsStore {
    typealias BaseStandings = BasePlayerStandingsStore<NBAPlayerStandingsDisplayModel>
    
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let itemWidth: CGFloat = 70
        let firstCategoryItemWidth: CGFloat = 132
        let firstCategoryItemHeight: CGFloat = 40
        let secondCategoryItemHeight: CGFloat = 44
        let firstCategoryFontSize: CGFloat = 15
        let secondCategoryFontSize: CGFloat = 14
        let dataFontSize: CGFloat = 15
        let barWidth: CGFloat = 2
        let fetchCategoryIndexList = [5, 8, 11, 21, 23, 24, 26, 27]
        
        /* ---------------------
           data state
           --------------------- */
        let responseModel: NBAPlayerStandingsResponseModel
        var baseStandings: BaseStandings.State
        
        var filteredStandings: [NBAPlayerStandingsDisplay] = []
        var standings: [NBAPlayerStandingsDisplay] = []
        
        init(responseModel: NBAPlayerStandingsResponseModel, displayModel: NBAPlayerStandingsDisplayModel) {
            self.responseModel = responseModel
            self.baseStandings = BaseStandings.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseStandings(BaseStandings.Action)
        
        case showMoreStandings(isUp: Bool)
        case showPlayerStats(id: Int)
        
        /* ---------------------
           private
           --------------------- */
        case filterStandings
        case sortStandings
        case fetchStandings(category: String)
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(data: SportDecodableModel)
        
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
                
                // init data
                state.standings = state.baseStandings.displayModel.standings
                
                return .send(.sortStandings)
                
            case let .baseStandings(.selectCategory(index, category)):
                let previousCategorySelectedIndex = state.baseStandings.categorySelectedIndex
                
                if state.fetchCategoryIndexList.contains(previousCategorySelectedIndex) || state.fetchCategoryIndexList.contains(index) {
                    return .send(.fetchStandings(category: category))
                } else {
                    return .send(.sortStandings)
                }
                
            case .sortStandings:
                switch state.baseStandings.categorySelectedIndex {
                case 0:
                    state.standings.sort { $0.stats.ptsPG > $1.stats.ptsPG }
                case 1:
                    state.standings.sort { $0.stats.astPG > $1.stats.astPG }
                case 2:
                    state.standings.sort { $0.stats.orebPG > $1.stats.orebPG }
                case 3:
                    state.standings.sort { $0.stats.fgaPG > $1.stats.fgaPG }
                case 4:
                    state.standings.sort { $0.stats.fgmPG > $1.stats.fgmPG }
                case 6:
                    state.standings.sort { $0.stats.fg3aPG > $1.stats.fg3aPG }
                case 7:
                    state.standings.sort { $0.stats.fg3mPG > $1.stats.fg3mPG }
                case 9:
                    state.standings.sort { $0.stats.ftaPG > $1.stats.ftaPG }
                case 10:
                    state.standings.sort { $0.stats.ftmPG > $1.stats.ftmPG }
                case 12:
                    state.standings.sort { $0.stats.drebPG > $1.stats.drebPG }
                case 13:
                    state.standings.sort { $0.stats.blkPG > $1.stats.blkPG }
                case 14:
                    state.standings.sort { $0.stats.stlPG > $1.stats.stlPG }
                case 15:
                    state.standings.sort { $0.stats.rebPG > $1.stats.rebPG }
                case 16:
                    state.standings.sort { $0.stats.tovPG > $1.stats.tovPG }
                case 17:
                    state.standings.sort { $0.stats.pfPG > $1.stats.pfPG }
                case 18:
                    state.standings.sort { $0.stats.pfdPG > $1.stats.pfdPG }
                case 19:
                    state.standings.sort { $0.stats.blkaPG > $1.stats.blkaPG }
                case 20:
                    state.standings.sort { $0.stats.plusMinusPG > $1.stats.plusMinusPG }
                case 22:
                    state.standings.sort { CalendarUtil.formatMinuteSecondToSeconds(time: $0.stats.minPG) > CalendarUtil.formatMinuteSecondToSeconds(time: $1.stats.minPG) }
                case 25:
                    state.standings.sort { $0.stats.winsPct > $1.stats.winsPct }
                default:
                    break
                }
                
                return .send(.filterStandings)
                
            case .filterStandings:
                // Get the first entity(player) matching with the standings.(Checking in the order of standings)
                let index = state.standings.firstIndex { player in
                    let entity = state.baseStandings.displayModel.entityInfo.first { $0.playerId == player.player.personId }
                    if entity != nil {
                        state.baseStandings.selectedEntity = entity
                    }
                    return entity != nil
                }
                
                state.baseStandings.entityIndex = index
                
                let rangeSize = 20
                let startIndex = max(0, (index ?? 0) - (rangeSize / 2) + 1) // previous 9 players from entity player
                let endIndex = min(state.standings.count, startIndex + rangeSize - 1) // next 10 players from entity player
                
                let newStandings = Array(state.standings[startIndex...endIndex])
                
                state.baseStandings.filteredStandingsEndIndex = endIndex
                state.baseStandings.filteredStandingsStartIndex = startIndex
                state.filteredStandings = newStandings
                
                return .send(.updateDisplayDataState(fetchState: .success), animation: AnimationConstants.AnimationType.defaultAnimation)
                
            case .showMoreStandings(let isUp):
                let filteredStandingsStartIndex = state.baseStandings.filteredStandingsStartIndex
                let filteredStandingsEndIndex = state.baseStandings.filteredStandingsEndIndex
                
                // get 10 more standings
                if isUp {
                    let newStartIndex = max(0, filteredStandingsStartIndex - 10)
                    
                    if newStartIndex == filteredStandingsStartIndex {
                        return .none
                    }
                    
                    let newStandings = Array(state.standings[newStartIndex...filteredStandingsEndIndex])
                    
                    state.baseStandings.filteredStandingsStartIndex = newStartIndex
                    state.filteredStandings = newStandings
                } else {
                    let newEndIndex = min(state.standings.count - 1, filteredStandingsEndIndex + 10)
                    
                    if newEndIndex == filteredStandingsEndIndex {
                        return .none
                    }
                    
                    let newStandings = Array(state.standings[filteredStandingsStartIndex...newEndIndex])
                    
                    state.baseStandings.filteredStandingsEndIndex = newEndIndex
                    state.filteredStandings = newStandings
                }
                
                return .none
                
            case .fetchStandings(let category):
                return .run { [displayModel = state.baseStandings.displayModel, selectedEntity = state.baseStandings.selectedEntity] send in
                    await send(.updateDisplayDataState(fetchState: .fetching), animation: AnimationConstants.AnimationType.defaultAnimation)
                    
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
                        
                        let result = try await searchClient.fetchDataByKeyword(keyword: keywordInfo, season: displayModel.season)
                        
                        await send(.setDisplayModel(data: result.data))
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case .updateDisplayDataState(let fetchState):
                state.baseStandings.displayDataState = fetchState
                
                return .none
                
            case .setDisplayModel(let data):
                if case let .nbaPlayerStandings(_, displayModel) = data {
                    state.baseStandings.displayModel = displayModel
                    state.standings = displayModel.standings
                    
                    return .send(.sortStandings)
                }
                
                return .none
                
            case let .showPlayerStats(id):
                // NOTE: For now nba player stats data in standings has all the stats, so doesn't has to fetchById like football.
                let player = state.responseModel.standings.first { $0.player.personId == id }
                let responseModel = NBAPlayerInfoResponseModel(info: player, lastGame: nil, nextGame: nil)
                
                let dataModel: SportDecodableModel = .nbaPlayerStats(
                    responseModel,
                    ModelConverter.shared.nbaPlayerStatsConverter(response: responseModel)
                )
                
                return .send(.delegate(.showPlayerStats(model: dataModel)))
                
            case .delegate:
                return .none
            } // switch action
        }
    }
}
