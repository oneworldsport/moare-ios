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
    
    @State var text = ""
    @State private var settingsShowing = false
    @State private var reportShowing = false
    @State private var selectedMoatId: String? = nil
    @State private var inputText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if let userProfileStore {
                let userProfile = userProfileStore.userProfile
                let userMoats = userProfileStore.userMoats
                let selectedMoat = userProfileStore.selectedMoat
                let comments = selectedMoat?.commentListResponse?.moats ?? []
                
                HStack {
                    BackButton {
                        userProfileStore.send(.goBack)
                    }
                    
                    Spacer()
                }
                
                VStack(spacing: 0) {
                    if selectedMoat == nil {
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
                            .padding(.top, 8)
                    }
                                        
                    ScrollView {
                        LazyVStack(spacing: 28) {
                            ForEach(userMoats, id: \.moatId) { moat in
                                let lines = moat.content.components(separatedBy: "\n")
                                let title = lines.first ?? ""
                                let body = lines.dropFirst().joined(separator: "\n")
                                
                                MoatItem(
                                    moatType: selectedMoat != nil ? .detail : .timeline,
                                    isButtonDisabled: selectedMoat != nil,
                                    title: title,
                                    content: body,
                                    hashtagList: moat.sportType,
                                    fireCount: moat.fireCount,
                                    commentCount: moat.commentCount,
                                    nickname: moat.nickname,
                                    createdAt: moat.createdAt,
                                    settingsTapped: {
                                        selectedMoatId = moat.moatId
                                        settingsShowing = true
                                    }
                                ) {
                                    userProfileStore.send(.selectMoat(moatId: moat.moatId))
                                }
                            }
                        }
                        .padding(.top, 18) // 10 + 8 (side bar end height + extra space)
                    }
                    .scrollDisabled(selectedMoat != nil)
                    .frame(height: selectedMoat != nil ? 180 : nil)
                    
                    if selectedMoat != nil {
                        HDivider()
                            .padding(.top, 8)
                        
                        ScrollView {
                            LazyVStack(spacing: 28) {
                                ForEach(comments, id: \.moatId) { moat in
                                    MoatItem(
                                        moatType: .comment,
                                        content: moat.content,
                                        hashtagList: moat.sportType,
                                        fireCount: moat.fireCount,
                                        commentCount: moat.commentCount,
                                        nickname: moat.nickname,
                                        createdAt: moat.createdAt,
                                        settingsTapped: {
                                            
                                        }
                                    ) {
                                        userProfileStore.send(.selectMoat(isComment: true, moatId: moat.moatId))
                                    }
                                }
                            }
                            .padding(.top, 18) // 10 + 8 (side bar end height + extra space)
                            .padding(.bottom, 61) // 35 + 8 + 10 + 8 (firstLineHeight + bottom padding + side bar end height + extra space)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment : .topTrailing) {
                    if settingsShowing {
                        SettingWindow(reportTapped: {
                            reportShowing = true
                            settingsShowing = false
                        })
                        .padding(.top, 10)
                    }
                }
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
        .background(
            TextFieldAlert(isPresented: $reportShowing, text: $inputText, title: "모트 신고하기")
        )
    }
}

#Preview {
    UserProfileView()
}
