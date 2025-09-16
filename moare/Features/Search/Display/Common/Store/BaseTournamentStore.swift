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
        var displayModel: T? = nil
        
        var teamNameDictionary: [String: String] = [:]
        var tournamentTeams: [String: [Int]] = [:]
    }
    
    enum Action {
        case initData(displayModel: T)
        case initTournamentTeams([String: [Int]])
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    @Dependency(\.tournamentTeamsClient) var tournamentTeamsClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                
                if let displayModel = displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case let id where Constants.Ids.footballLeagues.contains(id) || Constants.Ids.footballTournamentLeagues.contains(id):
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                    case Constants.Ids.nba:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.nbaTeamDic)
                    case Constants.Ids.kbo:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.kboTeamDic)
                    case Constants.Ids.mlb:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlbTeamDic)
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
