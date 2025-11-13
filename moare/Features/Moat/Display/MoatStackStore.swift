//
//  MoatStackStore.swift
//  moare
//
//  Created by Mohwa Yoon on 11/3/25.
//

import Foundation
import ComposableArchitecture

enum MoatViewType {
    case trending, detail, form, userProfile // createForm, updateForm
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
            case .push(let viewType):
                switch viewType {
                case .trending:
                    state.path.append(.trending(MoatStore.State()))
                    
                case .form:
                    state.path.append(.form(FormStore.State()))
                    
                case .userProfile:
                    return .none
                    
                default: break
                }
                
                return .none
                
            case let .path(.element(id: _, action: .trending(.delegate(.push(viewType, moatId))))),
                let .path(.element(id: _, action: .detail(.delegate(.push(viewType, moatId))))):
                switch viewType {
                case .detail:
                    state.path.append(.detail(MoatStore.State(moatId: moatId)))
                    
                default: break
                }
                
                return .none
                
            case .pop:
//                state.didPop = true
//                state.includesPreviousView = false
                
                // MoatViewType이 .trending이면 MoatStore의 .showTrending을 실행하고, .detail이면 기본 뒤로가기 동작을 실행한다
                if let id = state.path.ids.last {
                    if case .trending(_) = state.path[id: id] {
                        return .send(.path(.element(id: id, action: .trending(.showTrending))))
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
                            await send(.push(.trending))
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
            case trending(MoatStore.State)
            case form(FormStore.State)
            case detail(MoatStore.State)
        }
        
        enum Action {
            case trending(MoatStore.Action)
            case form(FormStore.Action)
            case detail(MoatStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.trending, action: \.trending) { MoatStore() }
            Scope(state: \.form, action: \.form) { FormStore() }
            Scope(state: \.detail, action: \.detail) { MoatStore() }
        }
    }
}
