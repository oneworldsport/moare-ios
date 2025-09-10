//
//  UserProfileStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

enum UserProfileViewType {
    case userProfile, moatDetail, profileUpdateForm
}

@Reducer
struct UserProfileStore {
    let userProfileClient = UserProfileClient()
    
    @ObservableState
    struct State {
        var userProfile: UserProfileResponse? = nil
        var moatListResponse: MoatListResponse? = nil // TODO: 이름 변경
        var userMoats: [MoatResponse] = []
    }
    
    enum Action {
        case getUserProfile
        case updateUserProfile
        
        case setUserProfile(userProfile: UserProfileWithMoatsResponse)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getUserProfile:
                return .run { send in
                    let result = try await userProfileClient.fetchUserProfile()
                    await send(.setUserProfile(userProfile: result))
                }
                
            case .updateUserProfile:
                return .none
                
            case .setUserProfile(let userProfile):
                state.userProfile = userProfile.userProfile
                state.moatListResponse = userProfile.moatListResponse
                state.userMoats = userProfile.moatListResponse?.moats ?? []
                return .none
            }
        }
    }
}
