//
//  MoatStore.swift
//  moare
//
//  Created by 최지혜 on 8/29/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MoatStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var idToken: String? = nil
        var accessToken: String? = nil
        var refreshToken: String? = nil
        
        var currentViewType: MoatViewType = .trending
        var viewStack: [MoatViewType] = []
        var poppedView: MoatViewType? = nil
        
        var moatListResponse: MoatListResponse? = nil
        var originalTrendingMoats: [MoatResponse] = []
        var trendingMoats: [MoatResponse] = []
        var selectedMoat: MoatDetailResponse? = nil
        
        var fireMap: [String: Bool] = [:]
        var fireCountMap: [String: Int] = [:]
    }
    
    enum Action {
        case deleteToken
        
        case getTrendingMoats
        case selectMoat(isComment: Bool = false, moatId: String)
        case createMoat(content: String)
        
        case updateTrendingMoats(moatListResponse: MoatListResponse)
        case updateSelectedMoat(isComment: Bool, moatDetailResponse: MoatDetailResponse)
        
        case addViewStack(viewType: MoatViewType)
        case showForm
        case goBack
        
        case checkFire(targetId: String)
        case setFireMap(targetId: String, isFired: Bool)
        case setFired(targetId: String, isFired: Bool)
        case createFire(targetId: String, targetType: TargetType)
        case createFireResult(targetId: String, isCreated: Bool)
        case deleteFire(targetId: String)
        case deleteFireResult(targetId: String, isDeleted: Bool)
        case toggleFire(targetId: String, targetType: TargetType)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case push(MoatViewType)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .deleteToken:
                UserDefaults.standard.removeObject(forKey: "idToken")
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                
                return .none
                
            case .getTrendingMoats:
                return .run { [moatListReponse = state.moatListResponse] send in
                    let moatListRequest = MoatListRequest(
                        sportTags: ["축구", "야구"],
                        nextToken: moatListReponse?.nextToken
                    )
                    
                    let result = try await moatClient.fetchTrendingMoats(body: moatListRequest)
                    await send(.updateTrendingMoats(moatListResponse: result))
                }
                
            case .selectMoat(let isComment, let moatId):
                return .run { send in
                    let result = try await moatClient.fetchMoatDetail(moatId: moatId)
                    await send(.updateSelectedMoat(isComment: isComment, moatDetailResponse: result), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                    
                    // TODO: 화면 먼저 보여주고 결과 띄워야하기때문에 실행시점 고민 필요
                    await send(.addViewStack(viewType: .detail))
                }
                
            case .createMoat(let content):
                return .run { [
                    moat = state.selectedMoat,
                    currentViewType = state.currentViewType,
                    moatListResponse = state.moatListResponse,
                    originalTrendingMoats = state.originalTrendingMoats
                ] send in
                    if currentViewType == .detail, let moat {
                        let moatRequest = MoatCreateRequest(content: content, sportTags: ["#축구"], parentMoatId: moat.moat.moatId)
                        let result = try await moatClient.createMoat(body: moatRequest)
                        
                        var comments = moat.commentListResponse?.moats ?? []
                        comments.append(result)
                        
                        var commentListResponse = moat.commentListResponse
                        commentListResponse?.moats = comments
                        
                        var newMoatDetail = moat
                        newMoatDetail.commentListResponse = commentListResponse
                        
                        await send(.updateSelectedMoat(isComment: false, moatDetailResponse: newMoatDetail))
                    } else if currentViewType == .form {
                        let moatRequest = MoatCreateRequest(content: content, sportTags: ["#축구"])
                        let result = try await moatClient.createMoat(body: moatRequest)
                        
                        await send(.goBack)
                        
                        if let moatListResponse {
                            var trendingMoats = originalTrendingMoats
                            trendingMoats.append(result)
                            
                            var moatList = moatListResponse
                            moatList.moats = trendingMoats
                            
                            await send(.updateTrendingMoats(moatListResponse: moatList))
                        }
                    }
                }
                
            case .updateTrendingMoats(let moatListResponse):
                state.moatListResponse = moatListResponse
                state.originalTrendingMoats = moatListResponse.moats
                state.trendingMoats = moatListResponse.moats
                
                return .none
                
            case .updateSelectedMoat(let isComment, let moatDetailResponse):
                if isComment {
                    state.selectedMoat = moatDetailResponse
                    state.trendingMoats = [moatDetailResponse.moat]
                } else {
                    state.selectedMoat = moatDetailResponse
                    state.trendingMoats = state.trendingMoats.filter {
                        $0.moatId == moatDetailResponse.moat.moatId
                    }
                }
                
                return .none
                
            case .addViewStack(let viewType):
                state.viewStack.append(viewType)
                state.currentViewType = viewType
                
                return .none
                
            case .goBack:
                let lastView = state.viewStack.popLast()
                state.poppedView = lastView
                
                let viewToShow = state.viewStack.last
                
                if let viewToShow {
                    switch viewToShow {
                    case .detail:
                        state.currentViewType = viewToShow
                        // TODO: 이전 selectedMoat를 다 저장해서 처리해줘야함.
                        
                    case .form:
                        state.currentViewType = viewToShow
                    default: break
                    }
                } else {
                    // 뒤로갈 뷰가 없는 경우. 즉, 메인 화면으로 이동하는 경우.
                    state.currentViewType = .trending
                    
                    state.selectedMoat = nil
                    state.trendingMoats = state.originalTrendingMoats
                }
                
                return .none
                
            case .showForm:
                return .send(.delegate(.push(.form)))
                
            case .checkFire(let targetId):
                return .run { send in
                    let result = try await moatClient.checkFire(moatId: targetId)
                    
                    await send(.setFireMap(targetId: targetId, isFired: result))
                }
                
            case .setFireMap(let targetId, let isFired):
                state.fireMap[targetId] = isFired
                return .none
                
            case .setFired(let targetId, let isFired):
                state.fireMap[targetId] = isFired
                return .none
                
            case .createFire(let targetId, let targetType):
                return .run { send in
                    var isCreated: Bool = false
                    
                    let fireCreateRequest = FireCreateRequest(targetId: targetId, targetType: targetType)
                    
                    let result = try await moatClient.createFire(body: fireCreateRequest)
                    
                    if result != nil {
                        isCreated = true
                    }
                    
                    await send(.createFireResult(targetId: targetId, isCreated: isCreated))
                }
                
            case .createFireResult(let targetId, let isCreated):
                if !isCreated {
                    state.fireMap[targetId] = false
                    
                    let firstFireCount = state.fireCountMap[targetId] ?? (state.trendingMoats.first{ $0.moatId == targetId }?.fireCount ?? 0)
                    
                    state.fireCountMap[targetId] = max(0, firstFireCount - 1)
                }
                
                return .none
                
            case .deleteFire(let targetId):
                return .run { send in
                    var isDeleted: Bool = false
                    
                    let result = try await moatClient.deleteFire(moatId: targetId)
                    
                    if result != nil {
                        isDeleted = true
                    }
                    
                    await send(.deleteFireResult(targetId: targetId, isDeleted: isDeleted))
                }
                
            case .deleteFireResult(let targetId, let isDeleted):
                if !isDeleted {
                    state.fireMap[targetId] = true
                    
                    let firstFireCount = state.fireCountMap[targetId] ?? (state.trendingMoats.first{ $0.moatId == targetId }?.fireCount ?? 0)
                    
                    state.fireCountMap[targetId] = firstFireCount + 1
                }
                
                return .none
                
            case .toggleFire(let targetId, let targetType):
                let isFired = state.fireMap[targetId] ?? false
                state.fireMap[targetId] = !isFired
                
                let firstFireCount = state.fireCountMap[targetId] ?? (state.trendingMoats.first{ $0.moatId == targetId }?.fireCount ?? 0)
                state.fireCountMap[targetId] = isFired ? max(0, firstFireCount - 1) : firstFireCount + 1
                
                if isFired {
                    state.fireMap[targetId] = false
                    return .send(.deleteFire(targetId: targetId))
                } else {
                    state.fireMap[targetId] = true
                    return .send(.createFire(targetId: targetId, targetType: targetType))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
