//
//  MLBTeamStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBTeamStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<MLBTeamStatsStore>
    let didPop: Bool
    
    @State private var show = false

    var body: some View {
        ScrollView {
            InfoViewContainer(
                itemCount: store.baseStats.displayModel.stats.count + 1,
                shouldShowMeasureContent: true,
                measureContent: { scope in
                    if show {
                        MLBTeamStatsPlayerInfoItem(mlbTeamStatsStore: store)
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
                        
                        MLBTeamStatsList(mlbTeamStatsStore: store, scope: scope)
                    }
                },
                displayContent: { scope in
                    if show {
                        // team info
                        MLBTeamStatsPlayerInfoItem(
                            mlbTeamStatsStore: store,
                            isAniItem: true,
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        
                        // stats list
                        MLBTeamStatsList(
                            mlbTeamStatsStore: store,
                            isAniItem: true,
                            scope: scope
                        )
                    }
                }
            )
        } // ScrollView
        .onAppear {
            if !didPop {
                store.send(.baseStats(.initData))
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct MLBTeamStatsPlayerInfoItem: View {
    @Bindable var mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool

    init(
        mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbTeamStatsStore = mlbTeamStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = mlbTeamStatsStore.baseStats.displayModel
        let teamNameDic = mlbTeamStatsStore.baseStats.teamNameDictionary
        let team = displayModel.team
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HStack {
                URLImage(url: MLBUtil.teamLogoURL(id: team.id), isSvg: true)
                
                // name, state and city
                VStack(alignment: .leading) {
                    Text(teamNameDic["full_\(team.id)"] ?? team.teamName)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    Text(team.name)
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .lineLimit(2)
                    
                    (
                        Text("연고지: ")
                            .font(.system(size: 15))
                        + Text(team.locationName)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    )
                    .multilineTextAlignment(.leading)
                }
                
                // venue, conference, division
                VStack(alignment: .leading) {
                    (
                        Text("홈구장: ")
                            .font(.system(size: 15))
                        + Text(teamNameDic["venue_\(team.id)"] ?? displayModel.venue.name)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    )
                    .multilineTextAlignment(.leading)
                    
                    (
                        Text("리그: ")
                            .font(.system(size: 15))
                        + Text(MLBUtil.leagueDivisionMap[team.league.id] ?? team.league.name)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    )
                    .multilineTextAlignment(.leading)
                    
                    (
                        Text("디비전: ")
                            .font(.system(size: 15))
                        + Text(MLBUtil.leagueDivisionMap[team.division.id] ?? team.division.name)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    )
                    .multilineTextAlignment(.leading)
                }
            }
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct MLBTeamStatsList: View {
    @Bindable var mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>
    
    let isAniItem: Bool
    let scope: InfoViewScope
    
    init(
        mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>,
        isAniItem: Bool = false,
        scope: InfoViewScope,
    ) {
        self.mlbTeamStatsStore = mlbTeamStatsStore
        self.isAniItem = isAniItem
        self.scope = scope
    }
    
    var body: some View {
        let stats = mlbTeamStatsStore.baseStats.displayModel.stats
        
        ForEach(stats.indices, id: \.self) { index in
            let stats = stats[index]
            let itemIndex = index + 1
            
            MLBTeamStatsListItem(
                mlbTeamStatsStore: mlbTeamStatsStore,
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

struct MLBTeamStatsListItem: View {
    @Bindable var mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>
    
    let stats: MLBTeamStats
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>,
        stats: MLBTeamStats,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbTeamStatsStore = mlbTeamStatsStore
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
            MLBTeamStatsItem(
                mlbTeamStatsStore: mlbTeamStatsStore,
                stats: stats
            )
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct MLBTeamStatsItem: View {
    @Bindable var mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>
    
    let stats: MLBTeamStats
    
    @State private var isBasicStatsOpened = true
    @State private var isHitterStatsOpened = false
    @State private var isPitcherStatsOpened = false

    var body: some View {
        let team = mlbTeamStatsStore.baseStats.displayModel.team
        
        if let record = stats.recordData,
           let hitting = stats.hitting, let pitching = stats.pitching,
           let fielding = stats.fielding, let catching = stats.catching {
            BaseballLeagueTitle(
                logoUrl: MLBUtil.mlbLogoUrl,
                name: "MLB",
                season: team.season
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
                        category: "\(MLBUtil.leagueDivisionMap[team.league.id] ?? team.league.name) 순위",
                        data: record.divisionRank,
                        customCategoryFontSize: 11,
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "승",
                        data: "\(record.wins)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "패",
                        data: "\(record.losses)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "경기수",
                        data: "\(record.gamesPlayed)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "게임차",
                        data: record.gamesBack,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "승률",
                        data: record.winningPercentage,
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
                        data: "\(hitting.hits)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "홈런",
                        data: "\(hitting.homeRuns)",
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
                        category: "득점",
                        data: "\(hitting.runs)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "타점",
                        data: "\(hitting.rbi)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "삼진",
                        data: "\(hitting.strikeOuts)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "사구",
                        data: "\(hitting.hitByPitch)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                }
                
                HDivider(color: .secondary)
                    .opacity(0.5)
                
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "병살타",
                        data: "\(hitting.groundIntoDoublePlay)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "땅볼아웃",
                        data: "\(hitting.groundOuts)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "도루성공",
                        data: "\(hitting.stolenBases)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "도루실패",
                        data: "\(hitting.caughtStealing)",
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
                        data: "\(pitching.hits)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "피홈런",
                        data: "\(pitching.homeRuns)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "세이브",
                        data: "\(pitching.saves)",
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
                        customCategoryFontSize: 11,
                        customWidth: 70
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "볼넷",
                        data: "\(pitching.baseOnBalls)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "보크",
                        data: "\(pitching.balks)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "홀드",
                        data: "\(pitching.holds)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "블론세이브",
                        data: "\(pitching.blownSaves)",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
