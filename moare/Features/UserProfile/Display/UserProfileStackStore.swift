//
//  UserProfileStackStore.swift
//  moare
//
//  Created by 최지혜 on 11/4/25.
//

import ComposableArchitecture

enum UserProfileViewType {
    case userProfile, moatDetail, profileUpdateForm
}

@Reducer
struct UserProfileStackStore {
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        
        case push(UserProfileViewType)
        case pop
        case emptyPath
        
        case bootstrapSession
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .push(let viewType):
                switch viewType {
                case .userProfile:
                    state.path.append(.userProfile(UserProfileStore.State()))
                    
                default:
                    break
                }
                
                return .none
                
            // UserProfileView에서 moat detail이 보이고 있는 상황에서 뒤로가기를 했을때 실행됨.
            case let .path(.element(id: _, action: .userProfile(.delegate(.push(viewType, moatId))))):
                switch viewType {
                case .moatDetail:
                    state.path.append(.moatDetail(MoatStore.State(moatId: moatId)))
                    
                default: break
                }
                
                return .none
                
            // MoatView(.detail)가 보이고 있는 상황에서 뒤로가기를 했을때 실행됨.
            case let .path(.element(id: _, action: .moatDetail(.delegate(.push(viewType, moatId))))):
                switch viewType {
                case .detail:
                    state.path.append(.moatDetail(MoatStore.State(moatId: moatId)))
                    
                default: break
                }
                
                return .none
                
            case .pop:
//                if let id = state.path.ids.last {
//                    return .send(.path(.element(id: id, action: .userProfile(.goBack))))
//                }
                
                if let id = state.path.ids.last {
                    if case .userProfile(_) = state.path[id: id] {
                        return .send(.path(.element(id: id, action: .userProfile(.showUserProfile))))
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
                            await send(.push(.userProfile))
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
            case userProfile(UserProfileStore.State)
            case moatDetail(MoatStore.State)
        }
        
        enum Action {
            case userProfile(UserProfileStore.Action)
            case moatDetail(MoatStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.userProfile, action: \.userProfile) { UserProfileStore() }
            Scope(state: \.moatDetail, action: \.moatDetail) { MoatStore() }
        }
    }
}
