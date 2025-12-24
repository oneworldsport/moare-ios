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
    let fireStore: StoreOf<FireStore>
    let userId: String?
    
    @Binding var userHandle: String
    
    @State private var show = false
    @State var text = ""
    @State private var settingsShowing = false
    
    @State private var inputText = ""
    @State private var fired = false
    
    var body: some View {
        VStack(spacing: 0) {
            if show {
                let userProfile = store.userProfile
                let userMoats = store.userMoats
                let profileImageUrl = userProfile?.profileImageUrl != nil ? "https://moare-sns-profile-images.s3.ap-northeast-2.amazonaws.com/\(userProfile!.profileImageUrl!)" : nil
                
                VStack(spacing: 0) {
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
                            // 여기 버그있음
                            let profileOwnerId = store.targetUserId ?? userId
                            
                            let isOwner = (profileOwnerId == store.userId)
                            
                            let itemsToShow: [UserProfileSettingItems] = {
                                if isOwner {
                                    return [.updateProfile]
                                } else {
                                    return [.report]
                                }
                            }()
                            
                            Menu {
                                ForEach(itemsToShow, id: \.self) { item in
                                    Button(action: {
                                        store.send(.settingItemsTapped(item: item))
                                    }) {
                                        Text("\(item.title)")
                                    }
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
                                        
                    ScrollView {
                        LazyVStack(spacing: 28) {
                            ForEach(userMoats, id: \.moatId) { moat in
                                let lines = moat.content.components(separatedBy: "\n")
                                let title = lines.first ?? ""
                                let body = lines.dropFirst().joined(separator: "\n")
                                
                                MoatItem(
                                    userId: userId,
                                    moatUserId: moat.userId,
                                    moatType: .trending,
                                    isButtonDisabled: false,
                                    title: title,
                                    content: body,
                                    hashtagList: moat.sportTags,
                                    fired: fireStore.fireMap[moat.moatId] ?? moat.isFired, // 여기도 확인
                                    fireCount: fireStore.fireCountMap[moat.moatId] ?? moat.fireCount,
                                    commentCount: moat.commentCount,
                                    userHandle: moat.userHandle,
                                    createdAt: moat.createdAt,
                                    settingsTapped: { _ in },
                                    fireTapped: {
                                        fireStore.send(.toggle(
                                            id: moat.moatId,
                                            targetType: .moat,
                                            baseIsFired: moat.isFired,
                                            baseCount: moat.fireCount
                                        ))
                                    },
                                    profileTapped: {},
                                ) {
                                    store.send(.selectMoat(moatId: moat.moatId))
                                }
                            }
                        }
                        .padding(.top, 18) // 10 + 8 (side bar end height + extra space)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
            
            // TODO: 다른 view 갔다오면 불필요하게 실행될 여지 있음. 개선 필요함.
            if store.userMoats.isEmpty && store.targetUserId == nil {
                store.send(.getUserProfile) // 내 프로필
            } else if store.targetUserId != nil {
                store.send(.getMoatUserProfile(targetUserId: store.targetUserId!)) // 다른 사람 프로필
            }
        }
        .onChange(of: store.userProfile?.userHandle) {
            userHandle = store.userProfile?.userHandle ?? ""
        }
    }
}

//#Preview {
//    UserProfileView()
//}
