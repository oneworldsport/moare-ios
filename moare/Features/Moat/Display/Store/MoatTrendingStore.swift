//
//  MoatTrendingStore.swift
//  moare
//
//  Created by 최지혜 on 12/5/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MoatTrendingStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var trendingMoats: [MoatResponse] = []
        var moatListResponse: MoatListResponse? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case getTrendingMoats
        case updateTrendingMoats(moatListResponse: MoatListResponse)
        case updateTrending(MoatResponse)
        case deleteDetailMoat(moatId: String)
        
        case selectMoat(moatId: String)
        case selectMoatResponse(Result<MoatDetailResponse, Error>)
        
        case tappedProfile(userId: String)
        
        case showForm
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case push(viewType: MoatViewType, moatId: String? = nil, moatDetailResponse: MoatDetailResponse? = nil, moat: MoatResponse? = nil, userId: String? = nil)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .getTrendingMoats:
                return .run { [moatListReponse = state.moatListResponse] send in
                    let body = MoatListRequest(
                        nextToken: moatListReponse?.nextToken
                    )
                    
                    let result = try await moatClient.fetchTrendingMoats(body: body)
                    await send(.updateTrendingMoats(moatListResponse: result))
                }
                
            case .updateTrendingMoats(let moatListResponse):
                state.moatListResponse = moatListResponse
                state.trendingMoats = moatListResponse.moats
                
                return .none
                
            case .updateTrending(let moat):
                var newTrending = state.trendingMoats
                
                if let j = newTrending.firstIndex(where: { $0.moatId == moat.moatId }) {
                    newTrending[j] = moat
                } else if moat.moatType == "comment" {
                    return .none
                } else {
                    newTrending.insert(moat, at: 0)
                }
                
                state.trendingMoats = newTrending
                return .none
                
            case .deleteDetailMoat(let moatId):
                var newTrending = state.trendingMoats
                newTrending.removeAll { $0.moatId == moatId }
                
                let newMoatListResponse = MoatListResponse(
                    moats: newTrending,
                    nextToken: state.moatListResponse?.nextToken
                )

                state.moatListResponse = newMoatListResponse
                
                state.trendingMoats = newTrending
                return .none
                
            case .selectMoat(let moatId):
                return .run { send in
                    do {
                        let result = try await moatClient.fetchMoatDetail(moatId: moatId)
                        await send(.selectMoatResponse(.success(result)))
                    } catch {
                        await send(.selectMoatResponse(.failure(error)))
                    }
                    
                }
                
            case .selectMoatResponse(.success(let moatDetailResponse)):
                return .send(.delegate(.push(viewType: .detail, moatDetailResponse: moatDetailResponse)))
                
            case .selectMoatResponse(.failure(_)):
                return .none
                
            case .tappedProfile(let userId):
                return .send(.delegate(.push(viewType: .userProfile, userId: userId)))
                
            case .showForm:
                return .send(.delegate(.push(viewType: .createForm)))
                                
            case .binding:
                return .none
                
            case .delegate:
                return .none

            }
        }
    }
}
