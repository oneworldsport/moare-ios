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
    
    @AppStorage("accessToken") private var accessToken: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton {
                    userProfileStackStore.send(.pop)
                }
                
                Spacer()
            }
            
            if !accessToken.isEmpty {
                if let id = userProfileStackStore.path.ids.last {
                    if let store = userProfileStackStore.scope(state: \.path[id: id], action: \.path[id: id]) {
                        UserProfilePathView(store: store)
                    }
                }
            } else {
                SignView()
            }
            
        }
        .onAppear {
            if userProfileStackStore.state.path.isEmpty {
                userProfileStackStore.send(.push)
              }
        }
    }
}

struct UserProfilePathView: View {
    let store: StoreOf<UserProfileStackStore.Path>
    
    init (
        store: StoreOf<UserProfileStackStore.Path>
    ) {
        self.store = store
    }
    
    var body: some View {
        switch store.state {
        case .userProfile:
            if let s = store.scope(state: \.userProfile, action: \.userProfile) {
                UserProfileView(userProfileStore: s)
            }
        }
    }
}
