//
//  UserProfileView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

struct UserProfileView: View {
    let store: StoreOf<UserProfileStore>
    
    @Binding var userHandle: String
    
    @State private var show = false
    @State var text = ""
    @State private var settingsShowing = false
    
    @State private var selectedMoatId: String? = nil
    @State private var inputText = ""
    @State private var fired = false
    
    var body: some View {
        VStack(spacing: 0) {
            if show {
                let userProfile = store.userProfile
                let userMoats = store.userMoats
                let selectedMoat = store.selectedMoat
                let comments = selectedMoat?.commentListResponse?.moats ?? []
                let profileImageUrl = userProfile?.profileImageUrl != nil ? "https://moare-sns-profile-images.s3.ap-northeast-2.amazonaws.com/\(userProfile!.profileImageUrl!)" : nil
                
                VStack(spacing: 0) {
                    if selectedMoat == nil {
                        HStack {
                            ProfileImage(url: profileImageUrl)
                            
                            if let bio = userProfile?.bio {
                                // TODO: 더보기 버튼 만들어서 클릭 시 늘어나게?
                                Text(bio)
                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                            }
                            
                            VStack {
                                Menu {
                                    Button(action: {
                                        store.send(.showUserProfileUpdateForm)
                                    }) {
                                        Text("프로필 수정")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .frame(width: 24, height: 24)
                                }
                                .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                        }
                        .frame(height: 80)
                        .padding(.horizontal, 8)
                        
                        if let sports = userProfile?.sportsInterests, !sports.isEmpty {
                            HStack {
                                ForEach(sports.indices, id: \.self) { index in
                                    let sport = sports[index]
                                    
                                    Text(sport)
                                    
                                    if index != sports.count - 1 {
                                        Capsule()
                                            .frame(width: 2, height: 15)
                                            .foregroundColor(.primary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 8)
                        }
                        
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
                                    moatType: selectedMoat != nil ? .detail : .trending,
                                    isButtonDisabled: selectedMoat != nil,
                                    title: title,
                                    content: body,
                                    hashtagList: moat.sportTags,
                                    fired: $fired,
                                    fireCount: moat.fireCount,
                                    commentCount: moat.commentCount,
                                    userHandle: moat.userHandle,
                                    createdAt: moat.createdAt,
                                    settingsTapped: { item in
                                        selectedMoatId = moat.moatId
                                        settingsShowing = true
                                    },
                                    fireTapped: {}
                                ) {
                                    store.send(.selectMoat(moatId: moat.moatId))
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
                                        hashtagList: moat.sportTags,
                                        fired: $fired,
                                        fireCount: moat.fireCount,
                                        commentCount: moat.commentCount,
                                        userHandle: moat.userHandle,
                                        createdAt: moat.createdAt,
                                        settingsTapped: { item in
                                        },
                                        fireTapped: {}
                                    ) {
                                        store.send(.selectMoat(moatId: moat.moatId))
                                    }
                                }
                            }
                            .padding(.top, 18) // 10 + 8 (side bar end height + extra space)
                            .padding(.bottom, 61) // 35 + 8 + 10 + 8 (firstLineHeight + bottom padding + side bar end height + extra space)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .overlay(alignment : .topTrailing) {
//                    if settingsShowing {
//                        SettingWindow(reportTapped: {
//                            reportShowing = true
//                            settingsShowing = false
//                        })
//                        .padding(.top, 10)
//                    }
//                }
            }
        }
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
            
            // TODO: 다른 view 갔다오면 불필요하게 실행될 여지 있음. 개선 필요함.
            if store.originalUserMoats.isEmpty {
                store.send(.getUserProfile)
            }
        }
        .onChange(of: store.userProfile?.userHandle) {
            userHandle = store.userProfile?.userHandle ?? ""
        }
//        .background(
//            TextFieldAlert(isPresented: $reportShowing, text: $inputText, title: "모트 신고하기")
//        )
    }
}

//#Preview {
//    UserProfileView()
//}
