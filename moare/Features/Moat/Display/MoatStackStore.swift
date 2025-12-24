//
//  MoatStackStore.swift
//  moare
//
//  Created by Mohwa Yoon on 11/3/25.
//

import Foundation
import ComposableArchitecture

enum MoatViewType {
    case trending, detail, createForm, userProfile, updateForm // createForm,
}

@Reducer
struct MoatStackStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        
        var fire = FireStore.State()
        
        var userId: String?
        
        var didPop: Bool = false
        var includesPreviousView: Bool = false
        
        var selectedHashtags: [String] = []
        var currentSelectedHashtags: [String] = []
        
        var createdMoat: MoatResponse? = nil
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        
        case fire(FireStore.Action)
        
        case push(MoatViewType)
        case pop
        case emptyPath
        
        case bootstrapSession

        case updateSelectedHashtags(String)
        case emptySelectedHashtags
        case getMoatsWithHashtags
        case updateMainMoats(MoatListResponse)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case initSignStore
        case login(String)
    }
    
    var body: some Reducer<State, Action> {
        
        // TODO: StackStore에서 다른 Store의 state 바꾸는거 전부 action으로 바꿔야함
        Reduce { state, action in
            switch action {
            case .push(let viewType):
                switch viewType {
                case .trending:
                    state.path.append(.trending(MoatTrendingStore.State()))
                    
                case .createForm:
                    state.path.append(.createForm(MoatFormStore.State()))
                    
                case .userProfile:
                    return .none
                    
                default: break
                }
                
                return .none
                
            case let .path(.element(id: _, action: .trending(.delegate(.push(viewType, moatId, moatDetailResponse, moat, userId))))),
                let .path(.element(id: _, action: .detail(.delegate(.push(viewType, moatId, moatDetailResponse, moat, userId))))):
                switch viewType {
                case .detail:
                    state.path.append(.detail(MoatDetailStore.State(moatDetailResponse: moatDetailResponse)))
                    
                case .createForm:
                    state.path.append(.createForm(MoatFormStore.State()))
                    
                case .updateForm:
                    state.path.append(.updateForm(MoatFormStore.State(moat: moat)))
                    
                case .userProfile:
                    state.path.append(.userProfile(UserProfileStore.State(userId: state.userId, targetUserId: userId)))
                    
                default: break
                }
                
                return .none
                
            case let .path(.element(id: _, action: .createForm(.delegate(.createdOrUpdatedMoat(moat))))),
                let .path(.element(id: _, action: .updateForm(.delegate(.createdOrUpdatedMoat(moat))))):
                
                if let lastId = state.path.ids.last,
                   let route = state.path[id: lastId] {
                    switch route {
                    case .createForm: // 마지막이 form이면 그 자리를 detail로 교체
                        state.path[id: lastId] = .detail(MoatDetailStore.State(moatResponse: moat))
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
                            case .detail(var s):
                                // 작성하자마자 바로 수정하는 경우...?
                                if s.moatResponse != nil {
                                    s.moatResponse = moat
                                    state.path[id: prevId] = .detail(s)
                                } else {
                                    s.moatDetailResponse?.moat = moat
                                    state.path[id: prevId] = .detail(s)
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
                
            case let .path(.element(id: _, action: .detail(.delegate(.deleted(moatId))))):

                let _ = state.path.popLast()
                
                if let id = state.path.ids.last {
                    if case .trending(_) = state.path[id: id] {
                        return .send(.path(.element(id: id, action: .trending(.deleteDetailMoat(moatId: moatId)))))
                        
                    }
                }
                
                return .none
                
            case let .path(.element(id: _, action: .userProfile(.delegate(.pushInUserProfile(viewType, moatDetailResponse))))):
                switch viewType {
                case .detail:
                    state.path.append(.detail(MoatDetailStore.State(moatDetailResponse: moatDetailResponse)))
                    
                default: break
                }
                return .none
                
            case .pop:
//                state.didPop = true
//                state.includesPreviousView = false
                
                // MoatViewType이 .trending이면 MoatStore의 .showTrending을 실행하고, .detail이면 기본 뒤로가기 동작을 실행한다
//                if let id = state.path.ids.last {
//                    if case .trending(_) = state.path[id: id] {
//                        return .send(.path(.element(id: id, action: .trending(.showTrending))))
//                    }
//                }
                                
                if state.path.count > 1 {
                    let _ = state.path.popLast()
                }
                
                // 뒤로가기를 했을 때 트렌딩에 보이도록
                if state.createdMoat != nil {
                    // 1) 기존 path에서 '트렌딩' 엘리먼트 id 찾기 (뒤에서부터)
                    if let trendingId = state.path.ids.reversed().first(where: {
                        if case .trending = state.path[id: $0] { return true } else { return false }
                    }) {
                        if case .trending(_) = state.path[id: trendingId] {
                            return .send(.path(.element(id: trendingId, action: .trending(.updateTrending(state.createdMoat!)))))
                        }
                    }
                    state.createdMoat = nil
                }
                
                return .none
                
            case .bootstrapSession:
                return .run { [path = state.path] send in
                    do {
                        let result = try await SignClient().bootstrapSession()
                        
                        if path.ids.isEmpty {
                            await send(.push(.trending))
                            await send(.delegate(.login(result.userId)))
                        }
                    } catch {
                        print("\(error)")
                    }
                }
                
            case .emptyPath:
                state.path.removeAll()
                
                return .none
                
            case .updateSelectedHashtags(let hashtag):
                if state.selectedHashtags.contains(hashtag) {
                    state.selectedHashtags.removeAll { $0 == hashtag }
                } else {
                    state.selectedHashtags.append(hashtag)
                }
                
                return .none
                
            case .emptySelectedHashtags:
                state.selectedHashtags.removeAll()
                
                return .none
                
            case .getMoatsWithHashtags:
                if state.selectedHashtags.isEmpty ||
                    Set(state.selectedHashtags) == Set(state.currentSelectedHashtags)
                {
                    return .none
                }
                
                return .run { [hastags = state.selectedHashtags] send in
                    let sportTags = hastags.map { tag in
                        var new = tag
                        if new.hasPrefix("# ") {
                            new.removeFirst(2)
                        }
                        return new
                    }
                    let body = MoatListRequest(sportTags: sportTags)
                    
                    do {
                        let result = try await moatClient.fetchMoatsByHashtags(body: body)
                        await send(.updateMainMoats(result))
                    } catch {
                        
                    }
                }
                
            case .updateMainMoats(let moatListResponse):
                state.currentSelectedHashtags = state.selectedHashtags
                
                if let id = state.path.ids.last {
                    if case .trending(_) = state.path[id: id] {
                        return .send(.path(.element(id: id, action: .trending(.updateTrendingMoats(moatListResponse: moatListResponse)))))
                    }
                }
                return .none
                
            case .path:
                return .none
                
            case .delegate:
                return .none
                
            case .fire:
                return .none
            }
        }
        Scope(state: \.fire, action: \.fire) {
              FireStore()
            }
        
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
    
    @Reducer
    struct Path {
        @ObservableState
        enum State {
            case trending(MoatTrendingStore.State)
            case createForm(MoatFormStore.State)
            case detail(MoatDetailStore.State)
            case updateForm(MoatFormStore.State)
            case userProfile(UserProfileStore.State)
        }
        
        enum Action {
            case trending(MoatTrendingStore.Action)
            case createForm(MoatFormStore.Action)
            case detail(MoatDetailStore.Action)
            case updateForm(MoatFormStore.Action)
            case userProfile(UserProfileStore.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.trending, action: \.trending) { MoatTrendingStore() }
            Scope(state: \.createForm, action: \.createForm) { MoatFormStore() }
            Scope(state: \.detail, action: \.detail) { MoatDetailStore() }
            Scope(state: \.updateForm, action:\.updateForm) { MoatFormStore() }
            Scope(state: \.userProfile, action: \.userProfile) { UserProfileStore() }
        }
    }
}
