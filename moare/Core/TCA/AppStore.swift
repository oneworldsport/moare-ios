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
                switch model {
                case .fbPlayerInfo(_, let displayModel):
                    state.path.append(.fbPlayerInfo(FBPlayerInfoStore.State(displayModel: displayModel)))
                case .fbPlayerStats(_, let displayModel):
                    state.path.append(.fbPlayerStats(FBPlayerStatsStore.State(displayModel: displayModel)))
                case .fbPlayerStandings(_, _):
                    state.path.append(.fbPlayerStandings(FBPlayerStandingsStore.State()))
                case .fbTeamInfo(_, let displayModel):
                    state.path.append(.fbTeamInfo(FBTeamInfoStore.State(displayModel: displayModel)))
                case .fbTeamStats(_, let displayModel):
                    state.path.append(.fbTeamStats(FBTeamStatsStore.State(displayModel: displayModel)))
                case .fbTeamStandings(_, _):
                    state.path.append(.fbTeamStandings(FBTeamStandingsStore.State()))
                case .fbLeagueSchedule(_, _):
                    state.path.append(.fbLeagueSchedule(FBLeagueScheduleStore.State()))
                case .fbGameStats(_, _):
                    state.path.append(.fbGameStats(FBGameStatsStore.State()))
                case .fbTournament(_, _):
                    state.path.append(.fbTournament(FBTournamentStore.State()))
                    
                case .nbaPlayerInfo(_, let displayModel):
                    state.path.append(.nbaPlayerInfo(NBAPlayerInfoStore.State(displayModel: displayModel)))
                case .nbaPlayerStats(_, let displayModel):
                    state.path.append(.nbaPlayerStats(NBAPlayerStatsStore.State(displayModel: displayModel)))
                case .nbaPlayerStandings(_, _):
                    state.path.append(.nbaPlayerStandings(NBAPlayerStandingsStore.State()))
                case .nbaTeamInfo(_, let displayModel):
                    state.path.append(.nbaTeamInfo(NBATeamInfoStore.State(displayModel: displayModel)))
                case .nbaTeamStats(_, let displayModel):
                    state.path.append(.nbaTeamStats(NBATeamStatsStore.State(displayModel: displayModel)))
                case .nbaTeamStandings(_, _):
                    state.path.append(.nbaTeamStandings(NBATeamStandingsStore.State()))
                case .nbaLeagueSchedule(_, _):
                    state.path.append(.nbaLeagueSchedule(NBALeagueScheduleStore.State()))
                case .nbaGameStats(_, _):
                    state.path.append(.nbaGameStats(NBAGameStatsStore.State()))
                case .nbaTournament(_, _):
                    state.path.append(.nbaTournament(NBATournamentStore.State()))
                    
                case .kboPlayerInfo(_, let displayModel):
                    state.path.append(.kboPlayerInfo(KBOPlayerInfoStore.State(displayModel: displayModel)))
                case .kboPlayerStats(_, let displayModel):
                    state.path.append(.kboPlayerStats(KBOPlayerStatsStore.State(displayModel: displayModel)))
//                case .kboPlayerStandings(_, _):
//                    state.path.append(.kboPlayerStandings(.State()))
                case .kboTeamInfo(_, let displayModel):
                    state.path.append(.kboTeamInfo(KBOTeamInfoStore.State(displayModel: displayModel)))
                case .kboTeamStats(_, let displayModel):
                    state.path.append(.kboTeamStats(KBOTeamStatsStore.State(displayModel: displayModel)))
                case .kboTeamStandings(_, _):
                    state.path.append(.kboTeamStandings(KBOTeamStandingsStore.State()))
                case .kboLeagueSchedule(_, _):
                    state.path.append(.kboLeagueSchedule(KBOLeagueScheduleStore.State()))
                case .kboGameStats(_, _):
                    state.path.append(.kboGameStats(KBOGameStatsStore.State()))
                case .kboTournament(_, _):
                    state.path.append(.kboTournament(KBOTournamentStore.State()))
                    
                case .mlbPlayerInfo(_, let displayModel):
                    state.path.append(.mlbPlayerInfo(MLBPlayerInfoStore.State(displayModel: displayModel)))
                case .mlbPlayerStats(_, let displayModel):
                    state.path.append(.mlbPlayerStats(MLBPlayerStatsStore.State(displayModel: displayModel)))
//                case .mlbPlayerStandings(_, _):
//                    state.path.append(.mlbPlayerStandings(.State()))
                case .mlbTeamInfo(_, let displayModel):
                    state.path.append(.mlbTeamInfo(MLBTeamInfoStore.State(displayModel: displayModel)))
                case .mlbTeamStats(_, let displayModel):
                    state.path.append(.mlbTeamStats(MLBTeamStatsStore.State(displayModel: displayModel)))
                case .mlbTeamStandings(_, _):
                    state.path.append(.mlbTeamStandings(MLBTeamStandingsStore.State()))
                case .mlbLeagueSchedule(_, _):
                    state.path.append(.mlbLeagueSchedule(MLBLeagueScheduleStore.State()))
                case .mlbGameStats(_, _):
                    state.path.append(.mlbGameStats(MLBGameStatsStore.State()))
                default: break
                }
                
                return .none
                
            case .search(.delegate(.pop)):
                let lastPath = state.path.popLast()
                
                return .send(.search(.popView(lastPath: lastPath, isEmpty: state.path.isEmpty)))
                
            case .search:
                return .none
                
            case .pop:
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
