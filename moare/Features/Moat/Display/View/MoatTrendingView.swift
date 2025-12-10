//
//  MoatTrendingView.swift
//  moare
//
//  Created by 최지혜 on 12/5/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatTrendingView: View {
    @Bindable var store: StoreOf<MoatTrendingStore>
    @Bindable var fireStore: StoreOf<FireStore>
    
    let userId: String?
    
    @State private var show = false
    
    private var trendingMoats: [MoatResponse] {
        store.trendingMoats
    }
    
    private func firedBinding(moat: MoatResponse, target: FireTargetType) -> Binding<Bool> {
            Binding(
                get: { fireStore.fireMap[moat.moatId] ?? moat.isFired },
                set: { _ in }
            )
        }
    
    var body: some View {
        VStack(spacing: 0) {
            if show {
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack(spacing: 28) {
                                ForEach(trendingMoats, id: \.moatId) { (moat: MoatResponse) in
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
                                        fired: firedBinding(moat: moat, target: .moat),
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
                                        action: {
                                            store.send(.selectMoat(moatId: moat.moatId))
                                        }
                                    )
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    FloatingAddButton {
                        store.send(.showForm)
                    }
                    .padding(10)
                }
            }
        }
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
            if store.trendingMoats.isEmpty {
                store.send(.getTrendingMoats)
            }
        }
    }
}
