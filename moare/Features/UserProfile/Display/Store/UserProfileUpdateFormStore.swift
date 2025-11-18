//
//  UserProfileUpdateFormStore.swift
//  moare
//
//  Created by Mohwa Yoon on 11/14/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct UserProfileUpdateFormStore {
    let userProfileClient = UserProfileClient()
    let signClient = SignClient()
    
    @ObservableState
    struct State {
        let userProfile: UserProfileResponse
        
        var userProfileUpdate = UserProfileUpdateRequest()
        
        var tempImageUrl: String? = nil
        var tempFileURL: URL? = nil
        var sportsInterests: [String]
        
        var isUserHandleTextFieldDisabled = false
        var userHandleCheckState: ApiFetchState = .idle
        
        init(userProfile: UserProfileResponse) {
            self.userProfile = userProfile
            self.sportsInterests = userProfile.sportsInterests
        }
    }
    
    enum Action {
        case showImageEdit
        case checkUserHandle(String)
        case updateBio(String)
        case updateSportsInterests(String)
        case submit
        case cancel
        
        // private
        case updateUserProfileUserHandle
        case updateUserHandleCheckState(checkState: ApiFetchState = .idle, newUserHandle: String? = nil)
        case reserveUserHandle(String)
        case uploadImage
        case updateProfile(key: String? = nil)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case push(viewType: UserProfileViewType, userId: String)
        case pop(userProfile: UserProfileResponse? = nil)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showImageEdit:
                return .send(.delegate(.push(viewType: .userProfileImageEdit, userId: state.userProfile.userId)))
                
            case .checkUserHandle(let text):
                let userHandle = state.userProfile.userHandle
                return .run { send in
                    do {
                        await send(.updateUserHandleCheckState(checkState: .idle))
                        
                        // TODO: 유효성 검사
                        if text.isEmpty || text == userHandle {
                            await send(.updateUserProfileUserHandle)
                            return
                        }
                        
                        try await Task.sleep(for: .seconds(2))
                        
                        await send(.updateUserHandleCheckState(checkState: .fetching), animation: AnimationConstants.AnimationType.shortDefaultAnimation)
                        
                        try await Task.sleep(for: .seconds(3)) // test 지연
                        
                        let result = try await signClient.checkUserHandle(userHandle: text)
                        
                        await send(.updateUserHandleCheckState(
                            checkState: result.success ? .success : .failure(result.message),
                            newUserHandle: text
                        ), animation: AnimationConstants.AnimationType.shortDefaultAnimation)
                    } catch {
                        if let err = error as? APIHTTPError, let message = err.message {
                            await send(.updateUserHandleCheckState(checkState: .failure(message)))
                        }
                    }
                }
                .cancellable(id: CheckUserHandleCancelID(), cancelInFlight: true)
                
            case .updateUserProfileUserHandle:
                state.userProfileUpdate.userHandle = nil
                return .none
                
            case let .updateUserHandleCheckState(checkState, newUserHandle):
                state.userHandleCheckState = checkState
                
                if checkState == .fetching {
                    state.isUserHandleTextFieldDisabled = true
                } else {
                    state.isUserHandleTextFieldDisabled = false
                }
                
                if let newUserHandle, checkState == .success {
                    state.userProfileUpdate.userHandle = newUserHandle
                    return .send(.reserveUserHandle(newUserHandle))
                }
                
                return .none
                
            case .reserveUserHandle(let text):
                return .run { send in
                    do {
                        let body = UserHandleReserveRequest(userHandle: text)
                        
                        _ = try await signClient.reserveUserHandle(body: body)
                    } catch {
                        if let err = error as? APIHTTPError {
//                            await send(.responseFailure(err))
                        }
                    }
                }
                
            case .updateBio(let text):
                if state.userProfile.bio != text {
                    state.userProfileUpdate.bio = text
                } else {
                    state.userProfileUpdate.bio = nil
                }
                
                return .none
                
            case .updateSportsInterests(let sport):
                if state.sportsInterests.contains(sport) {
                    state.sportsInterests.removeAll { $0 == sport }
                } else {
                    state.sportsInterests.append(sport)
                }
                
                if Set(state.sportsInterests) != Set(state.userProfile.sportsInterests) {
                    state.userProfileUpdate.sportsInterests = state.sportsInterests
                } else {
                    state.userProfileUpdate.sportsInterests = nil
                }
                
                return .none
                
            case .submit:
                let userProfileUpdate = state.userProfileUpdate
                let tempImageUrl = state.tempImageUrl
                if userProfileUpdate.userHandle == nil &&
                    userProfileUpdate.bio == nil &&
                    userProfileUpdate.sportsInterests == nil &&
                    tempImageUrl == nil {
                    // 바뀐값이 하나도 없으면 그냥 return
                    // TODO: 버튼 비활성화로 애초에 실행이 안되게 수정 필요
                    return .none
                }
                
                return .run { send in
                    if tempImageUrl != nil {
                        await send(.uploadImage)
                    } else {
                        await send(.updateProfile())
                    }
                }
                
            case .uploadImage:
                guard let fileURL = state.tempFileURL else {
                    // TODO: 예외 처리
                    return .none
                }
                
                let userId = state.userProfile.userId
                return .run { send in
                    let key = "profiles/\(userId)/profile.jpg"
                    let result = await withCheckedContinuation { continuation in
                        AWSManager.shared.uploadImage(fileURL: fileURL, key: key) { result in
                            continuation.resume(returning: result)
                        }
                    }
                    
                    switch result {
                    case .success(let key):
                        print("Uploaded avatar URL: \(key)")
                        await send(.updateProfile(key: key))
                        
                    case .failure(let error):
                        print("Upload error: \(error)")
//                            try FileManager.default.removeItem(at: fileURL)
//                            await send(.delegate(.pop()))
                    }
                }
                
            case .updateProfile(let key):
                state.userProfileUpdate.profileImageUrl = key
                let userProfileUpdate = state.userProfileUpdate
                return .run { send in
                    do {
                        print(userProfileUpdate)
                        let result = try await userProfileClient.updateUserProfile(body: userProfileUpdate)
                        
                        await send(.delegate(.pop(userProfile: result)))
                    } catch {
                        
                    }
                }
                
            case .cancel:
                return .send(.delegate(.pop()))
                
            case .delegate:
                return .none
            }
        }
    }
}
