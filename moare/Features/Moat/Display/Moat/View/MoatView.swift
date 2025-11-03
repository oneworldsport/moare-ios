//
//  MoatTimelineView.swift
//  moare
//
//  Created by 최지혜 on 8/29/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatView: View {
    let moatStackStore: StoreOf<MoatStackStore>
    let moatStore: StoreOf<MoatStore>
    
    @AppStorage("accessToken") private var accessToken: String = ""
    
    @State private var show = false
    @State var text = ""
    @State private var settingsShowing = false
    @State private var reportShowing = false
    @State private var selectedMoatId: String? = nil
    @State private var inputText = ""
    
    // TODO: store에서 action을 통해 애니메이션을 주는걸로 바꿔야함
    @State private var commentsToDisplay: [MoatResponse] = []
    
    var body: some View {
        VStack(spacing: 0) {
            if show {
                HStack {
                    BackButton {
                        moatStore.send(.goBack)
                    }
                    
                    Spacer()
                }
                
                ZStack(alignment: .bottomTrailing) {
                    let timelineMoats = moatStore.timelineMoats
                    let selectedMoat = moatStore.selectedMoat
                    let comments = selectedMoat?.commentListResponse?.moats ?? []
                    
                    if !accessToken.isEmpty {
                        VStack(spacing: 0) {
                            ScrollView {
                                LazyVStack(spacing: 28) {
                                    ForEach(timelineMoats, id: \.moatId) { moat in
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
                                            },
                                            action: {
                                                moatStore.send(.selectMoat(moatId: moat.moatId))
                                            }
                                        )
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
                                            MoatItem(
                                                moatType: .comment,
                                                content: moat.content,
                                                hashtagList: moat.sportType,
                                                fireCount: moat.fireCount,
                                                commentCount: moat.commentCount,
                                                nickname: moat.nickname,
                                                createdAt: moat.createdAt,
                                                settingsTapped: {}
                                            ) {
                                                moatStore.send(.selectMoat(isComment: true, moatId: moat.moatId))
                                            }
                                        }
                                    }
                                    .padding(.top, 18) // 10 + 8 (side bar end height + extra space)
                                    .padding(.bottom, 61) // 35 + 8 + 10 + 8 (firstLineHeight + bottom padding + side bar end height + extra space)
                                }
                            }
                        }
//                        .onChange(of: moatStore.selectedMoat) {
//                            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
//                                commentsToDisplay = moatStore.selectedMoat?.comments?.items ?? []
//                            }
//                        }
                        
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
                    }
                }
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
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
            
            moatStore.send(.getTimelineMoats)
//            moatStore.send(.deleteToken)
        }
        .background(
            TextFieldAlert(isPresented: $reportShowing, text: $inputText, title: "모트 신고하기")
        )
    }
}
