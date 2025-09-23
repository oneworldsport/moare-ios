//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<NBAPlayerStatsStore>
    
//    var startOffset = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    @State private var show = false
    
    var body: some View {
        ScrollView {
            InfoViewContainer(
                itemCount: store.baseStats.displayModel.stats.count + 1,
                shouldShowMeasureContent: true,
                measureContent: { scope in
                    if show {
                        NBAPlayerStatsPlayerInfoItem(nbaPlayerStatsStore: store)
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
                        
                        NBAPlayerStatsList(nbaPlayerStatsStore: store, scope: scope)
                    }
                }, displayContent: { scope in
                    if show {
                        // player info
                        NBAPlayerStatsPlayerInfoItem(
                            nbaPlayerStatsStore: store,
                            isAniItem: true,
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        
                        // stats list
                        NBAPlayerStatsList(
                            nbaPlayerStatsStore: store,
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

struct NBAPlayerStatsPlayerInfoItem: View {
    @Bindable var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool

    init(
        nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaPlayerStatsStore = nbaPlayerStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let playerNameDic = nbaPlayerStatsStore.baseStats.playerNameDictionary
        let teamNameDic = nbaPlayerStatsStore.baseStats.teamNameDictionary
        let player = nbaPlayerStatsStore.baseStats.displayModel.player
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HStack {
                URLImage(url: NBAUtil.playerPhotoURL(id: player.personId))
                
                // name
                VStack(alignment: .leading) {
                    Text(playerNameDic["\(player.personId)"] ?? player.displayFirstLast)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    Text(player.displayFirstLast)
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .lineLimit(2)
                    
                    HStack {
                        Text("국적: ")
                            .font(.system(size: 15))
                        
                        Text(player.country)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                }
                
                URLImage(url: NBAUtil.teamLogoURL(id: player.teamId), isSvg: true)
                
                // nationality, team, jersey, position
                VStack(alignment: .leading) {
                    Text(teamNameDic["full_\(player.teamId)"] ?? "\(player.teamCity) \(player.teamName)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    HStack(spacing: 0) {
                        Text("등번호: ")
                            .font(.system(size: 15))
                        
                        Text(player.jersey)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                    
                    HStack(spacing: 0) {
                        Text("포지션: ")
                            .font(.system(size: 15))
                        
                        Text(player.position)
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

struct NBAPlayerStatsList: View {
    @Bindable var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>
    
    let isAniItem: Bool
    let scope: InfoViewScope
    
    init(
        nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>,
        isAniItem: Bool = false,
        scope: InfoViewScope,
    ) {
        self.nbaPlayerStatsStore = nbaPlayerStatsStore
        self.isAniItem = isAniItem
        self.scope = scope
    }
    
    var body: some View {
        let statsList = nbaPlayerStatsStore.baseStats.displayModel.stats
         
        ForEach(statsList.indices, id: \.self) { index in
            let stats = statsList[index]
            let itemIndex = index + 1
            
            NBAPlayerStatsListItem(
                nbaPlayerStatsStore: nbaPlayerStatsStore,
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

struct NBAPlayerStatsListItem: View {
    @Bindable var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>
    
    let stats: NBAPlayerStats
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>,
        stats: NBAPlayerStats,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaPlayerStatsStore = nbaPlayerStatsStore
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
            NBAPlayerStatsItem(
                nbaPlayerStatsStore: nbaPlayerStatsStore,
                stats: stats
            )
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct NBAPlayerStatsItem: View {
    @Bindable var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>
    
    let stats: NBAPlayerStats
    
    @State private var isAttackStatsOpened = true
    @State private var isDefendStatsOpened = false
    @State private var isPenaltyStatsOpened = false
    @State private var isEtcStatsOpened = false
    
    var body: some View {
        // league
        NBATitle(
            leagueName: "NBA 정규시즌",
            leagueSeason: Int(stats.groupValue.split(separator: "-").first ?? "\(CalendarUtil.currentYear)")!
        )
        
        // stats
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isAttackStatsOpened.toggle()
            }
        }) {
            Text("공격 기록")
            
            Image(systemName: "chevron.\(isAttackStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isAttackStatsOpened {
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "경기당 득점",
                    data: "\(stats.ptsPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 공격 리바운드",
                    data: "\(stats.orebPG)",
                    customCategoryFontSize: 11,
                    customWidth: 60
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 어시스트",
                    data: "\(stats.astPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 야투 시도",
                    data: "\(stats.fgaPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 야투 성공",
                    data: "\(stats.fgmPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "야투 성공률",
                    data: "\(stats.fgPct)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "경기당 3점 시도",
                    data: "\(stats.fg3aPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 3점 성공",
                    data: "\(stats.fg3mPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "3점 성공률",
                    data: "\(stats.fg3Pct)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 자유투 시도",
                    data: "\(stats.ftaPG)",
                    customCategoryFontSize: 11,
                    customWidth: 60
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 자유투 성공",
                    data: "\(stats.ftmPG)",
                    customCategoryFontSize: 11,
                    customWidth: 60
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "자유투 성공률",
                    data: "\(stats.ftPct)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isDefendStatsOpened.toggle()
            }
        }) {
            Text("수비 기록")
            
            Image(systemName: "chevron.\(isDefendStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isDefendStatsOpened {
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "경기당 수비 리바운드",
                    data: "\(stats.drebPG)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 블록",
                    data: "\(stats.blkPG)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 스틸",
                    data: "\(stats.stlPG)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isPenaltyStatsOpened.toggle()
            }
        }) {
            Text("패널티 기록")
            
            Image(systemName: "chevron.\(isPenaltyStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isPenaltyStatsOpened {
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "경기당 턴오버",
                    data: "\(stats.tovPG)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 파울",
                    data: "\(stats.pfPG)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 피블록",
                    data: "\(stats.blkaPG)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isEtcStatsOpened.toggle()
            }
        }) {
            Text("공통/기타 기록")
            
            Image(systemName: "chevron.\(isEtcStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isEtcStatsOpened {
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "경기수",
                    data: "\(stats.gp)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 출전시간",
                    data: stats.minPG,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 리바운드",
                    data: "\(stats.rebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "(출전 경기)승",
                    data: "\(stats.wins)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "(출전 경기)패",
                    data: "\(stats.losses)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "(출전 경기)승률",
                    data: "\(stats.winsPct)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack(spacing: 0) {
                FBStatDataItem(
                    category: "경기당 파울 유도",
                    data: "\(stats.pfdPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 득실마진",
                    data: "\(stats.plusMinusPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "더블더블",
                    data: "\(stats.dd2)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "트리플더블",
                    data: "\(stats.td3)",
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
            }
        }
    }
}
