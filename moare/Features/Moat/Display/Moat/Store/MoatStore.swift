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
        var reportPresenting: Bool = false
        
        let moatId: String?
        var isDetail: Bool // moatId가 있거나, selectedMoat가 있으면 detail 화면임. 사용하기 편하려고 만든 프로퍼티.
        
        var moatListResponse: MoatListResponse? = nil
        var originalTrendingMoats: [MoatResponse] = []
        var trendingMoats: [MoatResponse] = []
        var selectedMoat: MoatDetailResponse? = nil
        
        var fireMap: [String: Bool] = [:]
        var fireCountMap: [String: Int] = [:]
    
        init(moatId: String? = nil) {
            self.moatId = moatId
            self.isDetail = moatId != nil
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case getTrendingMoats
        case selectMoat(moatId: String)
        case getMoatDetail(moatId: String)
        case createMoat(content: String)
        
        case updateTrendingMoats(moatListResponse: MoatListResponse)
        case updateSelectedMoat(moatDetailResponse: MoatDetailResponse)
        
        case updateTrending(MoatResponse)
        case deleteMoatComment
        
        case setFireMap(targetId: String, isFired: Bool)
        case setFired(targetId: String, isFired: Bool)
        case createFire(targetId: String, targetType: TargetType)
        case createFireResult(targetId: String, isCreated: Bool)
        case deleteFire(targetId: String)
        case deleteFireResult(targetId: String, isDeleted: Bool)
        case toggleFire(targetId: String, targetType: TargetType)
        
        case showForm
        case showTrending
        
        case settingItemsTapped(item: SettingItems, moatId: String)
        case showReport(Bool)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case push(viewType: MoatViewType, moatId: String? = nil)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .getTrendingMoats:
                return .run { [moatListReponse = state.moatListResponse] send in
                    let moatListRequest = MoatListRequest(
                        sportTags: ["축구", "야구"],
                        nextToken: moatListReponse?.nextToken
                    )
                    
                    let result = try await moatClient.fetchTrendingMoats(body: moatListRequest)
                    await send(.updateTrendingMoats(moatListResponse: result))
                }
                
            case .selectMoat(let moatId):
                if state.isDetail {
                    return .send(.delegate(.push(viewType: .detail, moatId: moatId)))
                } else {
                    return .send(.getMoatDetail(moatId: moatId))
                }
                
            case .getMoatDetail(let moatId):
                return .run { send in
                    let result = try await moatClient.fetchMoatDetail(moatId: moatId)
                    
                    await send(.updateSelectedMoat(moatDetailResponse: result), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                }
                
            case .createMoat(let content):
                return .run { [
                    isDetail = state.isDetail,
                    moat = state.selectedMoat
                ] send in
                    if isDetail, let moat {
                        let moatRequest = MoatCreateRequest(content: content, sportTags: ["#축구"], parentMoatId: moat.moat.moatId)
                        let result = try await moatClient.createMoat(body: moatRequest)
                        
                        var comments = moat.commentListResponse?.moats ?? []
                        comments.append(result)
                        
                        var commentListResponse = moat.commentListResponse
                        commentListResponse?.moats = comments
                        
                        var newMoatDetail = moat
                        newMoatDetail.commentListResponse = commentListResponse
                        
                        await send(.updateSelectedMoat(moatDetailResponse: newMoatDetail))
                    }
//                    if currentViewType == .form {
//                        let moatRequest = MoatCreateRequest(content: content, sportTags: ["#축구"])
//                        let result = try await moatClient.createMoat(body: moatRequest)
//                        
//                        if let moatListResponse {
//                            var trendingMoats = originalTrendingMoats
//                            trendingMoats.append(result)
//                            
//                            var moatList = moatListResponse
//                            moatList.moats = trendingMoats
//                            
//                            await send(.updateTrendingMoats(moatListResponse: moatList))
//                        }
//                    }
                }
                
            case .updateTrendingMoats(let moatListResponse):
                state.moatListResponse = moatListResponse
                state.originalTrendingMoats = moatListResponse.moats
                state.trendingMoats = moatListResponse.moats
                
                return .none
                
            case .updateSelectedMoat(let moatDetailResponse):
                state.selectedMoat = moatDetailResponse
                state.isDetail = true
                
                if state.isDetail {
                    state.trendingMoats = [moatDetailResponse.moat]
                } else {
                    state.trendingMoats = state.trendingMoats.filter {
                        $0.moatId == moatDetailResponse.moat.moatId
                    }
                }
                
                return .none
                
            case .showTrending:
                state.selectedMoat = nil
                state.isDetail = false
                state.trendingMoats = state.originalTrendingMoats
                
                return .none
                
            case .showForm:
                return .send(.delegate(.push(viewType: .form)))
                
            case .updateTrending(let moat):
                // ① 원본 리스트 갱신
                var newOriginal = state.originalTrendingMoats
                newOriginal.removeAll { $0.moatId == moat.moatId }
                newOriginal.insert(moat, at: 0)   // ✅ 최상단 삽입
                
                // ② 화면용 리스트도 동일 규칙으로 (필터 없다는 가정)
                var newTrending = state.trendingMoats
                newTrending.removeAll { $0.moatId == moat.moatId }
                newTrending.insert(moat, at: 0)
                
                // ③ 통째 교체 핸들러 재사용
                let newMoatListResponse = MoatListResponse(
                    moats: newOriginal,
                    nextToken: state.moatListResponse?.nextToken
                )
                
                // updateTrendingMoats에서 both(원본/화면) 세팅
                state.moatListResponse = newMoatListResponse
                state.originalTrendingMoats = newOriginal
                state.trendingMoats = newTrending
                return .none
                
            case .deleteMoatComment:
                return .none
                
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
                
            case .binding:
                return .none
                
            case .settingItemsTapped(let item, let moatId):
                switch item {
                case .report:
                    return .send(.showReport(true))
                    
                case .updateMoat:
                    return .send(.showForm)
                    
                case .deleteMoat:
                    return .run { _ in
                        try await moatClient.deleteMoat(moatId: moatId)
                    }
                default:
                    return .none
                }
                
            case .showReport(let show):
                state.reportPresenting = show
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
