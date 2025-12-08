//
//  AppStore.swift
//  moare
//
//  Created by Mohwa Yoon on 12/7/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppStore {
    @ObservableState
    struct State {
        var search = SearchStackStore.State()
        var moat = MoatStackStore.State()
        var userProfile = UserProfileStackStore.State()
        
        var sign: SignStore.State?
        var settings = UserSettingsStore.State()
        
        var userId: String?
    }
    
    enum Action {
        case search(SearchStackStore.Action)
        case moat(MoatStackStore.Action)
        case userProfile(UserProfileStackStore.Action)
        
        case sign(SignStore.Action)
        case settings(UserSettingsStore.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.search, action: \.search) { SearchStackStore() }
        Scope(state: \.moat, action: \.moat) { MoatStackStore() }
        Scope(state: \.userProfile, action: \.userProfile) { UserProfileStackStore() }
        Scope(state: \.settings, action: \.settings) { UserSettingsStore() }
        
        Reduce { state, action in
            switch action {
            case let .sign(.delegate(.login(access, refresh, id, userId))):
                // TODO: Dependancy 사용하게 수정 필요
                KeychainManager.shared.set(access, for: "accessToken")
                KeychainManager.shared.set(refresh, for: "refreshToken")
                KeychainManager.shared.set(id, for: "idToken")
                
                state.userId = userId
                state.moat.userId = userId
                state.userProfile.userId = userId
                state.sign = nil
                
                return .none
                
            case let .moat(.delegate(.login(userId))),
                let .userProfile(.delegate(.login(userId))):
                state.userId = userId
                state.moat.userId = userId
                state.userProfile.userId = userId
                state.sign = nil
                
                return .none
                
            case .moat(.delegate(.initSignStore)),
                    .userProfile(.delegate(.initSignStore)):
                state.sign = SignStore.State()
                
                return .none
                
            case .settings(.delegate(.logout)):
                KeychainManager.shared.deleteAllTokens()
                
                state.sign = SignStore.State()
                state.userId = nil
                state.moat.userId = nil
                state.userProfile.userId = nil
                
                return .none
                
            case .settings(.delegate(.close)):
                state.settings = UserSettingsStore.State()
                
                return .none

            case .search:
                return .none
            case .moat:
                return .none
            case .userProfile:
                return .none
            case .sign:
                return .none
            case .settings:
                return .none
            }
        }
        .ifLet(\.sign, action: \.sign) { SignStore() }
    }
}
