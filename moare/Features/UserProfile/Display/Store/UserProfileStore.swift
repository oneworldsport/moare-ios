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
    
    @ObservableState
    struct State {
        var userProfile: UserProfileResponse? = nil
        var userMoats: MoatListResponse? = nil
    }
    
    enum Action {
        case getUserProfile
        case updateUserProfile
        
        case setUserProfile(userProfile: UserProfileResponse)
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
                state.userProfile = userProfile
                return .none
            }
        }
    }
}
