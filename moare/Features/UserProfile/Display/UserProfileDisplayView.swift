//
//  UserProfileDisplayView.swift
//  moare
//
//  Created by 최지혜 on 11/4/25.
//

import ComposableArchitecture
import SwiftUI

struct UserProfileDisplayView: View {
    let stackStore: StoreOf<UserProfileStackStore>
    let signStore: Store<SignStore.State?, SignStore.Action>
    let settingsStore: StoreOf<UserSettingsStore>
    
    @State private var userHandle = ""
    @State private var currentViewType: UserProfileViewType = .userProfile
    @State private var isSettingsPresented = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if currentViewType != .userProfileImageEdit {
                    HStack {
                        BackButton {
                            stackStore.send(.pop)
                        }
                        
                        if currentViewType != .userProfileUpdateForm {
                            Text(userHandle)
                                .font(.system(size: 20, weight: .medium))
                                .padding(.horizontal, 8)
                        }
                        
                        Spacer()
                        
                        if currentViewType != .userProfileUpdateForm {
                            Button(action: {
                                isSettingsPresented = true
                            }) {
                                Image(systemName: "gearshape")
                                    .padding(.trailing, 8)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
                
                if let userId = stackStore.userId {
                    if let id = stackStore.path.ids.last {
                        if let store = stackStore.scope(
                            state: \.path[id: id],
                            action: \.path[id: id]
                        ) {
                            UserProfilePathView(
                                store: store,
                                userId: userId,
                                userHandle: $userHandle
                            )
                            .padding(.top, currentViewType != .userProfileImageEdit ? 30 : 0)
                        }
                    }
                } else {
                    IfLetStore(signStore) { store in
                        SignView(store: store)
                    }
                }
            }
            
            UserSettingsView(store: settingsStore, isPresented: $isSettingsPresented)
        }
        .onAppear {
            if let token = KeychainManager.shared.get("accessToken"), !token.isEmpty {
                stackStore.send(.bootstrapSession)
            } else {
                stackStore.send(.delegate(.initSignStore))
            }
        }
        .onChange(of: stackStore.userId) {
            if let _ = stackStore.userId {
                if stackStore.path.ids.isEmpty {
                    stackStore.send(.push(.userProfile))
                }
            } else {
                isSettingsPresented = false
                stackStore.send(.emptyPath)
            }
        }
        .onChange(of: stackStore.path.ids.last) {
            if let id = stackStore.path.ids.last {
                if let store = stackStore.scope(
                    state: \.path[id: id],
                    action: \.path[id: id]
                ) {
                    currentViewType = switch store.state {
                    case .userProfile: .userProfile
                    case .moatDetail: .moatDetail
                    case .userProfileUpdateForm: .userProfileUpdateForm
                    case .userProfileImageEdit: .userProfileImageEdit
                    }
                }
            }
        }
    }
}

struct UserProfilePathView: View {
    let store: StoreOf<UserProfileStackStore.Path>
    let userId: String?
    
    @Binding var userHandle: String
    
    init (
        store: StoreOf<UserProfileStackStore.Path>,
        userId: String?,
        userHandle: Binding<String>
    ) {
        self.store = store
        self.userId = userId
        self._userHandle = userHandle
    }
    
    var body: some View {
        switch store.state {
        case .userProfile:
            if let s = store.scope(state: \.userProfile, action: \.userProfile) {
                UserProfileView(store: s, userId: userId, userHandle: $userHandle)
            }
        case .moatDetail:
            if let s = store.scope(state: \.moatDetail, action: \.moatDetail) {
                MoatView(store: s, userId: userId).id(UUID())
            }
        case .userProfileUpdateForm:
            if let s = store.scope(state: \.userProfileUpdateForm, action: \.userProfileUpdateForm) {
                UserProfileUpdateFormView(store: s)
            }
        case .userProfileImageEdit:
            if let s = store.scope(state: \.userProfileImageEdit, action: \.userProfileImageEdit) {
                UserProfileImageEditView(store: s)
            }
        }
    }
}
