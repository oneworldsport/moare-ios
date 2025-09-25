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
        
        var didPop: Bool = false
        var includesPreviousView: Bool = false
    }
    
    enum Action {
        case search(SearchStore.Action)
        case path(StackActionOf<Path>)
        case pop
//        case show(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.search, action: \.search) { SearchStore() }
        
        Reduce { state, action in
            switch action {
            case .search(.delegate(.push(let model))):
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
                    // TODO: 이전 화면이 fbLeagueSchedule일때만
                    state.includesPreviousView = true
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
//                case .kboPlayerStandings(_, _):
//                    state.path.append(.kboPlayerStandings(.State()))
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
//                case .mlbPlayerStandings(_, _):
//                    state.path.append(.mlbPlayerStandings(.State()))
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
                default: break
                }
                
                return .none
                
            case let .search(.delegate(.pop(searchState))):
                // If searchBar is Opened and there are stack, don't pop and show the previous view.
                if !searchState {
                    return .none
                } else {
                    state.didPop = true
                    // TODO: 이전 화면이 fbLeagueSchedule일때는 true
                    state.includesPreviousView = false
                    
                    let lastPath = state.path.popLast()
                    
                    return .send(.search(.popView(lastPath: lastPath, isEmpty: state.path.isEmpty)))
                }
                
            case .search:
                return .none
                
            case .pop:
                return .none
                
            case let .path(.element(id: elementId, action: .fbGameStats(.delegate(.didRefreshGame(model))))):
                if case .fbGameStats(_, let displayModel) = model {
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
                
            case let .path(.element(id: _, action: .fbPlayerInfo(.delegate(.showPlayerStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .fbPlayerStats(_, let displayModel) = model {
                    state.path.append(.fbPlayerStats(FBPlayerStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbPlayerStandings(.delegate(.showPlayerStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .fbPlayerStats(_, let displayModel) = model {
                    state.path.append(.fbPlayerStats(FBPlayerStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbTeamInfo(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .fbTeamStats(_, let displayModel) = model {
                    state.path.append(.fbTeamStats(FBTeamStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .fbTeamStandings(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .fbTeamStats(_, let displayModel) = model {
                    state.path.append(.fbTeamStats(FBTeamStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .nbaPlayerInfo(.delegate(.showPlayerStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .nbaPlayerStats(_, let displayModel) = model {
                    state.path.append(.nbaPlayerStats(NBAPlayerStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .nbaPlayerStandings(.delegate(.showPlayerStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .nbaPlayerStats(_, let displayModel) = model {
                    state.path.append(.nbaPlayerStats(NBAPlayerStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .nbaTeamInfo(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .nbaTeamStats(_, let displayModel) = model {
                    state.path.append(.nbaTeamStats(NBATeamStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .nbaTeamStandings(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .nbaTeamStats(_, let displayModel) = model {
                    state.path.append(.nbaTeamStats(NBATeamStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .mlbPlayerInfo(.delegate(.showPlayerStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .mlbPlayerStats(_, let displayModel) = model {
                    state.path.append(.mlbPlayerStats(MLBPlayerStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .mlbTeamInfo(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .mlbTeamStats(_, let displayModel) = model {
                    state.path.append(.mlbTeamStats(MLBTeamStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .mlbTeamStandings(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .mlbTeamStats(_, let displayModel) = model {
                    state.path.append(.mlbTeamStats(MLBTeamStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .kboPlayerInfo(.delegate(.showPlayerStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .kboPlayerStats(_, let displayModel) = model {
                    state.path.append(.kboPlayerStats(KBOPlayerStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .kboTeamInfo(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .kboTeamStats(_, let displayModel) = model {
                    state.path.append(.kboTeamStats(KBOTeamStatsStore.State(displayModel: displayModel)))
                }
                
                return .none
                
            case let .path(.element(id: _, action: .kboTeamStandings(.delegate(.showTeamStats(model))))):
                state.didPop = false
                state.includesPreviousView = false
                
                if case .kboTeamStats(_, let displayModel) = model {
                    state.path.append(.kboTeamStats(KBOTeamStatsStore.State(displayModel: displayModel)))
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
        }
    }
}
