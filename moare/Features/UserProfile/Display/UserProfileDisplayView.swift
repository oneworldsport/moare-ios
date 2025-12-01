//
//  UserProfileDisplayView.swift
//  moare
//
//  Created by 최지혜 on 11/4/25.
//

import ComposableArchitecture
import SwiftUI

struct UserProfileDisplayView: View {
    let userProfileStackStore: StoreOf<UserProfileStackStore>
    
    @State private var userHandle = ""
    @State private var currentViewType: UserProfileViewType = .userProfile
    
    @AppStorage("accessToken") private var accessToken: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if currentViewType != .userProfileImageEdit {
                HStack {
                    BackButton {
                        userProfileStackStore.send(.pop)
                    }
                    
                    if currentViewType != .userProfileUpdateForm {
                        Text(userHandle)
                            .font(.system(size: 20, weight: .medium))
                            .padding(.horizontal, 8)
                    }
                    
                    Spacer()
                    
                    if currentViewType != .userProfileUpdateForm {
                        Image(systemName: "gearshape")
                            .padding(.trailing, 8)
                    }
                }
            }
            
            if !accessToken.isEmpty {
                if let id = userProfileStackStore.path.ids.last {
                    if let store = userProfileStackStore.scope(
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
        .onAppear {
            if !accessToken.isEmpty {
                userProfileStackStore.send(.bootstrapSession)
            }
        }
        .onChange(of: accessToken) {
            if accessToken.isEmpty {
                userProfileStackStore.send(.emptyPath)
            } else {
                if userProfileStackStore.path.ids.isEmpty {
                    userProfileStackStore.send(.push(.userProfile))
                }
            }
        }
        .onChange(of: userProfileStackStore.path.ids.last) {
            if let id = userProfileStackStore.path.ids.last {
                if let store = userProfileStackStore.scope(
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
