//
//  UserProfileStackStore.swift
//  moare
//
//  Created by 최지혜 on 11/4/25.
//

import ComposableArchitecture

enum UserProfileViewType {
    case userProfile, moatDetail, userProfileUpdateForm, userProfileImageEdit
}

@Reducer
struct UserProfileStackStore {
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
        var userId: String?
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        
        case push(UserProfileViewType)
        case pop
        case emptyPath
        
        case bootstrapSession
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case initSignStore
        case login(String)
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
                
            // UserProfileView에서 moat detail이 보이고 있는 상황에서 push할때 실행됨.
            case let .path(.element(id: _, action: .userProfile(.delegate(.push(viewType, moatId, userProfile))))):
                switch viewType {
                case .moatDetail:
                    state.path.append(.moatDetail(MoatStore.State(moatId: moatId)))
                    
                case .userProfileUpdateForm:
                    if let userProfile {
                        state.path.append(.userProfileUpdateForm(UserProfileUpdateFormStore.State(userProfile: userProfile)))
                    }
                    
                default: break
                }
                
                return .none
                
            // MoatView(.detail)가 보이고 있는 상황에서 push할때 실행됨.
            case let .path(.element(id: _, action: .moatDetail(.delegate(.push(viewType, moatId, moat))))):
                switch viewType {
                case .detail:
                    state.path.append(.moatDetail(MoatStore.State(moatId: moatId)))
                    
                default: break
                }
                
                return .none
                
            case let .path(.element(id: _, action: .userProfileUpdateForm(.delegate(.push(viewType, userId))))):
                switch viewType {
                case .userProfileImageEdit:
                    state.path.append(.userProfileImageEdit(UserProfileImageEditStore.State(userId: userId)))
                    
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
                
            case let .path(.element(id: _, action: .userProfileUpdateForm(.delegate(.pop(userProfile))))):
                _ = state.path.popLast()
                
                if let userProfile {
                    if let id = state.path.ids.last {
                        if case .userProfile(var profileState) = state.path[id: id] {
                            profileState.userProfile = userProfile
                            state.path[id: id] = .userProfile(profileState)
                        }
                    }
                }
                
                return .none
                
            case let .path(.element(id: _, action: .userProfileImageEdit(.delegate(.pop(key, fileURL))))):
                _ = state.path.popLast()
                
                if let key {
                    if let id = state.path.ids.last {
                        if case .userProfileUpdateForm(var updateState) = state.path[id: id] {
                            updateState.tempImageUrl = "https://moare-sns-profile-images.s3.ap-northeast-2.amazonaws.com/\(key)"
                            updateState.tempFileURL = fileURL
                            state.path[id: id] = .userProfileUpdateForm(updateState)
                        }
                    }
                }
                
                return .none
                
            case .bootstrapSession:
                return .run { [path = state.path] send in
                    do {
                        let result = try await SignClient().bootstrapSession()
                        
                        if path.ids.isEmpty {
                            await send(.push(.userProfile))
                            await send(.delegate(.login(result.userId)))
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
                
            case .delegate:
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
            case userProfileUpdateForm(UserProfileUpdateFormStore.State)
            case userProfileImageEdit(UserProfileImageEditStore.State)
        }
        
        enum Action {
            case userProfile(UserProfileStore.Action)
            case moatDetail(MoatStore.Action)
            case userProfileUpdateForm(UserProfileUpdateFormStore.Action)
            case userProfileImageEdit(UserProfileImageEditStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.userProfile, action: \.userProfile) { UserProfileStore() }
            Scope(state: \.moatDetail, action: \.moatDetail) { MoatStore() }
            Scope(state: \.userProfileUpdateForm, action: \.userProfileUpdateForm) { UserProfileUpdateFormStore() }
            Scope(state: \.userProfileImageEdit, action: \.userProfileImageEdit) { UserProfileImageEditStore() }
        }
    }
}
