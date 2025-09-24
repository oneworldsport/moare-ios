//
//  KBOTeamStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTeamStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<KBOTeamStatsStore>
    
    @State private var show = false

    var body: some View {
        ScrollView {
            InfoViewContainer(
                itemCount: store.baseStats.displayModel.stats.count + 1,
                measureContent: { scope in
                    if show {
                        KBOTeamStatsPlayerInfoItem(kboTeamStatsStore: store)
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
                        
                        KBOTeamStatsList(kboTeamStatsStore: store, scope: scope)
                    }
                },
                displayContent: { scope in
                    if show {
                        // team info
                        KBOTeamStatsPlayerInfoItem(
                            kboTeamStatsStore: store,
                            isAniItem: true,
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        
                        // stats list
                        KBOTeamStatsList(
                            kboTeamStatsStore: store,
                            isAniItem: true,
                            scope: scope
                        )
                    }
                }
            )
        } // ScrollView
        .onAppear {
            store.send(.baseStats(.initData))
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct KBOTeamStatsPlayerInfoItem: View {
    @Bindable var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool

    init(
        kboTeamStatsStore: StoreOf<KBOTeamStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboTeamStatsStore = kboTeamStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = kboTeamStatsStore.baseStats.displayModel
        let teamNameDic = kboTeamStatsStore.baseStats.teamNameDictionary
        let team = displayModel.team
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HStack {
                URLImage(url: KBOUtil.teamLogoURL(id: team.id), isSvg: true)
                
                // name, city
                VStack(alignment: .leading) {
                    Text(teamNameDic["full_\(team.id)"] ?? team.teamName)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    HStack(spacing: 0) {
                        Text("연고지: ")
                            .font(.system(size: 15))
                        
                        Text(team.city)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                    
                    HStack(spacing: 0) {
                        Text("홈구장: ")
                            .font(.system(size: 15))
                        
                        Text(teamNameDic["venue_\(team.id)"] ?? displayModel.venue.name)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                }
            }
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct KBOTeamStatsList: View {
    @Bindable var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>
    
    let isAniItem: Bool
    let scope: InfoViewScope
    
    init(
        kboTeamStatsStore: StoreOf<KBOTeamStatsStore>,
        isAniItem: Bool = false,
        scope: InfoViewScope,
    ) {
        self.kboTeamStatsStore = kboTeamStatsStore
        self.isAniItem = isAniItem
        self.scope = scope
    }
    
    var body: some View {
        let stats = kboTeamStatsStore.baseStats.displayModel.stats
        
        ForEach(stats.indices, id: \.self) { index in
            let stats = stats[index]
            let itemIndex = index + 1
            
            KBOTeamStatsListItem(
                kboTeamStatsStore: kboTeamStatsStore,
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

struct KBOTeamStatsListItem: View {
    @Bindable var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>
    
    let stats: KBOTeamStats
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboTeamStatsStore: StoreOf<KBOTeamStatsStore>,
        stats: KBOTeamStats,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboTeamStatsStore = kboTeamStatsStore
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
            KBOTeamStatsItem(
                kboTeamStatsStore: kboTeamStatsStore,
                stats: stats
            )
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct KBOTeamStatsItem: View {
    @Bindable var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>
    
    let stats: KBOTeamStats
    
    @State private var isBasicStatsOpened = true
    @State private var isHitterStatsOpened = false
    @State private var isPitcherStatsOpened = false
    
    var body: some View {
        let rank = stats.rankData
        let hitting = stats.hitterData
        let pitching = stats.pitcherData
        let running = stats.runnerData
        
        BaseballLeagueTitle(
            logoUrl: KBOUtil.kboLogoUrl,
            name: "KBO",
            season: stats.season
        )
        
        // stats
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isBasicStatsOpened.toggle()
            }
        }) {
            Text("기본 기록")
            
            Image(systemName: "chevron.\(isBasicStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isBasicStatsOpened {
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "순위",
                    data: rank.rank,
                    customCategoryFontSize: 11,
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "승",
                    data: rank.wins,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "무",
                    data: rank.draws,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "패",
                    data: rank.losses,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기수",
                    data: rank.gp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "게임차",
                    data: rank.gb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "승률",
                    data: rank.winpct,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isHitterStatsOpened.toggle()
            }
        }) {
            Text("타자 기록")
            
            Image(systemName: "chevron.\(isHitterStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isHitterStatsOpened {
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "타율",
                    data: hitting.avg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "안타",
                    data: hitting.h,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "홈런",
                    data: hitting.hr,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "출루율",
                    data: hitting.obp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "장타율",
                    data: hitting.slg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "ops",
                    data: hitting.ops,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "득점권타율",
                    data: hitting.risp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "득점",
                    data: hitting.r,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "타점",
                    data: hitting.rbi,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "사구",
                    data: hitting.hbp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "병살타",
                    data: hitting.gdp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "삼진",
                    data: hitting.so,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도루성공",
                    data: running.sb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도루실패",
                    data: running.cs,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                    .opacity(0)
                EmptyStatDataItem()
                    .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isPitcherStatsOpened.toggle()
            }
        }) {
            Text("투수 기록")
            
            Image(systemName: "chevron.\(isPitcherStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isPitcherStatsOpened {
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "평균자책점",
                    data: pitching.era,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피안타율",
                    data: pitching.avg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피안타",
                    data: pitching.h,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피홈런",
                    data: pitching.hr,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "세이브",
                    data: pitching.sv,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "이닝당 출루허용률",
                    data: pitching.whip,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "볼넷",
                    data: pitching.bb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "보크",
                    data: pitching.bk,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "홀드",
                    data: pitching.hld,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "블론세이브",
                    data: pitching.bsv,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}
