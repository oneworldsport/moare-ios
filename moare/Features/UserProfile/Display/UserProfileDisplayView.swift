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
    
    @State private var userHandle = ""
    @State private var currentViewType: UserProfileViewType = .userProfile
    @State private var isSettingsPresented = false
    
    @AppStorage("accessToken") private var accessToken: String = ""
    
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
                
                if !accessToken.isEmpty {
                    if let id = stackStore.path.ids.last {
                        if let store = stackStore.scope(
                            state: \.path[id: id],
                            action: \.path[id: id]
                        ) {
                            UserProfilePathView(
                                store: store,
                                userHandle: $userHandle
                            )
                            .padding(.top, currentViewType != .userProfileImageEdit ? 30 : 0)
                        }
                    }
                } else {
                    SignView()
                }
            }
            
            UserSettingsView(isPresented: $isSettingsPresented)
        }
        .onAppear {
            if !accessToken.isEmpty {
                stackStore.send(.bootstrapSession)
            }
        }
        .onChange(of: accessToken) {
            if accessToken.isEmpty {
                isSettingsPresented = false
                stackStore.send(.emptyPath)
            } else {
                if stackStore.path.ids.isEmpty {
                    stackStore.send(.push(.userProfile))
                }
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
    
    @Binding var userHandle: String
    
    init (
        store: StoreOf<UserProfileStackStore.Path>,
        userHandle: Binding<String>
    ) {
        self.store = store
        self._userHandle = userHandle
    }
    
    var body: some View {
        switch store.state {
        case .userProfile:
            if let s = store.scope(state: \.userProfile, action: \.userProfile) {
                UserProfileView(store: s, userHandle: $userHandle)
            }
        case .moatDetail:
            if let s = store.scope(state: \.moatDetail, action: \.moatDetail) {
                MoatView(store: s).id(UUID())
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
