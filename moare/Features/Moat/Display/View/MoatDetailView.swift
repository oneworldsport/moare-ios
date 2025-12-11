//
//  MoatDetailView.swift
//  moare
//
//  Created by 최지혜 on 12/8/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatDetailView: View {
    @Bindable var store: StoreOf<MoatDetailStore>
    @Bindable var fireStore: StoreOf<FireStore>
    
    let userId: String?
    
    @State var text = ""
    @State private var inputText = ""
    
    private var moat: MoatResponse? {
        // moatDetailResponse : 트렌딩 -> 디테일 모트
        // moatResponse : 모트 작성 후의 디테일 모트
        store.moatDetailResponse?.moat ?? store.moatResponse
    }
    
    private var comments: [MoatResponse] {
        store.moatDetailResponse?.commentListResponse?.moats ?? []
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                if let moat = moat {
                    let lines = moat.content.components(separatedBy: "\n")
                    let title = lines.first ?? ""
                    let body = lines.dropFirst().joined(separator: "\n")
                    
                    MoatItem(
                        userId: userId,
                        moatUserId: moat.userId,
                        moatType: .detail,
                        isButtonDisabled: true,
                        title: title,
                        content: body,
                        hashtagList: moat.sportTags,
                        fired: moat.isFired,
                        fireCount: moat.fireCount,
                        commentCount: moat.commentCount,
                        userHandle: moat.userHandle,
                        createdAt: moat.createdAt,
                        settingsTapped: { item in
                            
                            store.send(.settingItemsTapped(item: item, moatId: moat.moatId))
                        },
                        fireTapped: {
                            store.send(.fireToggle(moatId: moat.moatId, targetType: .moat))
                            
                            fireStore.send(.toggle(
                                id: moat.moatId,
                                targetType: .moat,
                                baseIsFired: moat.isFired,
                                baseCount: moat.fireCount
                            ))
                        },
                        action: {}
                    )
                    .padding(.top, 10)
                    .frame(height: 180)
                }
                
                HDivider()
                    .padding(.top, 8)
                
                ScrollView {
                    LazyVStack(spacing: 28) {
                        ForEach(comments, id: \.moatId) { (moat: MoatResponse) in
                            MoatItem(
                                userId: userId,
                                moatUserId: moat.userId,
                                moatType: .comment,
                                content: moat.content,
                                hashtagList: moat.sportTags,
                                fired: moat.isFired,
                                fireCount: moat.fireCount,
                                commentCount: moat.commentCount,
                                userHandle: moat.userHandle,
                                createdAt: moat.createdAt,
                                settingsTapped: { item in
                                },
                                fireTapped: {
                                    store.send(.fireToggle(moatId: moat.moatId, targetType: .comment))
                                    
                                    fireStore.send(.toggle(
                                        id: moat.moatId,
                                        targetType: .comment,
                                        baseIsFired: moat.isFired,
                                        baseCount: moat.fireCount
                                    ))
                                },
                            ) {
                                store.send(.selectMoat(moatId: moat.moatId))
                            }
                        }
                    }
                    .padding(.top, 18) // 10 + 8 (side bar end height + extra space)
                    .padding(.bottom, 61) // 35 + 8 + 10 + 8 (firstLineHeight + bottom padding + side bar end height + extra space)
                }
            }
            CommentComposer(text: $text) {
                store.send(.createMoat(content: text))
            }
        }
        .background(
            TextFieldAlert(
                isPresented: $store.reportPresenting,
                text: $inputText,
                title: "모트 신고하기",
                onSubmit: { value in
                    store.send(.reportSuccess(reasonText: value))
                }
            )
        )
    }
}
