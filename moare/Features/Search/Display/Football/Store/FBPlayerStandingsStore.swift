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
    let searchClient = SearchClient()
    
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
        var displayModel: FBPlayerStandingsDisplayModel? = nil
        var displayDataState: ApiFetchState = .idle
        var filteredStandings: [FBPlayerStandingsDisplay] = []
        var league: FBLeague? = nil
        
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
        var standings: [FBPlayerStandingsDisplay] = []
        var selectedEntity: EntityInfo? = nil
        var filteredStandingsEndIndex = 0
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: FBPlayerStandingsDisplayModel)
        
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
        case setDisplayModel(data: SportDecodableModel)
        case updateDisplayDataState(fetchState: ApiFetchState)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.displayModel = nil
                state.displayDataState = .idle
                state.filteredStandings = []
                state.league = nil
                state.firstSelectedIndex = 0
                state.secondSelectedIndex = 0
                state.shouldScrollCategory = false
                state.entityIndex = nil
                state.filteredStandingsStartIndex = 0
                state.standings = []
                state.selectedEntity = nil
                state.filteredStandingsEndIndex = 0
                
                // init data
                state.displayModel = displayModel
                state.standings = displayModel.standings
                state.league = displayModel.standings.first?.stats.league
                
                if let leagueId = displayModel.leagueId {
                    switch leagueId {
                    case Constants.Ids.epl:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.eplPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.eplTeamDic)
                    case Constants.Ids.laliga:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaTeamDic)
                    case Constants.Ids.bundesliga:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                    case Constants.Ids.ligue1:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                    default: break
                    }
                }
                
                let keywords = displayModel.keywords
                
                if !keywords.isEmpty {
                    // Check matching keyword in the order of categories, doesn't matter what keyword is in keywords
                    let index = StringConstants.Football.playerStandingsSecondCategories.firstIndex { category in
                        let keyword = keywords.first { $0.keyword == category }
                        return keyword != nil
                    }
                    
                    if let index = index {
                        state.secondSelectedIndex = index
                    }
                }
                
                return .send(.filterStandings)
                
            case .selectFirstCategory(let index):
                state.shouldScrollCategory = true
                
                var secondCategory = "득점"
                
                // should change secondSelectedIndex first as bar moves based on secondSelectedIndex when firstSelectedIndex changes
                switch index {
                case 0: 
                    state.secondSelectedIndex = 0
                    secondCategory = "득점"
                case 1: 
                    state.secondSelectedIndex = StringConstants.Football.playerStandingsAttackCategories.count
                    secondCategory = "태클 시도"
                case 2:
                    state.secondSelectedIndex = StringConstants.Football.playerStandingsAttackCategories.count + StringConstants.Football.playerStandingsDefendCategories.count
                    secondCategory = "패스 시도"
                default: break
                }
                
                state.firstSelectedIndex = index
                
                return .send(.fetchStandings(category: secondCategory))
                
            case .selectSecondCategory(let index, let category):
                state.shouldScrollCategory = false
                state.secondSelectedIndex = index
                
                switch index {
                case StringConstants.Football.playerStandingsAttackCategories.indices:
                    state.firstSelectedIndex = 0
                case StringConstants.Football.playerStandingsAttackCategories.count..<(StringConstants.Football.playerStandingsAttackCategories.count + StringConstants.Football.playerStandingsDefendCategories.count):
                    state.firstSelectedIndex = 1
                default:
                    state.firstSelectedIndex = 2
                }
                
                return .send(.fetchStandings(category: category))
                
            case .filterStandings:
                // Get the first entity(player) matching with the standings.(Checking in the order of standings)
                let index = state.standings.firstIndex { player in
                    let entity = state.displayModel?.entityInfo.first { $0.playerId == player.player.id }
                    if entity != nil {
                        state.selectedEntity = entity
                    }
                    return entity != nil
                }
                
                guard let index = index else {
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
                
                return .send(.updateDisplayDataState(fetchState: .success))
                
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
                    await send(.updateDisplayDataState(fetchState: .fetching))
                    
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
                        
                        let data = try await searchClient.fetchDataByKeyword(keyword: keywordInfo)
                        
                        await send(.setDisplayModel(data: data.data))
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")))
                        print("\(error)")
                    }
                }
                
            case .setDisplayModel(let data):
                if case let .fbPlayerStandings(_, displayModel) = data {
                    state.displayModel = displayModel
                    state.standings = displayModel.standings
                    
                    return .send(.filterStandings)
                }
                
                return .none
                
            case .updateDisplayDataState(let fetchState):
                withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                    state.displayDataState = fetchState
                }
                
                return .none
                
            case .sortStandings:
                var standings = state.filteredStandings
                
                switch state.secondSelectedIndex {
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
            }
        }
    }
}
