//
//  MoatStackStore.swift
//  moare
//
//  Created by Mohwa Yoon on 11/3/25.
//

import ComposableArchitecture

@Reducer
struct MoatStackStore {
    @ObservableState
    struct State {
        var moat = MoatStore.State()
        var path = StackState<Path.State>()
        
        var didPop: Bool = false
        var includesPreviousView: Bool = false
    }
    
    enum Action {
        case moat(MoatStore.Action)
        case path(StackActionOf<Path>)
        case pop
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.moat, action: \.moat) { MoatStore() }
        
        Reduce { state, action in
            switch action {
            case .pop:
                return .none
                
            case .moat:
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
            case form(FormStore.State)
        }
        
        enum Action {
            case form(FormStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.form, action: \.form) { FormStore() }
        }
    }
}
