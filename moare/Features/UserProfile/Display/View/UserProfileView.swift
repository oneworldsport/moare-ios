//
//  UserProfileView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

struct UserProfileView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State var userProfileStore: StoreOf<UserProfileStore>? = nil
    
    var body: some View {
        VStack {
            if let userProfileStore {
                let userProfile = userProfileStore.userProfile
                let userMoats = userProfileStore.userMoats?.items ?? []
                
                VStack {
                    HStack(alignment: .top) {
                        Circle()
                            .fill(.moare)
                            .frame(width: 80, height: 80)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(userProfile?.nickname ?? "")
                                
                                Spacer()
                                
                                Image(systemName: "gearshape")
                                    .font(.system(size: 24))
                            }
                            
                            Spacer()
                            
                            if let sports = userProfile?.sportsInterests, !sports.isEmpty {
                                ForEach(sports, id: \.self) { sport in
                                    Text(sport)
                                }
                            }
                        }
                    }
                    .frame(height: 80)
                    .padding(.horizontal, 8)
                    
                    HDivider()
                    
                    ScrollView {
                        LazyVStack(spacing: 28) {
                            ForEach(userMoats, id: \.moatId) { moat in
                                MoatItem(
                                    moatType: .userProfile,
                                    title: "test",
                                    content: moat.content,
                                    hashtagList: moat.sportType,
                                    fireCount: moat.fireCount,
                                    commentCount: moat.commentCount,
                                    nickname: moat.nickname,
                                    createdAt: moat.createdAt,
                                ) {
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            let userProfileStore: StoreOf<UserProfileStore> = storeManager.getStore(forKey: StoreKeys.userProfileStore) ?? {
                let newStore = Store(initialState: UserProfileStore.State()) {
                    UserProfileStore()
                }
                
                storeManager.setStore(newStore, forKey: StoreKeys.userProfileStore)
                
                return newStore
            }()
            
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                self.userProfileStore = userProfileStore
            }
            
            userProfileStore.send(.getUserProfile)
        }
    }
}

#Preview {
    UserProfileView()
}
