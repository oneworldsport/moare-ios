//
//  AppStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppStore {
    @ObservableState
    struct State {
        var search = SearchStore.State()
        var path = StackState<Path.State>()
        var queryList: [String] = []
        
        var didPop: Bool = false
        var includesPreviousView: Bool = false
    }
    
    enum Action {
        case search(SearchStore.Action)
        case path(StackActionOf<Path>)
        case pop
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.search, action: \.search) { SearchStore() }
        
        Reduce { state, action in
            switch action {
            case .search(.delegate(.push(let model))):
                return handleRoute(&state, model)
                
            case .pop:
                if !state.search.searchState {
                    if state.path.isEmpty {
                        return .send(.search(.updateTextField("")))
                    } else {
                        // If searchBar is Opened and there are stack, don't pop and show the previous view.
                        return .send(.search(.showPreviousView))
                    }
                } else {
                    state.didPop = true
                    // NOTE: .fbGameStats로 뒤로갔을때(.fbLeagueSchedule -> .fbGameStats인 경우) includesPreviousView가 true여야 하지만 false여도
                    // 그냥 .fbGameStats 화면이 잘 나오기 때문에 상관없음
                    state.includesPreviousView = false
                    
                    let lastPath = state.path.popLast()
                    let poppedQuery = state.queryList.popLast()
                    let lastQuery = state.queryList.last ?? poppedQuery ?? ""
                    
                    return .send(.search(.popView(lastPath: lastPath, isEmpty: state.path.isEmpty, lastQuery: lastQuery)))
                }
                
            case .search:
                return .none
                
            case let .path(.element(id: elementId, action: .fbGameStats(.delegate(.didRefreshGame(model))))):
                if case .fbGameStats(_, let displayModel) = model {
                    // 현재 화면인 .fbGameStats의 이전 화면인 .fbLeagueSchedule을 찾아서 필요한 state를 업데이트 시키고 해당 state를 path에 재배치한다.
                    if let idx = state.path.ids.firstIndex(of: elementId) {
                        for previousId in state.path.ids[..<idx].reversed() {
                            if case .fbLeagueSchedule(var leagueState) = state.path[id: previousId] {
                                leagueState.baseSchedule.displayModel = ModelConverter.fbGameDisplayToLeagueScheduleDisplayConverter(
                                    gameStatsDisplayModel: displayModel,
                                    leagueScheduleDisplayModel: leagueState.baseSchedule.displayModel
                                )
                                leagueState.league = displayModel.game.league
                                state.path[id: previousId] = .fbLeagueSchedule(leagueState)
                                break
                            }
                        }
                    }
                }
                
                return .none
                
            case let .path(.element(id: elementId, action: .nbaGameStats(.delegate(.didRefreshGame(model))))):
                if case .nbaGameStats(_, let displayModel) = model {
                    if let idx = state.path.ids.firstIndex(of: elementId) {
                        for previousId in state.path.ids[..<idx].reversed() {
                            if case .nbaLeagueSchedule(var leagueState) = state.path[id: previousId] {
                                leagueState.baseSchedule.displayModel = ModelConverter.nbaGameDisplayToLeagueScheduleDisplayConverter(
                                    gameStatsDisplayModel: displayModel,
                                    leagueScheduleDisplayModel: leagueState.baseSchedule.displayModel
                                )
                                state.path[id: previousId] = .nbaLeagueSchedule(leagueState)
                                break
                            }
                        }
                    }
                }
                
                return .none
                
            case let .path(.element(id: elementId, action: .mlbGameStats(.delegate(.didRefreshGame(model))))):
                if case .mlbGameStats(_, let displayModel) = model {
                    if let idx = state.path.ids.firstIndex(of: elementId) {
                        for previousId in state.path.ids[..<idx].reversed() {
                            if case .mlbLeagueSchedule(var leagueState) = state.path[id: previousId] {
                                leagueState.baseSchedule.displayModel = ModelConverter.mlbGameDisplayToLeagueScheduleDisplayConverter(
                                    gameStatsDisplayModel: displayModel,
                                    leagueScheduleDisplayModel: leagueState.baseSchedule.displayModel
                                )
                                state.path[id: previousId] = .mlbLeagueSchedule(leagueState)
                                break
                            }
                        }
                    }
                }
                
                return .none
                
            case let .path(.element(id: elementId, action: .kboGameStats(.delegate(.didRefreshGame(model))))):
                if case .kboGameStats(_, let displayModel) = model {
                    if let idx = state.path.ids.firstIndex(of: elementId) {
                        for previousId in state.path.ids[..<idx].reversed() {
                            if case .kboLeagueSchedule(var leagueState) = state.path[id: previousId] {
                                leagueState.baseSchedule.displayModel = ModelConverter.kboGameDisplayToLeagueScheduleDisplayConverter(
                                    gameStatsDisplayModel: displayModel,
                                    leagueScheduleDisplayModel: leagueState.baseSchedule.displayModel
                                )
                                state.path[id: previousId] = .kboLeagueSchedule(leagueState)
                                break
                            }
                        }
                    }
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbPlayerInfo(.delegate(.showPlayerStats(model))))),
                let .path(.element(id: _, action: .fbPlayerStandings(.delegate(.showPlayerStats(model))))),
                let .path(.element(id: _, action: .nbaPlayerInfo(.delegate(.showPlayerStats(model))))),
                let .path(.element(id: _, action: .nbaPlayerStandings(.delegate(.showPlayerStats(model))))),
                let .path(.element(id: _, action: .mlbPlayerInfo(.delegate(.showPlayerStats(model))))),
                let .path(.element(id: _, action: .kboPlayerInfo(.delegate(.showPlayerStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if let route = model.playerStatsRoute {
                    state.path.append(route)
                    state.queryList.append(state.search.query)
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbTeamInfo(.delegate(.showTeamStats(model))))),
                let .path(.element(id: _, action: .fbTeamStandings(.delegate(.showTeamStats(model))))),
                let .path(.element(id: _, action: .nbaTeamInfo(.delegate(.showTeamStats(model))))),
                let .path(.element(id: _, action: .nbaTeamStandings(.delegate(.showTeamStats(model))))),
                let .path(.element(id: _, action: .mlbTeamInfo(.delegate(.showTeamStats(model))))),
                let .path(.element(id: _, action: .mlbTeamStandings(.delegate(.showTeamStats(model))))),
                let .path(.element(id: _, action: .kboTeamInfo(.delegate(.showTeamStats(model))))),
                let .path(.element(id: _, action: .kboTeamStandings(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if let route = model.teamStatsRoute {
                    state.path.append(route)
                    state.queryList.append(state.search.query)
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbPlayerInfo(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .fbTeamInfo(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .fbTournament(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .nbaPlayerInfo(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .nbaTeamInfo(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .nbaLeagueSchedule(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .mlbPlayerInfo(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .mlbTeamInfo(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .mlbLeagueSchedule(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .kboPlayerInfo(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .kboTeamInfo(.delegate(.showGameStats(model))))),
                let .path(.element(id: _, action: .kboLeagueSchedule(.delegate(.showGameStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if let route = model.gameStatsRoute {
                    state.path.append(route)
                    state.queryList.append(state.search.query)
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbLeagueSchedule(.delegate(.showGameStats(model))))):
                state.didPop = false
                // FBLeagueScheduleView에서 아이템 클릭으로 FBGameStatsView보여줄때 state.includesPreviousView = true로 설정해 줘야 함.
                if let pathId = state.path.ids.last {
                    if case .fbLeagueSchedule = state.path[id: pathId] {
                        state.includesPreviousView = true
                    }
                }
                
                if let route = model.gameStatsRoute {
                    state.path.append(route)
                    state.queryList.append(state.search.query)
                }
                
                return .none
            
            case let .path(.element(id: _, action: .fbTournament(.delegate(.showLeagueSchedule(model))))),
                let .path(.element(id: _, action: .nbaTournament(.delegate(.showLeagueSchedule(model))))),
                let .path(.element(id: _, action: .mlbTournament(.delegate(.showLeagueSchedule(model))))),
                let .path(.element(id: _, action: .kboTournament(.delegate(.showLeagueSchedule(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if let route = model.leagueScheduleRoute {
                    state.path.append(route)
                    state.queryList.append(state.search.query)
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbLeagueSchedule(.delegate(.showTournament(model))))),
                let .path(.element(id: _, action: .nbaLeagueSchedule(.delegate(.showTournament(model))))),
                let .path(.element(id: _, action: .mlbLeagueSchedule(.delegate(.showTournament(model))))),
                let .path(.element(id: _, action: .kboLeagueSchedule(.delegate(.showTournament(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if let route = model.tournamentRoute {
                    state.path.append(route)
                    state.queryList.append(state.search.query)
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbLeagueSchedule(.delegate(.showTeamStandings(model))))),
                let .path(.element(id: _, action: .nbaLeagueSchedule(.delegate(.showTeamStandings(model))))),
                let .path(.element(id: _, action: .mlbLeagueSchedule(.delegate(.showTeamStandings(model))))),
                let .path(.element(id: _, action: .kboLeagueSchedule(.delegate(.showTeamStandings(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if let route = model.teamStandingsRoute {
                    state.path.append(route)
                    state.queryList.append(state.search.query)
                }
                
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
    
    @inline(never)
    private func handleRoute(_ state: inout State, _ model: SportDecodableModel) -> Effect<Action> {
        state.didPop = false
        state.includesPreviousView = false
        
        switch model {
        case let .fbPlayerInfo(responseModel, displayModel):
            state.path.append(.fbPlayerInfo(FBPlayerInfoStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .fbPlayerStats(_, let displayModel):
            state.path.append(.fbPlayerStats(FBPlayerStatsStore.State(displayModel: displayModel)))
        case .fbPlayerStandings(_, let displayModel):
            state.path.append(.fbPlayerStandings(FBPlayerStandingsStore.State(displayModel: displayModel)))
        case let .fbTeamInfo(responseModel, displayModel):
            state.path.append(.fbTeamInfo(FBTeamInfoStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .fbTeamStats(_, let displayModel):
            state.path.append(.fbTeamStats(FBTeamStatsStore.State(displayModel: displayModel)))
        case let .fbTeamStandings(responseModel, displayModel):
            state.path.append(.fbTeamStandings(FBTeamStandingsStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .fbLeagueSchedule(_, let displayModel):
            state.path.append(.fbLeagueSchedule(FBLeagueScheduleStore.State(displayModel: displayModel)))
        case .fbGameStats(_, let displayModel):
            state.path.append(.fbGameStats(FBGameStatsStore.State(displayModel: displayModel)))
        case .fbTournament(_, let displayModel):
            state.path.append(.fbTournament(FBTournamentStore.State(displayModel: displayModel)))
            
        case let .nbaPlayerInfo(responseModel, displayModel):
            state.path.append(.nbaPlayerInfo(NBAPlayerInfoStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .nbaPlayerStats(_, let displayModel):
            state.path.append(.nbaPlayerStats(NBAPlayerStatsStore.State(displayModel: displayModel)))
        case let .nbaPlayerStandings(responseModel, displayModel):
            state.path.append(.nbaPlayerStandings(NBAPlayerStandingsStore.State(responseModel: responseModel, displayModel: displayModel)))
        case let .nbaTeamInfo(responseModel, displayModel):
            state.path.append(.nbaTeamInfo(NBATeamInfoStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .nbaTeamStats(_, let displayModel):
            state.path.append(.nbaTeamStats(NBATeamStatsStore.State(displayModel: displayModel)))
        case let .nbaTeamStandings(responseModel, displayModel):
            state.path.append(.nbaTeamStandings(NBATeamStandingsStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .nbaLeagueSchedule(_, let displayModel):
            state.path.append(.nbaLeagueSchedule(NBALeagueScheduleStore.State(displayModel: displayModel)))
        case .nbaGameStats(_, let displayModel):
            state.path.append(.nbaGameStats(NBAGameStatsStore.State(displayModel: displayModel)))
        case .nbaTournament(_, let displayModel):
            state.path.append(.nbaTournament(NBATournamentStore.State(displayModel: displayModel)))
            
        case let .kboPlayerInfo(responseModel, displayModel):
            state.path.append(.kboPlayerInfo(KBOPlayerInfoStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .kboPlayerStats(_, let displayModel):
            state.path.append(.kboPlayerStats(KBOPlayerStatsStore.State(displayModel: displayModel)))
        case let .kboTeamInfo(responseModel, displayModel):
            state.path.append(.kboTeamInfo(KBOTeamInfoStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .kboTeamStats(_, let displayModel):
            state.path.append(.kboTeamStats(KBOTeamStatsStore.State(displayModel: displayModel)))
        case let .kboTeamStandings(responseModel, displayModel):
            state.path.append(.kboTeamStandings(KBOTeamStandingsStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .kboLeagueSchedule(_, let displayModel):
            state.path.append(.kboLeagueSchedule(KBOLeagueScheduleStore.State(displayModel: displayModel)))
        case .kboGameStats(_, let displayModel):
            state.path.append(.kboGameStats(KBOGameStatsStore.State(displayModel: displayModel)))
        case .kboTournament(_, let displayModel):
            state.path.append(.kboTournament(KBOTournamentStore.State(displayModel: displayModel)))
            
        case let .mlbPlayerInfo(responseModel, displayModel):
            state.path.append(.mlbPlayerInfo(MLBPlayerInfoStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .mlbPlayerStats(_, let displayModel):
            state.path.append(.mlbPlayerStats(MLBPlayerStatsStore.State(displayModel: displayModel)))
        case let .mlbTeamInfo(responseModel, displayModel):
            state.path.append(.mlbTeamInfo(MLBTeamInfoStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .mlbTeamStats(_, let displayModel):
            state.path.append(.mlbTeamStats(MLBTeamStatsStore.State(displayModel: displayModel)))
        case let .mlbTeamStandings(responseModel, displayModel):
            state.path.append(.mlbTeamStandings(MLBTeamStandingsStore.State(responseModel: responseModel, displayModel: displayModel)))
        case .mlbLeagueSchedule(_, let displayModel):
            state.path.append(.mlbLeagueSchedule(MLBLeagueScheduleStore.State(displayModel: displayModel)))
        case .mlbGameStats(_, let displayModel):
            state.path.append(.mlbGameStats(MLBGameStatsStore.State(displayModel: displayModel)))
        case .mlbTournament(_, let displayModel):
            state.path.append(.mlbTournament(MLBTournamentStore.State(displayModel: displayModel)))
        default: break
        }
        
        state.queryList.append(state.search.query)
        
        return .none
    }
    
    @Reducer
    struct Path {
        @ObservableState
        enum State {
            // football
            case fbPlayerInfo(FBPlayerInfoStore.State)
            case fbPlayerStats(FBPlayerStatsStore.State)
            case fbPlayerStandings(FBPlayerStandingsStore.State)
            case fbTeamInfo(FBTeamInfoStore.State)
            case fbTeamStats(FBTeamStatsStore.State)
            case fbTeamStandings(FBTeamStandingsStore.State)
            case fbLeagueSchedule(FBLeagueScheduleStore.State)
            case fbGameStats(FBGameStatsStore.State)
            case fbTournament(FBTournamentStore.State)
            
            // nba
            case nbaPlayerInfo(NBAPlayerInfoStore.State)
            case nbaPlayerStats(NBAPlayerStatsStore.State)
            case nbaPlayerStandings(NBAPlayerStandingsStore.State)
            case nbaTeamInfo(NBATeamInfoStore.State)
            case nbaTeamStats(NBATeamStatsStore.State)
            case nbaTeamStandings(NBATeamStandingsStore.State)
            case nbaLeagueSchedule(NBALeagueScheduleStore.State)
            case nbaGameStats(NBAGameStatsStore.State)
            case nbaTournament(NBATournamentStore.State)
            
            // kbo
            case kboPlayerInfo(KBOPlayerInfoStore.State)
            case kboPlayerStats(KBOPlayerStatsStore.State)
//            case kboPlayerStandings()
            case kboTeamInfo(KBOTeamInfoStore.State)
            case kboTeamStats(KBOTeamStatsStore.State)
            case kboTeamStandings(KBOTeamStandingsStore.State)
            case kboLeagueSchedule(KBOLeagueScheduleStore.State)
            case kboGameStats(KBOGameStatsStore.State)
            case kboTournament(KBOTournamentStore.State)
            
            // mlb
            case mlbPlayerInfo(MLBPlayerInfoStore.State)
            case mlbPlayerStats(MLBPlayerStatsStore.State)
//            case mlbPlayerStandings()
            case mlbTeamInfo(MLBTeamInfoStore.State)
            case mlbTeamStats(MLBTeamStatsStore.State)
            case mlbTeamStandings(MLBTeamStandingsStore.State)
            case mlbLeagueSchedule(MLBLeagueScheduleStore.State)
            case mlbGameStats(MLBGameStatsStore.State)
            case mlbTournament(MLBTournamentStore.State)
        }
        
        enum Action {
            // football
            case fbPlayerInfo(FBPlayerInfoStore.Action)
            case fbPlayerStats(FBPlayerStatsStore.Action)
            case fbPlayerStandings(FBPlayerStandingsStore.Action)
            case fbTeamInfo(FBTeamInfoStore.Action)
            case fbTeamStats(FBTeamStatsStore.Action)
            case fbTeamStandings(FBTeamStandingsStore.Action)
            case fbLeagueSchedule(FBLeagueScheduleStore.Action)
            case fbGameStats(FBGameStatsStore.Action)
            case fbTournament(FBTournamentStore.Action)
            
            // nba
            case nbaPlayerInfo(NBAPlayerInfoStore.Action)
            case nbaPlayerStats(NBAPlayerStatsStore.Action)
            case nbaPlayerStandings(NBAPlayerStandingsStore.Action)
            case nbaTeamInfo(NBATeamInfoStore.Action)
            case nbaTeamStats(NBATeamStatsStore.Action)
            case nbaTeamStandings(NBATeamStandingsStore.Action)
            case nbaLeagueSchedule(NBALeagueScheduleStore.Action)
            case nbaGameStats(NBAGameStatsStore.Action)
            case nbaTournament(NBATournamentStore.Action)
            
            // kbo
            case kboPlayerInfo(KBOPlayerInfoStore.Action)
            case kboPlayerStats(KBOPlayerStatsStore.Action)
//            case kboPlayerStandings()
            case kboTeamInfo(KBOTeamInfoStore.Action)
            case kboTeamStats(KBOTeamStatsStore.Action)
            case kboTeamStandings(KBOTeamStandingsStore.Action)
            case kboLeagueSchedule(KBOLeagueScheduleStore.Action)
            case kboGameStats(KBOGameStatsStore.Action)
            case kboTournament(KBOTournamentStore.Action)
            
            // mlb
            case mlbPlayerInfo(MLBPlayerInfoStore.Action)
            case mlbPlayerStats(MLBPlayerStatsStore.Action)
//            case mlbPlayerStandings()
            case mlbTeamInfo(MLBTeamInfoStore.Action)
            case mlbTeamStats(MLBTeamStatsStore.Action)
            case mlbTeamStandings(MLBTeamStandingsStore.Action)
            case mlbLeagueSchedule(MLBLeagueScheduleStore.Action)
            case mlbGameStats(MLBGameStatsStore.Action)
            case mlbTournament(MLBTournamentStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.fbPlayerInfo, action: \.fbPlayerInfo) { FBPlayerInfoStore() }
            Scope(state: \.fbPlayerStats, action: \.fbPlayerStats) { FBPlayerStatsStore() }
            Scope(state: \.fbPlayerStandings, action: \.fbPlayerStandings) { FBPlayerStandingsStore() }
            Scope(state: \.fbTeamInfo, action: \.fbTeamInfo) { FBTeamInfoStore() }
            Scope(state: \.fbTeamStats, action: \.fbTeamStats) { FBTeamStatsStore() }
            Scope(state: \.fbTeamStandings, action: \.fbTeamStandings) { FBTeamStandingsStore() }
            Scope(state: \.fbLeagueSchedule, action: \.fbLeagueSchedule) { FBLeagueScheduleStore() }
            Scope(state: \.fbGameStats, action: \.fbGameStats) { FBGameStatsStore() }
            Scope(state: \.fbTournament, action: \.fbTournament) { FBTournamentStore() }
            Scope(state: \.nbaPlayerInfo, action: \.nbaPlayerInfo) { NBAPlayerInfoStore() }
            Scope(state: \.nbaPlayerStats, action: \.nbaPlayerStats) { NBAPlayerStatsStore() }
            Scope(state: \.nbaPlayerStandings, action: \.nbaPlayerStandings) { NBAPlayerStandingsStore() }
            Scope(state: \.nbaTeamInfo, action: \.nbaTeamInfo) { NBATeamInfoStore() }
            Scope(state: \.nbaTeamStats, action: \.nbaTeamStats) { NBATeamStatsStore() }
            Scope(state: \.nbaTeamStandings, action: \.nbaTeamStandings) { NBATeamStandingsStore() }
            Scope(state: \.nbaLeagueSchedule, action: \.nbaLeagueSchedule) { NBALeagueScheduleStore() }
            Scope(state: \.nbaGameStats, action: \.nbaGameStats) { NBAGameStatsStore() }
            Scope(state: \.nbaTournament, action: \.nbaTournament) { NBATournamentStore() }
            Scope(state: \.kboPlayerInfo, action: \.kboPlayerInfo) { KBOPlayerInfoStore() }
            Scope(state: \.kboPlayerStats, action: \.kboPlayerStats) { KBOPlayerStatsStore() }
            Scope(state: \.kboTeamInfo, action: \.kboTeamInfo) { KBOTeamInfoStore() }
            Scope(state: \.kboTeamStats, action: \.kboTeamStats) { KBOTeamStatsStore() }
            Scope(state: \.kboTeamStandings, action: \.kboTeamStandings) { KBOTeamStandingsStore() }
            Scope(state: \.kboLeagueSchedule, action: \.kboLeagueSchedule) { KBOLeagueScheduleStore() }
            Scope(state: \.kboGameStats, action: \.kboGameStats) { KBOGameStatsStore() }
            Scope(state: \.kboTournament, action: \.kboTournament) { KBOTournamentStore() }
            Scope(state: \.mlbPlayerInfo, action: \.mlbPlayerInfo) { MLBPlayerInfoStore() }
            Scope(state: \.mlbPlayerStats, action: \.mlbPlayerStats) { MLBPlayerStatsStore() }
            Scope(state: \.mlbTeamInfo, action: \.mlbTeamInfo) { MLBTeamInfoStore() }
            Scope(state: \.mlbTeamStats, action: \.mlbTeamStats) { MLBTeamStatsStore() }
            Scope(state: \.mlbTeamStandings, action: \.mlbTeamStandings) { MLBTeamStandingsStore() }
            Scope(state: \.mlbLeagueSchedule, action: \.mlbLeagueSchedule) { MLBLeagueScheduleStore() }
            Scope(state: \.mlbGameStats, action: \.mlbGameStats) { MLBGameStatsStore() }
            Scope(state: \.mlbTournament, action: \.mlbTournament) { MLBTournamentStore() }
        }
    }
}

extension SportDecodableModel {
    var playerStatsRoute: AppStore.Path.State? {
        switch self {
        case let .fbPlayerStats(_, displayModel):  return .fbPlayerStats(.init(displayModel: displayModel))
        case let .nbaPlayerStats(_, displayModel): return .nbaPlayerStats(.init(displayModel: displayModel))
        case let .mlbPlayerStats(_, displayModel): return .mlbPlayerStats(.init(displayModel: displayModel))
        case let .kboPlayerStats(_, displayModel): return .kboPlayerStats(.init(displayModel: displayModel))
        default: return nil
        }
    }
    
    var teamStatsRoute: AppStore.Path.State? {
        switch self {
        case let .fbTeamStats(_, displayModel):  return .fbTeamStats(.init(displayModel: displayModel))
        case let .nbaTeamStats(_, displayModel): return .nbaTeamStats(.init(displayModel: displayModel))
        case let .mlbTeamStats(_, displayModel): return .mlbTeamStats(.init(displayModel: displayModel))
        case let .kboTeamStats(_, displayModel): return .kboTeamStats(.init(displayModel: displayModel))
        default: return nil
        }
    }
    
    var gameStatsRoute: AppStore.Path.State? {
        switch self {
        case let .fbGameStats(_, displayModel):  return .fbGameStats(.init(displayModel: displayModel))
        case let .nbaGameStats(_, displayModel): return .nbaGameStats(.init(displayModel: displayModel))
        case let .mlbGameStats(_, displayModel): return .mlbGameStats(.init(displayModel: displayModel))
        case let .kboGameStats(_, displayModel): return .kboGameStats(.init(displayModel: displayModel))
        default: return nil
        }
    }
    
    var leagueScheduleRoute: AppStore.Path.State? {
        switch self {
        case let .fbLeagueSchedule(_, displayModel):  return .fbLeagueSchedule(.init(displayModel: displayModel))
        case let .nbaLeagueSchedule(_, displayModel): return .nbaLeagueSchedule(.init(displayModel: displayModel))
        case let .mlbLeagueSchedule(_, displayModel): return .mlbLeagueSchedule(.init(displayModel: displayModel))
        case let .kboLeagueSchedule(_, displayModel): return .kboLeagueSchedule(.init(displayModel: displayModel))
        default: return nil
        }
    }
    
    var tournamentRoute: AppStore.Path.State? {
        switch self {
        case let .fbTournament(_, displayModel):  return .fbTournament(.init(displayModel: displayModel))
        case let .nbaTournament(_, displayModel): return .nbaTournament(.init(displayModel: displayModel))
        case let .mlbTournament(_, displayModel): return .mlbTournament(.init(displayModel: displayModel))
        case let .kboTournament(_, displayModel): return .kboTournament(.init(displayModel: displayModel))
        default: return nil
        }
    }
    
    var teamStandingsRoute: AppStore.Path.State? {
        switch self {
        case let .fbTeamStandings(responseModel, displayModel):  return .fbTeamStandings(.init(responseModel: responseModel, displayModel: displayModel))
        case let .nbaTeamStandings(responseModel, displayModel): return .nbaTeamStandings(.init(responseModel: responseModel, displayModel: displayModel))
        case let .mlbTeamStandings(responseModel, displayModel): return .mlbTeamStandings(.init(responseModel: responseModel, displayModel: displayModel))
        case let .kboTeamStandings(responseModel, displayModel): return .kboTeamStandings(.init(responseModel: responseModel, displayModel: displayModel))
        default: return nil
        }
    }
}
