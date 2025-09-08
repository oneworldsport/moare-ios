//
//  MoatTimelineStore.swift
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
        
        var moatListResponse: MoatListResponse? = nil
        var timelineMoats: [MoatResponse] = []
        var selectedMoat: MoatDetailResponse? = nil
    }
    
    enum Action {
        case deleteToken
        
        case getTimelineMoats
        case selectMoat(moatId: String)
        
        case updateTimelineMoats(moatListResponse: MoatListResponse)
        case updateSelectedMoat(moatDetailResponse: MoatDetailResponse)
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
            }
        }
    }
}
