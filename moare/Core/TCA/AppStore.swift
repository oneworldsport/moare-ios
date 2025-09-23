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
        case show(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.search, action: \.search) { SearchStore() }
        
        Reduce { state, action in
            switch action {
            case let .show(model):
                switch model {
                case .fbPlayerInfo(_, _):
                    state.path.append(.fbPlayerInfo(FBPlayerInfoStore.State()))
                default: break
                }
                return .none
            case .search(.delegate(.show(let model))):
                switch model {
                case .fbPlayerInfo(_, _):
                    state.path.append(.fbPlayerInfo(FBPlayerInfoStore.State()))
                default: break
                }
                return .none
            case .search:
                return .none
            case .pop:
                _ = state.path.popLast()
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
            case fbPlayerInfo(FBPlayerInfoStore.State)
            case fbPlayerStats(FBPlayerStatsStore.State)
        }
        
        enum Action {
            case fbPlayerInfo(FBPlayerInfoStore.Action)
            case fbPlayerStats(FBPlayerStatsStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.fbPlayerInfo, action: \.fbPlayerInfo) { FBPlayerInfoStore() }
            Scope(state: \.fbPlayerStats, action: \.fbPlayerStats) { FBPlayerStatsStore() }
        }
    }
}
