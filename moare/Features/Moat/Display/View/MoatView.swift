//
//  MoatView.swift
//  moare
//
//  Created by 최지혜 on 8/29/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatView: View {
    @Bindable var store: StoreOf<MoatStore>
    let userId: String?
    
    @State private var show = false
    @State var text = ""
    @State private var selectedMoatId: String? = nil
    @State private var inputText = ""
    
    // TODO: store에서 action을 통해 애니메이션을 주는걸로 바꿔야함
    @State private var commentsToDisplay: [MoatResponse] = []
    
    var body: some View {
        VStack(spacing: 0) {
            if show {
                ZStack(alignment: .bottomTrailing) {
                    let trendingMoats = store.trendingMoats
                    let selectedMoat = store.selectedMoat
                    let comments = selectedMoat?.commentListResponse?.moats ?? []
                    
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack(spacing: 28) {
                                ForEach(trendingMoats, id: \.moatId) { moat in
                                    let lines = moat.content.components(separatedBy: "\n")
                                    let title = lines.first ?? ""
                                    let body = lines.dropFirst().joined(separator: "\n")
                                    
                                    let firedBinding = Binding<Bool>(
                                        get: { store.state.fireMap[moat.moatId] ?? false },
                                        set: { newValue in store.send(.setFired(targetId: moat.moatId, isFired: newValue)) }
                                      )
                                    
                                    let fireCount = store.state.fireCountMap[moat.moatId] ?? moat.fireCount
                                    
                                    let onSettings: (SettingItems) -> Void = { item in
                                        selectedMoatId = moat.moatId
                                        store.send(.settingItemsTapped(item: item, moatId: moat.moatId))
                                    }
                                    
//                                    let isSelectedMoatDeleted = store.isDetail && store.isDeletedMoat
//                                    
//                                    if isSelectedMoatDeleted {
//                                        DeletedMoatItem()
//                                            .frame(maxWidth: .infinity, alignment: .center)
//                                    } else {
                                        MoatItem(
                                            userId: userId,
                                            moatUserId: moat.userId,
                                            moatType: selectedMoat != nil ? .detail : .trending,
                                            isButtonDisabled: selectedMoat != nil,
                                            title: title,
                                            content: body,
                                            hashtagList: moat.sportTags,
                                            fired: firedBinding,
                                            fireCount: fireCount,
                                            commentCount: moat.commentCount,
                                            userHandle: moat.userHandle,
                                            createdAt: moat.createdAt,
                                            settingsTapped: { item in
                                                    selectedMoatId = moat.moatId
                                                    store.send(.settingItemsTapped(item: item, moatId: moat.moatId))
                                            },
                                            fireTapped: {
                                                print("fire tapped")
                                                store.send(.toggleFire(targetId: moat.moatId, targetType: .moat))
                                            },
                                            action: {
                                                store.send(.selectMoat(moatId: moat.moatId))
                                            }
                                        )
//                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                        .scrollDisabled(selectedMoat != nil)
                        .frame(height: selectedMoat != nil ? 180 : nil)
                        
                        if selectedMoat != nil {
                            //                            if !commentsToDisplay.isEmpty {
                            HDivider()
                                .padding(.top, 8)
                            
                            ScrollView {
                                LazyVStack(spacing: 28) {
                                    ForEach(comments, id: \.moatId) { moat in
                                        let firedBinding = Binding<Bool>(
                                            get: { store.state.fireMap[moat.moatId] ?? false },
                                            set: { newValue in store.send(.setFired(targetId: moat.moatId, isFired: newValue)) }
                                          )
                                        
                                        let fireCount = store.state.fireCountMap[moat.moatId] ?? moat.fireCount
                                        
                                        MoatItem(
                                            userId: userId,
                                            moatUserId: moat.userId,
                                            moatType: .comment,
                                            content: moat.content,
                                            hashtagList: moat.sportTags,
                                            fired: firedBinding,
                                            fireCount: fireCount,
                                            commentCount: moat.commentCount,
                                            userHandle: moat.userHandle,
                                            createdAt: moat.createdAt,
                                            settingsTapped: { item in
                                            },
                                            fireTapped: {
                                                print("fire tapped")
                                                store.send(.toggleFire(targetId: moat.moatId, targetType: .comment))
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
                    }
                    //                        .onChange(of: store.selectedMoat) {
                    //                            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    //                                commentsToDisplay = store.selectedMoat?.comments?.items ?? []
                    //                            }
                    //                        }
                    
                    if store.isDetail {
                        CommentComposer(text: $text) {
                            store.send(.createMoat(content: text))
                        }
                    } else {
                        FloatingAddButton {
                            store.send(.showForm)
                        }
                        .padding(10)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
            
            if let moatId = store.moatId {
                // TODO: 뒤로가기를 통해 detail로 왔을때도 불필요하게 실행됨. 불필요한게 아닐수도 있지만 그래도 고민은 해봐야 할 것 같음.
                store.send(.getMoatDetail(moatId: moatId))
            } else {
                if store.originalTrendingMoats.isEmpty {
                    store.send(.getTrendingMoats)
                }
            }
        }
        .background(
            TextFieldAlert(isPresented: $store.reportPresenting, text: $inputText, title: "모트 신고하기")
        )
    }
}
