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
        var timelineMoats: [MoatResponse] = []
        var selectedMoat: MoatDetailResponse? = nil
    }
    
    enum Action {
        case deleteToken
        
        case getTimelineMoats
        case selectMoat(moatId: String)
        case createMoat(content: String)
        
        case updateTimelineMoats(moatListResponse: MoatListResponse)
        case updateSelectedMoat(moatDetailResponse: MoatDetailResponse)
        
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
                
            case .selectMoat(let moatId):
                return .run { send in
                    let result = try await moatClient.fetchMoatDetail(moatId: moatId)
                    await send(.updateSelectedMoat(moatDetailResponse: result))
                    
                    // TODO: 화면 먼저 보여주고 결과 띄워야하기때문에 실행시점 고민 필요
                    await send(.addViewStack(viewType: .detail))
                }
                
            case .createMoat(let content):
                return .run { [moat = state.selectedMoat] send in
                    if let moat {
                        let moatRequest = MoatCreateRequest(content: content, sportType: ["#축구"], parentMoatId: moat.moat.moatId)
                        let _ = try await moatClient.createMoat(body: moatRequest)
                    }
                }
                
            case .updateTimelineMoats(let moatListResponse):
                state.moatListResponse = moatListResponse
                state.timelineMoats = moatListResponse.items
                
                return .none
                
            case .updateSelectedMoat(let moatDetailResponse):
                state.selectedMoat = moatDetailResponse
                state.timelineMoats.filter {
                    $0.moatId == moatDetailResponse.moat.moatId
                }
                
                return .none
                
            case .addViewStack(let viewType):
                state.viewStack.append(viewType)
                state.currentViewType = viewType
                
                return .none
                
            case .goBack:
                let lastView = state.viewStack.popLast()
                state.poppedView = lastView
                
                return .none
            }
        }
    }
}
