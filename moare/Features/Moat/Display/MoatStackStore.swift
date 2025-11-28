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
        
        var createdMoat: MoatResponse? = nil
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
                    
                case .form:
                    state.path.append(.form(FormStore.State()))
                    
                default: break
                }
                
                return .none
                
            case let .path(.element(id: _, action: .form(.delegate(.created(moat))))):
                // 마지막이 form이면 그 자리를 detail로 교체
                if let lastId = state.path.ids.last,
                   case .form = state.path[id: lastId] {
                    state.path[id: lastId] = .detail(MoatStore.State(moatId: moat.moatId))
                }
                
                // 방금 작성한 모트를 일단 담아두기
                state.createdMoat = moat
            
                return .none
                
            case let .path(.element(id: _, action: .detail(.delegate(.deleted(moatId))))),
                let .path(.element(id: _, action: .trending(.delegate(.deleted(moatId))))):
                
                if state.path.count > 1 {
                    let _ = state.path.popLast()

                } else {
                    if let id = state.path.ids.last {
                        if case .trending(_) = state.path[id: id] {
                            return .send(.path(.element(id: id, action: .trending(.deleteDetailMoat(moatId: moatId)))))
                        }
                    }
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
