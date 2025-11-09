//
//  MoatStackStore.swift
//  moare
//
//  Created by Mohwa Yoon on 11/3/25.
//

import Foundation
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
        case emptyPath
        
        case bootstrapSession
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .push(let viewType),
                let .path(.element(id: _, action: .moat(.delegate(.push(viewType))))):
                switch viewType {
                case .timeline:
                    state.path.append(.moat(MoatStore.State()))
                    
                case .form:
                    state.path.append(.form(FormStore.State()))
                    
                case .userProfile:
                    return .none
                    
                default: break
                }
                
                return .none
                
            case .pop:
//                state.didPop = true
//                state.includesPreviousView = false
                
                if let id = state.path.ids.last {
                    if case .moat(let state) = state.path[id: id] {
                        if case .detail = state.currentViewType {
                            return .send(.path(.element(id: id, action: .moat(.goBack))))
                        }
                    }
                }
                
                if state.path.count > 1 {
                    let _ = state.path.popLast()
                }
                
                return .none
                
            case .bootstrapSession:
                return .run { [path = state.path] send in
                    do {
                        let result = try await SignClient().bootstrapSession()
                        
                        if result.success && path.ids.isEmpty {
                            await send(.push(.timeline))
                        }
                    } catch {
                        print("\(error)")
                    }
                }
                
            case .emptyPath:
                state.path.removeAll()
                
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
