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
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var userProfile: UserProfileResponse? = nil
        var moatListResponse: MoatListResponse? = nil // TODO: 이름 변경
        var userMoats: [MoatResponse] = []
        
        var currentViewType: UserProfileViewType = .userProfile
        var viewStack: [UserProfileViewType] = []
        var poppedView: UserProfileViewType? = nil
        
        var selectedMoat: MoatDetailResponse? = nil
        var originalUserMoats: [MoatResponse] = []
    }
    
    enum Action {
        case getUserProfile
        case updateUserProfile
        
        case setUserProfile(userProfile: UserProfileWithMoatsResponse)
        case selectMoat(isComment: Bool = false, moatId: String)
        
        case updateSelectedMoat(isComment: Bool, moatDetailResponse: MoatDetailResponse)
        
        case addViewStack(viewType: UserProfileViewType)
        case goBack
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
                state.originalUserMoats = userProfile.moatListResponse?.moats ?? []
                return .none
                
            case .selectMoat(let isComment, let moatId):
                return .run { send in
                    let result = try await moatClient.fetchMoatDetail(moatId: moatId)
                    await send(.updateSelectedMoat(isComment: isComment, moatDetailResponse: result), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                    
                    // TODO: 화면 먼저 보여주고 결과 띄워야하기때문에 실행시점 고민 필요
                    await send(.addViewStack(viewType: .moatDetail))
                }
                
            case .updateSelectedMoat(let isComment, let moatDetailResponse):
                if isComment {
                    state.selectedMoat = moatDetailResponse
                    state.userMoats = [moatDetailResponse.moat]
                } else {
                    state.selectedMoat = moatDetailResponse
                    state.userMoats = state.userMoats.filter {
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
                    case .moatDetail:
                        state.currentViewType = viewToShow
                        // TODO: 이전 selectedMoat를 다 저장해서 처리해줘야함.
                    default: break
                    }
                } else {
                    // 뒤로갈 뷰가 없는 경우. 즉, 메인 화면으로 이동하는 경우.
                    state.currentViewType = .userProfile
                    
                    state.selectedMoat = nil
                    state.userMoats = state.originalUserMoats
                }
                
                return .none
            }
        }
    }
}
