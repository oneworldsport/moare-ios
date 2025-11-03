//
//  MoatStackStore.swift
//  moare
//
//  Created by Mohwa Yoon on 11/3/25.
//

import ComposableArchitecture

enum MoatViewType {
    case timeline, detail, form, userProfile // createForm, updateForm
}

@Reducer
struct MoatStackStore {
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
        var didPop: Bool = false
        var includesPreviousView: Bool = false
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        
        case push(MoatViewType)
        case pop
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .push(let moatTypeEnum):
                switch moatTypeEnum {
                case .timeline:
                    state.path.append(.moat(MoatStore.State()))
                    return .none
                    
                case .detail:
                    return .none
                    
                case .form:
                    return .none
                    
                case .userProfile:
                    return .none
                    
                }
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
            case moat(MoatStore.State)
            case form(FormStore.State)
        }
        
        enum Action {
            case moat(MoatStore.Action)
            case form(FormStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.moat, action: \.moat) { MoatStore() }
            Scope(state: \.form, action: \.form) { FormStore() }
        }
    }
}
