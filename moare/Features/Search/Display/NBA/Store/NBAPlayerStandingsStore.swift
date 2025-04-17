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
        var displayModel: NBAPlayerStandingsDisplayModel? = nil
        var displayDataState: ApiFetchState = .idle
        var filteredStandings: [NBAPlayerStandingsDisplay] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var firstSelectedIndex = 0
        var secondSelectedIndex = 0
        var shouldScrollCategory = false
        var entityIndex: Int? = nil
        var filteredStandingsStartIndex = 0
        
        /* ---------------------
           etc
           --------------------- */
        var standings: [NBAPlayerStandingsDisplay] = []
        var selectedEntity: EntityInfo? = nil
        var filteredStandingsEndIndex = 0
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: NBAPlayerStandingsDisplayModel)
        
        /* ---------------------
           view action
           --------------------- */
        case selectFirstCategory(index: Int)
        case selectSecondCategory(index: Int, category: String)
        case showMoreStandings(isUp: Bool)
        
        /* ---------------------
           private
           --------------------- */
        case filterStandings
        case sortStandings
        case fetchStandings(category: String)
        
        // TODO: feature가 있어 따로 나눌 수 있을 듯 함
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(data: SportDecodableModel)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.displayDataState = .idle
                state.filteredStandings = []
                state.firstSelectedIndex = 0
                state.secondSelectedIndex = 0
                state.shouldScrollCategory = false
                state.entityIndex = nil
                state.filteredStandingsStartIndex = 0
                state.selectedEntity = nil
                state.filteredStandingsEndIndex = 0
                
                // init data
                state.displayModel = displayModel
                state.standings = displayModel.standings
                
                state.playerNameDictionary = nameProvider.getDictionary(category: "nba_player")
                state.teamNameDictionary = nameProvider.getDictionary(category: "nba_team")
                
                let keywords = displayModel.keywords
                if !keywords.isEmpty {
                    // Check matching keyword in the order of categories, doesn't matter what keyword is in keywords
                    let index = StringConstants.NBA.playerStandingsSecondCategories.firstIndex { category in
                        let keyword = keywords.first { $0.keyword == category }
                        return keyword != nil
                    }
                    
                    if let index {
                        state.secondSelectedIndex = index
                    }
                }
                
                return .send(.sortStandings)
                
            case .selectFirstCategory(let index):
                let beforeSecondSelectedIndex = state.secondSelectedIndex
                
                state.shouldScrollCategory = true
                
                let attackCategoriesSize = StringConstants.NBA.playerStandingsAttackCategories.count
                let defendCategoriesSize = StringConstants.NBA.playerStandingsDefendCategories.count
                
                switch index {
                case 0:
                    state.secondSelectedIndex = 0
                case 1:
                    state.secondSelectedIndex = attackCategoriesSize
                case 2:
                    state.secondSelectedIndex = attackCategoriesSize + defendCategoriesSize
                default: break
                }
                
                state.firstSelectedIndex = index
                
                if state.fetchCategoryIndexList.contains(beforeSecondSelectedIndex) {
                    return .send(.fetchStandings(category: "득점"))
                } else {
                    return .send(.sortStandings)
                }
                
            case .selectSecondCategory(let index, let category):
                let beforeSecondSelectedIndex = state.secondSelectedIndex
                
                state.shouldScrollCategory = false
                state.secondSelectedIndex = index
                
                let attackCategories = StringConstants.NBA.playerStandingsAttackCategories
                let defendCategories = StringConstants.NBA.playerStandingsDefendCategories
                
                switch index {
                case attackCategories.indices:
                    state.firstSelectedIndex = 0
                case attackCategories.count..<(attackCategories.count + defendCategories.count):
                    state.firstSelectedIndex = 1
                default:
                    state.firstSelectedIndex = 2
                }
                
                if state.fetchCategoryIndexList.contains(beforeSecondSelectedIndex) || state.fetchCategoryIndexList.contains(index) {
                    return .send(.fetchStandings(category: category))
                } else {
                    return .send(.sortStandings)
                }
                
            case .sortStandings:
                switch state.secondSelectedIndex {
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
                    state.standings.sort { CalendarUtil.formatHourMinuteToMinutes(time: $0.stats.minPG) > CalendarUtil.formatHourMinuteToMinutes(time: $1.stats.minPG) }
                case 25:
                    state.standings.sort { $0.stats.winsPct > $1.stats.winsPct }
                default:
                    break
                }
                
                return .send(.filterStandings)
                
            case .filterStandings:
                // Get the first entity(player) matching with the standings.(Checking in the order of standings)
                let index = state.standings.firstIndex { player in
                    let entity = state.displayModel?.entityInfo.first { $0.playerId == player.player.personId }
                    if entity != nil {
                        state.selectedEntity = entity
                    }
                    return entity != nil
                }
                
                guard let index else {
                    return .none
                }
                
                state.entityIndex = index
                
                let rangeSize = 20
                let startIndex = max(0, index - (rangeSize / 2) + 1) // previous 9 players from entity player
                let endIndex = min(state.standings.count, startIndex + rangeSize - 1) // next 10 players from entity player
                
                let newStandings = Array(state.standings[startIndex...endIndex])
                
                state.filteredStandingsEndIndex = endIndex
                state.filteredStandingsStartIndex = startIndex
                state.filteredStandings = newStandings
                
                return .send(.updateDisplayDataState(fetchState: .success), animation: AnimationConstants.AnimationType.defaultAnimation)
                
            case .showMoreStandings(let isUp):
                // get 10 more standings
                if isUp {
                    let newStartIndex = max(0, state.filteredStandingsStartIndex - 10)
                    
                    if newStartIndex == state.filteredStandingsStartIndex {
                        return .none
                    }
                    
                    let newStandings = Array(state.standings[newStartIndex...state.filteredStandingsEndIndex])
                    
                    state.filteredStandingsStartIndex = newStartIndex
                    state.filteredStandings = newStandings
                } else {
                    let newEndIndex = min(state.standings.count - 1, state.filteredStandingsEndIndex + 10)
                    
                    if newEndIndex == state.filteredStandingsEndIndex {
                        return .none
                    }
                    
                    let newStandings = Array(state.standings[state.filteredStandingsStartIndex...newEndIndex])
                    
                    state.filteredStandingsEndIndex = newEndIndex
                    state.filteredStandings = newStandings
                }
                
                return .none
                
            case .fetchStandings(let category):
                return .run { [displayModel = state.displayModel, selectedEntity = state.selectedEntity] send in
                    await send(.updateDisplayDataState(fetchState: .fetching), animation: AnimationConstants.AnimationType.defaultAnimation)
                    
                    do {
                        // TODO: Structure should be updated(Temporary code)
                        let standingsKeyword = displayModel?.keywords.first { $0.id == "standings" }
                        let keywords = [standingsKeyword!, Keyword(keyword: category, id: "", priority: 100)]
                        let entities = selectedEntity != nil ? [selectedEntity!] : []
                        let keywordInfo = KeywordInfo(
                            keyword: category,
                            keywords: keywords,
                            entities: entities
                        )
                        
                        let result = try await searchClient.fetchDataByKeyword(keyword: keywordInfo)
                        
                        await send(.setDisplayModel(data: result.data))
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case .updateDisplayDataState(let fetchState):
                state.displayDataState = fetchState
                
                return .none
                
            case .setDisplayModel(let data):
                if case let .nbaPlayerStandings(_, displayModel) = data {
                    state.displayModel = displayModel
                    state.standings = displayModel.standings
                    
                    return .send(.sortStandings)
                }
                
                return .none
            } // switch action
        }
    }
}
