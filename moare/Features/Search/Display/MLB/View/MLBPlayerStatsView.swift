//
//  MLBPlayerStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBPlayerStatsView: View {
    /* ---------------------
     store
     --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: MLBPlayerStatsDisplayModel

    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let mlbPlayerStatsStore {
                    InfoViewContainer(
                        itemCount: (mlbPlayerStatsStore.baseStats.displayModel?.stats.count ?? 0) + 1,
                        measureContent: { scope in
                            MLBPlayerStatsPlayerInfoItem(mlbPlayerStatsStore: mlbPlayerStatsStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            MLBPlayerStatsList(mlbPlayerStatsStore: mlbPlayerStatsStore) { index, geometry in
                                scope.updateItemFrame(index: index, geometry: geometry)
                            }
                            .frame(maxWidth: .infinity)
                        },
                        displayContent: { scope in
                            MLBPlayerStatsPlayerInfoItem(
                                mlbPlayerStatsStore: mlbPlayerStatsStore,
                                isAniItem: true,
                                itemOffset: scope.computedOffset(for: 0),
                                showContents: scope.showContents
                            )
                            MLBPlayerStatsList(
                                mlbPlayerStatsStore: mlbPlayerStatsStore,
                                isAniItem: true,
                                itemOffset: scope.computedOffset(for: 1),
                                showContents: scope.showContents
                            )
                        }
                    )
                }
            } // ScrollView
            .padding(.top, 6)
            .onAppear {
                // init MLBPlayerStatsStore
                let mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore> = storeManager.getStore(forKey: StoreKeys.mlbPlayerStatsStore) ?? {
                    let newStore = Store(initialState: MLBPlayerStatsStore.State()) { MLBPlayerStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.mlbPlayerStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.mlbPlayerStatsStore = mlbPlayerStatsStore
                }
                
                if searchStore.poppedView == nil {
                    mlbPlayerStatsStore.send(.baseStats(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .mlbPlayerStats = searchStore.poppedView {
                    mlbPlayerStatsStore?.send(.baseStats(.initData(displayModel: displayModel)))
                }
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
        let player = displayModel?.player
        let playerNameDic = mlbPlayerStatsStore.baseStats.playerNameDictionary
        let teamNameDic = mlbPlayerStatsStore.baseStats.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HCapsuleBar()
            
            HStack {
                URLImage(url: MLBUtil.playerPhotoURL(id: player?.id))
                
                VStack(alignment: .leading) {
                    Text(playerNameDic["\(player?.id ?? 0)"] ?? (player?.fullName ?? ""))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    Text("\(player?.fullName ?? "")")
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .lineLimit(2)
                }
//                
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("국적: ")
                            .font(.system(size: 15))
                            
                        Text(player?.birthCountry ?? "")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                    
                    HStack(spacing: 0) {
                        Text("소속팀: ")
                            .font(.system(size: 15))
                        
                        URLImage(url: MLBUtil.teamLogoURL(id: displayModel?.teamId), customSize: CGSize(width: 24, height: 24), isSvg: true)
                            .padding(.trailing, 6)
                        
                        Text(teamNameDic["full_\(displayModel?.teamId ?? 0)"] ?? "")
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

struct MLBPlayerStatsList: View {
    @Bindable var mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool
    
    let updateItemPosition: (Int, GeometryProxy) -> Void
    
    init(
        mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true,
        updateItemPosition: @escaping (Int, GeometryProxy) -> Void = { _, _ in }
    ) {
        self.mlbPlayerStatsStore = mlbPlayerStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
        self.updateItemPosition = updateItemPosition
    }
    
    var body: some View {
        if let stats = mlbPlayerStatsStore.baseStats.displayModel?.stats {
            ForEach(stats.indices, id: \.self) { index in
                let data = stats[index]
                
                MLBPlayerStatsListItem(
                    mlbPlayerStatsStore: mlbPlayerStatsStore,
                    data: data,
                    index: index,
                    isAniItem: isAniItem,
                    itemOffset: itemOffset,
                    showContents: showContents,
                    updateItemPosition: updateItemPosition
                )
            }
        }
    }
}

struct MLBPlayerStatsListItem: View {
    @Bindable var mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>
    
    let data: MLBPlayerStats
    let index: Int
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool
    
    let updateItemPosition: (Int, GeometryProxy) -> Void
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset,
            updateItemPosition: { geometry in
                updateItemPosition(index + 1, geometry)
            }
        ) {
            MLBPlayerStatsItem(
                mlbPlayerStatsStore: mlbPlayerStatsStore,
                data: data,
                showContents: showContents
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct MLBPlayerStatsItem: View {
    @Bindable var mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>
    
    let data: MLBPlayerStats
    let showContents: Bool

    init(
        mlbPlayerStatsStore: StoreOf<MLBPlayerStatsStore>,
        data: MLBPlayerStats,
        showContents: Bool = true
    ) {
        self.mlbPlayerStatsStore = mlbPlayerStatsStore
        self.data = data
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = mlbPlayerStatsStore.baseStats.displayModel
        let season = data.hitting?.season ?? data.pitching?.season ?? data.fielding?.season ?? data.catching?.season ?? "2025"

        HCapsuleBar()
        
        if let hitting = data.hitting?.stat {
            HStack {
                BaseballLeagueTitle(
                    logoUrl: MLBUtil.mlbLogoUrl,
                    name: "MLB",
                    season: Int(season) ?? 2025
                )
                
                Text(" - [타자]")
                    .fontWeight(.medium)
            }
            .padding(.bottom, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: "\(hitting.gamesPlayed)",
                    customCategoryFontSize: 11,
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "타수",
                    data: "\(hitting.atBats)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "타율",
                    data: hitting.avg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "안타",
                    data: "\(hitting.hits)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "2루타",
                    data: "\(hitting.doubles)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "3루타",
                    data: "\(hitting.triples)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "홈런",
                    data: "\(hitting.homeRuns)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "출루율",
                    data: hitting.obp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "장타율",
                    data: hitting.slg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "ops",
                    data: hitting.ops,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "득점",
                    data: "\(hitting.runs)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "타점",
                    data: "\(hitting.rbi)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "볼넷",
                    data: "\(hitting.baseOnBalls)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "삼진",
                    data: "\(hitting.strikeOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "사구",
                    data: "\(hitting.hitByPitch)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루",
                    data: "\(hitting.stolenBases)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루 실패",
                    data: "\(hitting.caughtStealing)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루 성공률",
                    data: hitting.stolenBasePercentage,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "희생번트",
                    data: "\(hitting.sacBunts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "희생플라이",
                    data: "\(hitting.sacFlies)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "병살타",
                    data: "\(hitting.groundIntoDoublePlay)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "땅볼아웃",
                    data: "\(hitting.groundOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "뜬공아웃",
                    data: "\(hitting.airOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "",
                    data: "",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
        } // if let hitting
        
        if let pitching = data.pitching?.stat {
            HStack {
                BaseballLeagueTitle(
                    logoUrl: MLBUtil.mlbLogoUrl,
                    name: "MLB",
                    season: Int(season) ?? 2025
                )
                
                Text(" - [투수]")
                    .fontWeight(.medium)
            }
            .padding(.bottom, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: "\(pitching.gamesPitched)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "이닝",
                    data: pitching.inningsPitched,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "평균자책",
                    data: pitching.era,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "승",
                    data: "\(pitching.wins)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "패",
                    data: "\(pitching.losses)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "홀드",
                    data: "\(pitching.holds)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "세이브",
                    data: "\(pitching.saves)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "삼진",
                    data: "\(pitching.strikeOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "볼넷",
                    data: "\(pitching.baseOnBalls)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "피안타",
                    data: "\(pitching.hits)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "피2루타",
                    data: "\(pitching.doubles)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "피3루타",
                    data: "\(pitching.triples)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "피홈런",
                    data: "\(pitching.homeRuns)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "피안타율",
                    data: pitching.avg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "실점",
                    data: "\(pitching.runs)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "자책점",
                    data: "\(pitching.earnedRuns)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "블론세이브",
                    data: "\(pitching.blownSaves)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "보크",
                    data: "\(pitching.balks)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "고의4구",
                    data: "\(pitching.intentionalWalks)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "폭투",
                    data: "\(pitching.wildPitches)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "완투",
                    data: "\(pitching.completeGames)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "완봉",
                    data: "\(pitching.shutouts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "투구수",
                    data: "\(pitching.numberOfPitches)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "이닝당 출루허용률",
                    data: pitching.whip,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "도루 허용",
                    data: "\(pitching.stolenBases)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루 허용률",
                    data: pitching.stolenBasePercentage,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "승률",
                    data: pitching.winPercentage,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "병살타",
                    data: "\(pitching.groundIntoDoublePlay)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "뜬공아웃",
                    data: "\(pitching.airOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "땅볼아웃",
                    data: "\(pitching.groundOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
        } // if let hitting
    }
}
