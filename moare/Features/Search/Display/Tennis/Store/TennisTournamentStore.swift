//
//  TennisTournamentStore.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct TennisTournamentStore {
    typealias BaseTournament = BaseTournamentStore<TennisTournamentDisplayModel>
    
    @ObservableState
    struct State {
        var baseTournament: BaseTournament.State
        
        init(displayModel: TennisTournamentDisplayModel) {
            self.baseTournament = BaseTournament.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseTournament(BaseTournament.Action)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseTournament, action: \.baseTournament) { BaseTournament() }
        
        Reduce { state, action in
            switch action {
            case .baseTournament:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
