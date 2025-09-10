//
//  MoatTimelineStore.swift
//  moare
//
//  Created by 최지혜 on 8/29/25.
//

import SwiftUI
import ComposableArchitecture

enum MoatViewType {
    case timeline, detail, form // createForm, updateForm
}

@Reducer
struct MoatStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var idToken: String? = nil
        var accessToken: String? = nil
        var refreshToken: String? = nil
        
        var currentViewType: MoatViewType = .timeline
        var viewStack: [MoatViewType] = []
        var poppedView: MoatViewType? = nil
        
        var moatListResponse: MoatListResponse? = nil
        var originalTimelineMoats: [MoatResponse] = []
        var timelineMoats: [MoatResponse] = []
        var selectedMoat: MoatDetailResponse? = nil
    }
    
    enum Action {
        case deleteToken
        
        case getTimelineMoats
        case selectMoat(isComment: Bool = false, moatId: String)
        case createMoat(content: String)
        
        case updateTimelineMoats(moatListResponse: MoatListResponse)
        case updateSelectedMoat(isComment: Bool, moatDetailResponse: MoatDetailResponse)
        
        case addViewStack(viewType: MoatViewType)
        case goBack
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .deleteToken:
                UserDefaults.standard.removeObject(forKey: "idToken")
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                
                return .none
                
            case .getTimelineMoats:
                return .run { [moatListReponse = state.moatListResponse] send in
                    let moatListRequest = MoatListRequest(nextToken: moatListReponse?.nextToken)
                    
                    let result = try await moatClient.fetchTimelineMoats(body: moatListRequest)
                    await send(.updateTimelineMoats(moatListResponse: result))
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
                    originalTimeLineMoats = state.originalTimelineMoats
                ] send in
                    if currentViewType == .detail, let moat {
                        let moatRequest = MoatCreateRequest(content: content, sportType: ["#축구"], parentMoatId: moat.moat.moatId)
                        let result = try await moatClient.createMoat(body: moatRequest)
                        
                        var comments = moat.comments?.items ?? []
                        comments.append(result)
                        
                        var moatList = moat.comments
                        moatList?.items = comments
                        
                        var newMoatDetail = moat
                        newMoatDetail.comments = moatList
                        
                        await send(.updateSelectedMoat(isComment: false, moatDetailResponse: newMoatDetail))
                    } else if currentViewType == .form {
                        let moatRequest = MoatCreateRequest(content: content, sportType: ["#축구"])
                        let result = try await moatClient.createMoat(body: moatRequest)
                        
                        await send(.goBack)
                        
                        if let moatListResponse {
                            var timelineMoats = originalTimeLineMoats
                            timelineMoats.append(result)
                            
                            var moatList = moatListResponse
                            moatList.items = timelineMoats
                            
                            await send(.updateTimelineMoats(moatListResponse: moatList))
                        }
                    }
                }
                
            case .updateTimelineMoats(let moatListResponse):
                state.moatListResponse = moatListResponse
                state.originalTimelineMoats = moatListResponse.items
                state.timelineMoats = moatListResponse.items
                
                return .none
                
            case .updateSelectedMoat(let isComment, let moatDetailResponse):
                if isComment {
                    state.selectedMoat = moatDetailResponse
                    state.timelineMoats = [moatDetailResponse.moat]
                } else {
                    state.selectedMoat = moatDetailResponse
                    state.timelineMoats = state.timelineMoats.filter {
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
                    state.currentViewType = .timeline
                    
                    state.selectedMoat = nil
                    state.timelineMoats = state.originalTimelineMoats
                }
                
                return .none
            }
        }
    }
}
