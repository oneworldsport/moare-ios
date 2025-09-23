//
//  KBOPlayerStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOPlayerStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<KBOPlayerStatsStore>
    
    @State private var show = false

    var body: some View {
        ScrollView {
            InfoViewContainer(
                itemCount: store.baseStats.displayModel.stats.count + 1,
                measureContent: { scope in
                    if show {
                        KBOPlayerStatsPlayerInfoItem(kboPlayerStatsStore: store)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        scope.updateItemFrame(index: 0, geometry: geometry)
                                    }
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 0, geometry: geometry)
                                    }
                                }
                            )
                        
                        KBOPlayerStatsList(kboPlayerStatsStore: store, scope: scope)
                    }
                },
                displayContent: { scope in
                    if show {
                        KBOPlayerStatsPlayerInfoItem(
                            kboPlayerStatsStore: store,
                            isAniItem: true,
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        KBOPlayerStatsList(
                            kboPlayerStatsStore: store,
                            isAniItem: true,
                            scope: scope
                        )
                    }
                }
            )
        } // ScrollView
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct KBOPlayerStatsPlayerInfoItem: View {
    @Bindable var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool

    init(
        kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboPlayerStatsStore = kboPlayerStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let player = kboPlayerStatsStore.baseStats.displayModel.player
        let teamNameDic = kboPlayerStatsStore.baseStats.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HStack {
                URLImage(url: KBOUtil.playerPhotoURL(id: player.id))
                
                // name
                VStack(alignment: .leading) {
                    Text(player.name)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                
                URLImage(url: KBOUtil.teamLogoURL(id: player.teamId))
                
                // team, jersey, position
                VStack(alignment: .leading) {
                    Text(teamNameDic["full_\(player.teamId)"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    (
                        Text("등번호: ")
                            .font(.system(size: 15))
                        + Text(player.jersey)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    )
                    .multilineTextAlignment(.leading)
                    
                    (
                        Text("포지션: ")
                            .font(.system(size: 15))
                        + Text(player.position)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    )
                    .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity)
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct KBOPlayerStatsList: View {
    @Bindable var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>
    
    let isAniItem: Bool
    let scope: InfoViewScope
    
    init(
        kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>,
        isAniItem: Bool = false,
        scope: InfoViewScope,
    ) {
        self.kboPlayerStatsStore = kboPlayerStatsStore
        self.isAniItem = isAniItem
        self.scope = scope
    }
    
    var body: some View {
        let stats = kboPlayerStatsStore.baseStats.displayModel.stats
        
        ForEach(stats.indices, id: \.self) { index in
            let stats = stats[index]
            let itemIndex = index + 1
            
            KBOPlayerStatsListItem(
                kboPlayerStatsStore: kboPlayerStatsStore,
                stats: stats,
                isAniItem: isAniItem,
                itemSize: scope.itemSizes[itemIndex],
                itemOffset: scope.computedOffset(for: itemIndex),
                showContents: scope.showContents
            )
            .background(
                GeometryReader { geometry in
                    if !isAniItem {
                        // 1) 최초 한 번은 무조건 측정 - gpt
                        // NOTE: Color.clear.onChange()만 했을때는 update가 안돼서 Color.clear.onAppear 추가해줌
                        Color.clear.onAppear {
                            scope.updateItemFrame(index: itemIndex, geometry: geometry)
                        }
                        // 2) 위치 변하면 - gpt
                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                            scope.updateItemFrame(index: itemIndex, geometry: geometry)
                        }
                    }
                }
            )
        }
    }
}

struct KBOPlayerStatsListItem: View {
    @Bindable var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>
    
    let stats: KBOPlayerStats
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>,
        stats: KBOPlayerStats,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboPlayerStatsStore = kboPlayerStatsStore
        self.stats = stats
        self.isAniItem = isAniItem
        
        if isAniItem {
            self.itemSize = itemSize
            self.itemOffset = itemOffset
            self.showContents = showContents
        } else {
            self.itemSize = nil
            self.itemOffset = nil
            self.showContents = true
        }
    }
    
    var body: some View {
        MovingCapsuleItemContainer(
            isButton: false,
            isAniItem: isAniItem,
            itemOffset: itemOffset,
        ) {
            KBOPlayerStatsItem(
                kboPlayerStatsStore: kboPlayerStatsStore,
                stats: stats
            )
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct KBOPlayerStatsItem: View {
    @Bindable var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>
    
    let stats: KBOPlayerStats
    
    var body: some View {
        if let hitter = stats.hitter {
            HStack {
                BaseballLeagueTitle(
                    logoUrl: KBOUtil.kboLogoUrl,
                    name: "KBO",
                    season: stats.season
                )
                
                Text(" - [타자]")
                    .fontWeight(.medium)
            }
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: hitter.g,
                    customCategoryFontSize: 11,
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "타수",
                    data: hitter.ab,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "타율",
                    data: hitter.avg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "안타",
                    data: hitter.h,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "2루타",
                    data: hitter.double,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "3루타",
                    data: hitter.triple,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "홈런",
                    data: hitter.hr,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "출루율",
                    data: hitter.obp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "장타율",
                    data: hitter.slg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "ops",
                    data: hitter.ops,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "득점",
                    data: hitter.r,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "타점",
                    data: hitter.rbi,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "득점권 타율",
                    data: hitter.risp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "볼넷",
                    data: hitter.bb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "삼진",
                    data: hitter.so,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도루",
                    data: hitter.sb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도루 실패",
                    data: hitter.cs,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도루 성공률",
                    data: hitter.sbPercent,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "멀티히트",
                    data: hitter.mh,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "사구",
                    data: hitter.hbp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "희생번트",
                    data: hitter.sac,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "희생플라이",
                    data: hitter.sf,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "병살타",
                    data: hitter.gdp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "대타 타율",
                    data: hitter.phBa,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
        } // if let hitter
        
        if let pitcher = stats.pitcher {
            HStack {
                BaseballLeagueTitle(
                    logoUrl: KBOUtil.kboLogoUrl,
                    name: "KBO",
                    season: stats.season
                )
                
                Text(" - [투수]")
                    .fontWeight(.medium)
            }
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: pitcher.g,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "이닝",
                    data: pitcher.ip,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "평균자책",
                    data: pitcher.era,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "승",
                    data: pitcher.w,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "패",
                    data: pitcher.l,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "홀드",
                    data: pitcher.hld,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "세이브",
                    data: pitcher.sv,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "삼진",
                    data: pitcher.h,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "볼넷",
                    data: pitcher.bb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피안타",
                    data: pitcher.h,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피2루타",
                    data: pitcher.double,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피3루타",
                    data: pitcher.triple,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "피홈런",
                    data: pitcher.hr,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피안타율",
                    data: pitcher.avg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "실점",
                    data: pitcher.r,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "자책점",
                    data: pitcher.er,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "블론세이브",
                    data: pitcher.bsv,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "보크",
                    data: pitcher.bk,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "고의4구",
                    data: pitcher.ibb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "폭투",
                    data: pitcher.wp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "완투",
                    data: pitcher.cg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "완봉",
                    data: pitcher.sho,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "투구수",
                    data: pitcher.np,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "퀄리티 스타트",
                    data: pitcher.qs,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "이닝당 출루허용률",
                    data: pitcher.whip,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "승률",
                    data: pitcher.wpct,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 평균 투구수",
                    data: "\(pitcher.npsPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                    .opacity(0)
                EmptyStatDataItem()
                    .frame(maxWidth: .infinity)
                StatsDivider()
                    .opacity(0)
                EmptyStatDataItem()
                    .frame(maxWidth: .infinity)
                StatsDivider()
                    .opacity(0)
                EmptyStatDataItem()
                    .frame(maxWidth: .infinity)
            }
        } // if let hitter
    }
}
