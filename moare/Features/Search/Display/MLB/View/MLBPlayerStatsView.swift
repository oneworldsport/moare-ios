//
//  MLBPlayerStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBPlayerStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<MLBPlayerStatsStore>
    let didPop: Bool
    
    @State private var show = false

    var body: some View {
        ScrollView {
            InfoViewContainer(
                itemCount: store.baseStats.displayModel.stats.count + 1,
                shouldShowMeasureContent: true,
                measureContent: { scope in
                    if show {
                        MLBPlayerStatsPlayerInfoItem(mlbPlayerStatsStore: store)
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
                        
                        MLBPlayerStatsList(mlbPlayerStatsStore: store, scope: scope)
                    }
                },
                displayContent: { scope in
                    if show {
                        MLBPlayerStatsPlayerInfoItem(
                            mlbPlayerStatsStore: store,
                            isAniItem: true,
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        MLBPlayerStatsList(
                            mlbPlayerStatsStore: store,
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

struct MLBPlayerStatsPlayerInfoItem: View {
    @Bindable var mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool

    init(
        mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbPlayerStatsStore = mlbPlayerStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = mlbPlayerStatsStore.baseStats.displayModel
        let playerNameDic = mlbPlayerStatsStore.baseStats.playerNameDictionary
        let teamNameDic = mlbPlayerStatsStore.baseStats.teamNameDictionary
        let player = displayModel.player
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HStack {
                URLImage(url: MLBUtil.playerPhotoURL(id: player.id))
                
                // name
                VStack(alignment: .leading) {
                    Text(playerNameDic["\(player.id)"] ?? (player.fullName))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    Text("\(player.fullName)")
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .lineLimit(2)
                    
                    (
                        Text("국적: ")
                            .font(.system(size: 15))
                        + Text(player.birthCountry)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    )
                    .multilineTextAlignment(.leading)
                }
                
                URLImage(
                    url: MLBUtil.teamLogoURL(id: displayModel.teamId),
                    isSvg: true
                )

                // team, jersey, position
                VStack(alignment: .leading) {
                    Text(teamNameDic["full_\(displayModel.teamId ?? 0)"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    (
                        Text("등번호: ")
                            .font(.system(size: 15))
                        + Text(player.primaryNumber)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    )
                    .multilineTextAlignment(.leading)
                    
                    (
                        Text("포지션: ")
                            .font(.system(size: 15))
                        + Text(player.primaryPosition.name)
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

struct MLBPlayerStatsList: View {
    @Bindable var mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>
    
    let isAniItem: Bool
    let scope: InfoViewScope
    
    init(
        mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>,
        isAniItem: Bool = false,
        scope: InfoViewScope,
    ) {
        self.mlbPlayerStatsStore = mlbPlayerStatsStore
        self.isAniItem = isAniItem
        self.scope = scope
    }
    
    var body: some View {
        let stats = mlbPlayerStatsStore.baseStats.displayModel.stats
        
        ForEach(stats.indices, id: \.self) { index in
            let stats = stats[index]
            let itemIndex = index + 1
            
            MLBPlayerStatsListItem(
                mlbPlayerStatsStore: mlbPlayerStatsStore,
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

struct MLBPlayerStatsListItem: View {
    @Bindable var mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>
    
    let stats: MLBPlayerStats
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>,
        stats: MLBPlayerStats,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbPlayerStatsStore = mlbPlayerStatsStore
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
            MLBPlayerStatsItem(
                mlbPlayerStatsStore: mlbPlayerStatsStore,
                stats: stats
            )
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct MLBPlayerStatsItem: View {
    @Bindable var mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>
    
    let stats: MLBPlayerStats
    
    var body: some View {
        let season = stats.hitting?.season ?? stats.pitching?.season ?? stats.fielding?.season ?? stats.catching?.season ?? "\(CalendarUtil.currentYear)"
        
        if let hitting = stats.hitting?.stat {
            HStack {
                BaseballLeagueTitle(
                    logoUrl: MLBUtil.mlbLogoUrl,
                    name: "MLB",
                    season: Int(season)
                )
                
                Text(" - [타자]")
                    .fontWeight(.medium)
            }
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: "\(hitting.gamesPlayed)",
                    customCategoryFontSize: 11,
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "타수",
                    data: "\(hitting.atBats)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
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
                    category: "2루타",
                    data: "\(hitting.doubles)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "3루타",
                    data: "\(hitting.triples)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
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
                StatsDivider()
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
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "볼넷",
                    data: "\(hitting.baseOnBalls)",
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
                StatsDivider()
                FBStatDataItem(
                    category: "도루",
                    data: "\(hitting.stolenBases)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도루 실패",
                    data: "\(hitting.caughtStealing)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도루 성공률",
                    data: hitting.stolenBasePercentage,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "희생번트",
                    data: "\(hitting.sacBunts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "희생플라이",
                    data: "\(hitting.sacFlies)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
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
                    category: "뜬공아웃",
                    data: "\(hitting.airOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                    .opacity(0)
                EmptyStatDataItem()
                    .frame(maxWidth: .infinity)
            }
        } // if let hitting
        
        if let pitching = stats.pitching?.stat {
            HStack {
                BaseballLeagueTitle(
                    logoUrl: MLBUtil.mlbLogoUrl,
                    name: "MLB",
                    season: Int(season)
                )
                
                Text(" - [투수]")
                    .fontWeight(.medium)
            }
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: "\(pitching.gamesPitched)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "이닝",
                    data: pitching.inningsPitched,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "평균자책",
                    data: pitching.era,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "승",
                    data: "\(pitching.wins)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "패",
                    data: "\(pitching.losses)",
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
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "세이브",
                    data: "\(pitching.saves)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "삼진",
                    data: "\(pitching.strikeOuts)",
                    customCategoryFontSize: 11
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
                    category: "피안타",
                    data: "\(pitching.hits)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피2루타",
                    data: "\(pitching.doubles)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "피3루타",
                    data: "\(pitching.triples)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "피홈런",
                    data: "\(pitching.homeRuns)",
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
                    category: "실점",
                    data: "\(pitching.runs)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "자책점",
                    data: "\(pitching.earnedRuns)",
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
                StatsDivider()
                FBStatDataItem(
                    category: "보크",
                    data: "\(pitching.balks)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "고의4구",
                    data: "\(pitching.intentionalWalks)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "폭투",
                    data: "\(pitching.wildPitches)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "완투",
                    data: "\(pitching.completeGames)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "완봉",
                    data: "\(pitching.shutouts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "투구수",
                    data: "\(pitching.numberOfPitches)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "이닝당 출루허용률",
                    data: pitching.whip,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            
            HDivider(color: .secondary)
                .opacity(0.5)
            
            HStack {
                FBStatDataItem(
                    category: "도루 허용",
                    data: "\(pitching.stolenBases)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도루 허용률",
                    data: pitching.stolenBasePercentage,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "승률",
                    data: pitching.winPercentage,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "병살타",
                    data: "\(pitching.groundIntoDoublePlay)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "뜬공아웃",
                    data: "\(pitching.airOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "땅볼아웃",
                    data: "\(pitching.groundOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
        } // if let hitting
    }
}
