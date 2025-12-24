//
//  UserProfileStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct UserProfileStore {
    let userProfileClient = UserProfileClient()
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var userProfile: UserProfileResponse? = nil
        var moatListResponse: MoatListResponse? = nil // TODO: 이름 변경
        var userMoats: [MoatResponse] = []
        var userId: String?
        var targetUserId: String?
    }
    
    enum Action {
        case getUserProfile
        case showUserProfileUpdateForm
        
        case setUserProfile(userProfile: UserProfileWithMoatsResponse)
        case selectMoat(moatId: String)
        case selectMoatResponse(Result<MoatDetailResponse, Error>)
        case updateTrending(MoatResponse)
        case deleteDetailMoat(moatId: String)
        case getMoatUserProfile(targetUserId: String)
        
        case settingItemsTapped(item: UserProfileSettingItems)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case push(viewType: UserProfileViewType, moatId: String? = nil, userProfile: UserProfileResponse? = nil, moatDetailResponse: MoatDetailResponse? = nil, userId: String? = nil)
        case pushInUserProfile(viewType: MoatViewType, moatDetailResponse: MoatDetailResponse)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getUserProfile:
                return .run { send in
                    let result = try await userProfileClient.fetchUserProfile()
                    await send(.setUserProfile(userProfile: result))
                }
                
            case .showUserProfileUpdateForm:
                return .send(.delegate(.push(viewType: .userProfileUpdateForm, userProfile: state.userProfile)))
                
            case .setUserProfile(let userProfile):
                state.userProfile = userProfile.userProfile
                state.moatListResponse = userProfile.moatListResponse
                state.userMoats = userProfile.moatListResponse?.moats ?? []
                
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
                if state.targetUserId == nil {
                    return .send(.delegate(.push(viewType: .moatDetail, moatDetailResponse: moatDetailResponse)))
                } else {
                    return .send(.delegate(.pushInUserProfile(viewType: .detail, moatDetailResponse: moatDetailResponse)))
                }
                
            case .selectMoatResponse(.failure(_)):
                return .none
                
            case .updateTrending(let moat):
                var newTrending = state.userMoats
                
                if let j = newTrending.firstIndex(where: { $0.moatId == moat.moatId }) {
                    newTrending[j] = moat
                } else if moat.moatType == "comment" {
                    return .none
                } else {
                    newTrending.insert(moat, at: 0)
                }
                
                state.userMoats = newTrending
                return .none
                
            case .deleteDetailMoat(let moatId):
                var newTrending = state.userMoats
                newTrending.removeAll { $0.moatId == moatId }
                
                let newMoatListResponse = MoatListResponse(
                    moats: newTrending,
                    nextToken: state.moatListResponse?.nextToken
                )

                state.moatListResponse = newMoatListResponse
                
                state.userMoats = newTrending
                return .none
                
            case .getMoatUserProfile(let targetUserId):
                return .run { send in
                    let result = try await userProfileClient.getMoatUserProfile(userId: targetUserId)
                    
                    await send(.setUserProfile(userProfile: result))
                }
                
            case .settingItemsTapped(let item):
                switch item {
                case .report:
                    return .none
                case .updateProfile:
                    return .send(.showUserProfileUpdateForm)
                default:
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
