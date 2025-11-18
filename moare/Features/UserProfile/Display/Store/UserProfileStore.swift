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
        
        var selectedMoat: MoatDetailResponse? = nil
        var originalUserMoats: [MoatResponse] = []
    }
    
    enum Action {
        case getUserProfile
        case showUserProfileUpdateForm
        
        case setUserProfile(userProfile: UserProfileWithMoatsResponse)
        case selectMoat(moatId: String)
        
        case showUserProfile
        
        case updateSelectedMoat(moatDetailResponse: MoatDetailResponse)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case push(viewType: UserProfileViewType, moatId: String? = nil, userProfile: UserProfileResponse? = nil)
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
                state.originalUserMoats = userProfile.moatListResponse?.moats ?? []
                
                return .none
                
            case .selectMoat(let moatId):
                if state.selectedMoat != nil {
                    return .send(.delegate(.push(viewType: .moatDetail, moatId: moatId)))
                } else {
                    return .run { send in
                        let result = try await moatClient.fetchMoatDetail(moatId: moatId)
                        
                        await send(.updateSelectedMoat(moatDetailResponse: result), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                    }
                }
                
            case .updateSelectedMoat(let moatDetailResponse):
                state.selectedMoat = moatDetailResponse
                state.userMoats = state.userMoats.filter {
                    $0.moatId == moatDetailResponse.moat.moatId
                }
                
                return .none
                
            case .showUserProfile:
                state.selectedMoat = nil
                state.userMoats = state.originalUserMoats
                
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
