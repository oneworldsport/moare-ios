//
//  BaseTournamentStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/17/25.
//

import ComposableArchitecture

@Reducer
struct BaseTournamentStore<T> {
    @ObservableState
    struct State {
        var displayModel: T
        
        var tournamentTeams: [String: [Int?]] = [:]
        
        var teamNameDic: [String: String] = [:]
        
        init(displayModel: T) {
            self.displayModel = displayModel
        }
    }
    
    enum Action {
        case initData
        case initTournamentTeams([String: [Int?]])
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    @Dependency(\.tournamentTeamsClient) var tournamentTeamsClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                // init with default value
                state.tournamentTeams = [:]
                
                state.teamNameDic = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                
                if let displayModel = state.displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case Constants.Ids.nba:
                        state.teamNameDic = nameProvider.getDictionary(category: Constants.Keys.nbaTeamDic)
                    case Constants.Ids.kbo:
                        state.teamNameDic = nameProvider.getDictionary(category: Constants.Keys.kboTeamDic)
                    case Constants.Ids.mlb:
                        state.teamNameDic = nameProvider.getDictionary(category: Constants.Keys.mlbTeamDic)
                    default: break
                    }
                }
                
                return .run { send in
                    async let tournamentTeams = tournamentTeamsClient.wait()
                    
                    let tournamentTeamsResult = try await tournamentTeams
                    
                    await send(.initTournamentTeams(tournamentTeamsResult))
                }
                
            case .initTournamentTeams(let tournamentTeams):
                state.tournamentTeams = tournamentTeams
                
                return .none
            }
        }
    }
}
