//
//  MoatTimelineView.swift
//  moare
//
//  Created by 최지혜 on 8/29/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State var moatStore: StoreOf<MoatStore>? = nil
    
    @AppStorage("accessToken") private var accessToken: String = ""
    
    @State var text = ""
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let moatStore {
                let timelineMoats = moatStore.timelineMoats
                let selectedMoat = moatStore.selectedMoat
                let comments = selectedMoat?.comments?.items ?? []
                
                if !accessToken.isEmpty {
                    VStack {
                        ScrollView {
                            LazyVStack(spacing: 28) {
                                ForEach(timelineMoats, id: \.moatId) { moat in
                                    MoatItem(
                                        moatType: selectedMoat != nil ? .detail : .timeline,
                                        isButtonDisabled: selectedMoat != nil,
                                        title: "test",
                                        content: moat.content,
                                        hashtagList: moat.sportType,
                                        fireCount: moat.fireCount,
                                        commentCount: moat.commentCount,
                                        nickname: moat.nickname,
                                        createdAt: moat.createdAt,
                                    ) {
                                        moatStore.send(.selectMoat(moatId: moat.moatId))
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                        .scrollDisabled(selectedMoat != nil)
                        .frame(height: selectedMoat != nil ? 180 : nil)
                        
                        if selectedMoat != nil {
                            HDivider()
                            
                            ScrollView {
                                LazyVStack(spacing: 28) {
                                    ForEach(comments, id: \.moatId) { moat in
                                        MoatItem(
                                            moatType: .comment,
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
                    }
                    
                    if moatStore.currentViewType == .timeline {
                        FloatingAddButton {
                            moatStore.send(.addViewStack(viewType: .form))
                        }
                        .padding(10)
                    } else if moatStore.currentViewType == .form {
                        FormView()
                    } else if moatStore.currentViewType == .detail {
                        CommentComposer(text: $text) {
                            moatStore.send(.createMoat(content: text))
                        }
                    }
                } else {
                    SignView()
                        .environmentObject(storeManager)
                }
            }
        }
        .onAppear {
            let moatStore: StoreOf<MoatStore> = storeManager.getStore(forKey: StoreKeys.moatStore) ?? {
                let newStore = Store(initialState: MoatStore.State()) {
                    MoatStore()
                }
                
                storeManager.setStore(newStore, forKey: StoreKeys.moatStore)
                
                return newStore
            }()
            
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                self.moatStore = moatStore
            }
            
            moatStore.send(.getTimelineMoats)
//            moatStore.send(.deleteToken)
        }
    }
}
