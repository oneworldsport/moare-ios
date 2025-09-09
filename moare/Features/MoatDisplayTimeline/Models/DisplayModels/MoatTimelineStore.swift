//
//  MoatTimelineStore.swift
//  moare
//
//  Created by 최지혜 on 8/29/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MoatTimelineStore {
    
    @ObservableState
    struct State {
        var idToken: String? = nil
        var accessToken: String? = nil
        var refreshToken: String? = nil
        
        var deleteOneTimeOnly: Bool = false
    }
    
    enum Action {
        case deleteOneTimeOnly
        case delete
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .deleteOneTimeOnly:
                guard !state.deleteOneTimeOnly else {
                    return .none
                }
                
                state.deleteOneTimeOnly = true
                
                return .send(.delete)
            case .delete:
                UserDefaults.standard.removeObject(forKey: "idToken")
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                
                return .none
            }
        }
    }
}
