//
//  UserProfileStackStore.swift
//  moare
//
//  Created by 최지혜 on 11/4/25.
//

import ComposableArchitecture

@Reducer
struct UserProfileStackStore {
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case push
        case pop
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .push:
                state.path.append(.userProfile(UserProfileStore.State()))
                return .none
            case .pop:
                if let id = state.path.ids.last {
                    return .send(.path(.element(id: id, action: .userProfile(.goBack))))
                }
                
                if state.path.count > 1 {
                    let _ = state.path.popLast()
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
            case userProfile(UserProfileStore.State)
        }
        
        enum Action {
            case userProfile(UserProfileStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.userProfile, action: \.userProfile) { UserProfileStore() }
        }
    }
}
