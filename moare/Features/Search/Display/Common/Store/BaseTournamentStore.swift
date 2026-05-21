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
        case initNameDictionary([String: String])
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
                
                return .run { [displayModel = state.displayModel] send in
                    async let tournamentTeams = tournamentTeamsClient.wait()
                    
                    let tournamentTeamsResult = try await tournamentTeams
                    
                    var dic = await nameProvider.getDictionary(Constants.Keys.footballTeamDic)
                    
                    if let displayModel = displayModel as? SportDisplayModel {
                        switch displayModel.leagueId {
                        case Constants.Ids.nba:
                            dic = await nameProvider.getDictionary(Constants.Keys.nbaTeamDic)
                        case Constants.Ids.kbo:
                            dic = await nameProvider.getDictionary(Constants.Keys.kboTeamDic)
                        case Constants.Ids.mlb:
                            dic = await nameProvider.getDictionary(Constants.Keys.mlbTeamDic)
                        default: break
                        }
                    }
                    
                    await send(.initNameDictionary(dic))
                    await send(.initTournamentTeams(tournamentTeamsResult))
                }
                
            case .initNameDictionary(let dic):
                state.teamNameDic = dic
                return .none
                
            case .initTournamentTeams(let tournamentTeams):
                state.tournamentTeams = tournamentTeams
                
                return .none
            }
        }
    }
}
