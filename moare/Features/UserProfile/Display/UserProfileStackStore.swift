//
//  UserProfileStackStore.swift
//  moare
//
//  Created by 최지혜 on 11/4/25.
//

import ComposableArchitecture

enum UserProfileViewType {
    case userProfile, moatDetail, userProfileUpdateForm, userProfileImageEdit, updateMoat
}

@Reducer
struct UserProfileStackStore {
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
        var userId: String?
        var createdMoat: MoatResponse? = nil
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
            case let .path(.element(id: _, action: .userProfile(.delegate(.push(viewType, moatId, userProfile, moatDetailResponse, userId))))):
                switch viewType {
                case .moatDetail:
                    state.path.append(.moatDetail(MoatDetailStore.State(moatDetailResponse: moatDetailResponse)))
                    
                case .userProfileUpdateForm:
                    if let userProfile {
                        state.path.append(.userProfileUpdateForm(UserProfileUpdateFormStore.State(userProfile: userProfile)))
                    }
                    
                default: break
                }
                
                return .none
                
            // MoatView(.detail)가 보이고 있는 상황에서 push할때 실행됨.
            case let .path(.element(id: _, action: .moatDetail(.delegate(.push(viewType, moatId, moatDetailResponse, moat, userId))))):
                switch viewType {
                case .detail:
                    state.path.append(.moatDetail(MoatDetailStore.State(moatDetailResponse: moatDetailResponse)))
                    
                case .updateForm:
                    state.path.append(.updateForm(MoatFormStore.State(moat: moat)))
                    
                default: break
                }
                
                return .none
                
            case let .path(.element(id: _, action: .updateForm(.delegate(.createdOrUpdatedMoat(moat))))):
                
                if let lastId = state.path.ids.last,
                   let route = state.path[id: lastId] {
                    switch route {
//                    case .createForm: // 마지막이 form이면 그 자리를 detail로 교체
//                        state.path[id: lastId] = .detail(MoatDetailStore.State(moatResponse: moat))
                    case .updateForm:
                        if let lastId = state.path.ids.last,
                           let route = state.path[id: lastId],
                           case .updateForm = route,
                           let prevId = state.path.ids.dropLast().last,
                           let prev = state.path[id: prevId] {
                            
                            // 1) 폼 제거
                            state.path.popLast()
                            
                            // 2) 바로 전 화면의 상태만 moat 교체
                            switch prev {
                            case .moatDetail(var s):
                                // 작성하자마자 바로 수정하는 경우...?
                                if s.moatResponse != nil {
                                    s.moatResponse = moat
                                    state.path[id: prevId] = .moatDetail(s)
                                } else {
                                    s.moatDetailResponse?.moat = moat
                                    state.path[id: prevId] = .moatDetail(s)
                                }
                                
                            default:
                                break
                            }
                        }
                        
                    default:
                        break
                    }
                }
                
                // 방금 작성한 모트를 일단 담아두기
                state.createdMoat = moat
            
                return .none
                
            case let .path(.element(id: _, action: .moatDetail(.delegate(.deleted(moatId))))):

                let _ = state.path.popLast()
                
                if let id = state.path.ids.last {
                    if case .userProfile(_) = state.path[id: id] {
                        return .send(.path(.element(id: id, action: .userProfile(.deleteDetailMoat(moatId: moatId)))))
                        
                    }
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
                
//                if let id = state.path.ids.last {
//                    if case .userProfile(_) = state.path[id: id] {
//                        return .send(.path(.element(id: id, action: .userProfile(.showUserProfile))))
//                    }
//                }
                
                if state.path.count > 1 {
                    let _ = state.path.popLast()
                }
                
                // 뒤로가기를 했을 때 트렌딩에 보이도록
                if state.createdMoat != nil {
                    // 1) 기존 path에서 '트렌딩' 엘리먼트 id 찾기 (뒤에서부터)
                    if let trendingId = state.path.ids.reversed().first(where: {
                        if case .userProfile = state.path[id: $0] { return true } else { return false }
                    }) {
                        if case .userProfile(_) = state.path[id: trendingId] {
                            return .send(.path(.element(id: trendingId, action: .userProfile(.updateTrending(state.createdMoat!)))))
                        }
                    }
                    state.createdMoat = nil
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
            case moatDetail(MoatDetailStore.State)
            case userProfileUpdateForm(UserProfileUpdateFormStore.State)
            case userProfileImageEdit(UserProfileImageEditStore.State)
            case updateForm(MoatFormStore.State)
        }
        
        enum Action {
            case userProfile(UserProfileStore.Action)
            case moatDetail(MoatDetailStore.Action)
            case userProfileUpdateForm(UserProfileUpdateFormStore.Action)
            case userProfileImageEdit(UserProfileImageEditStore.Action)
            case updateForm(MoatFormStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.userProfile, action: \.userProfile) { UserProfileStore() }
            Scope(state: \.moatDetail, action: \.moatDetail) { MoatDetailStore() }
            Scope(state: \.userProfileUpdateForm, action: \.userProfileUpdateForm) { UserProfileUpdateFormStore() }
            Scope(state: \.userProfileImageEdit, action: \.userProfileImageEdit) { UserProfileImageEditStore() }
            Scope(state: \.updateForm, action:\.updateForm) { MoatFormStore() }
        }
    }
}
