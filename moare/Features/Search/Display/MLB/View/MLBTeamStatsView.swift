//
//  MLBTeamStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBTeamStatsView: View {
    /* ---------------------
     store
     --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: MLBTeamStatsDisplayModel

    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let mlbTeamStatsStore {
                    InfoViewContainer(
                        itemCount: (mlbTeamStatsStore.baseStats.displayModel?.stats.count ?? 0) + 1,
                        measureContent: { scope in
                            MLBTeamStatsPlayerInfoItem(mlbTeamStatsStore: mlbTeamStatsStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            MLBTeamStatsList(mlbTeamStatsStore: mlbTeamStatsStore) { index, geometry in
                                scope.updateItemFrame(index: index, geometry: geometry)
                            }
                            .frame(maxWidth: .infinity)
                        },
                        displayContent: { scope in
                            MLBTeamStatsPlayerInfoItem(
                                mlbTeamStatsStore: mlbTeamStatsStore,
                                isAniItem: true,
                                itemOffset: scope.computedOffset(for: 0),
                                showContents: scope.showContents
                            )
                            MLBTeamStatsList(
                                mlbTeamStatsStore: mlbTeamStatsStore,
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
                // init MLBTeamStatsStore
                let mlbTeamStatsStore: StoreOf<MLBTeamStatsStore> = storeManager.getStore(forKey: StoreKeys.mlbTeamStatsStore) ?? {
                    let newStore = Store(initialState: MLBTeamStatsStore.State()) { MLBTeamStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.mlbTeamStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.mlbTeamStatsStore = mlbTeamStatsStore
                }
                
                if searchStore.poppedView == nil {
                    mlbTeamStatsStore.send(.baseStats(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .mlbPlayerStats = searchStore.poppedView {
                    mlbTeamStatsStore?.send(.baseStats(.initData(displayModel: displayModel)))
                }
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
        let playerNameDic = mlbTeamStatsStore.baseStats.playerNameDictionary
        let teamNameDic = mlbTeamStatsStore.baseStats.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HCapsuleBar()
            
            if let team = displayModel?.team {
                HStack {
                    URLImage(url: MLBUtil.teamLogoURL(id: team.id), isSvg: true)
                    
                    // name, state and city
                    VStack(alignment: .leading) {
                        Text(teamNameDic["full_\(team.id)"] ?? team.teamName)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                        
                        Text(team.teamName)
                            .font(.system(size: 15))
                            .fontWeight(.light)
                            .lineLimit(2)
                        
                        HStack(spacing: 0) {
                            Text("연고지: ")
                                .font(.system(size: 15))
                            
                            Text(team.locationName)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                    
                    // venue, conference, division
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("홈구장: ")
                                .font(.system(size: 15))
                            
                            Text(teamNameDic["venue_\(team.id)"] ?? (displayModel?.venue.name ?? ""))
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 0) {
                            Text("리그: ")
                                .font(.system(size: 15))
                            
                            Text(team.league.name)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 0) {
                            Text("디비전: ")
                                .font(.system(size: 15))
                            
                            Text(team.division.name)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct MLBTeamStatsList: View {
    @Bindable var mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool
    
    let updateItemPosition: (Int, GeometryProxy) -> Void
    
    init(
        mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true,
        updateItemPosition: @escaping (Int, GeometryProxy) -> Void = { _, _ in }
    ) {
        self.mlbTeamStatsStore = mlbTeamStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
        self.updateItemPosition = updateItemPosition
    }
    
    var body: some View {
        if let stats = mlbTeamStatsStore.baseStats.displayModel?.stats {
            ForEach(stats.indices, id: \.self) { index in
                let data = stats[index]
                
                MLBTeamStatsListItem(
                    mlbTeamStatsStore: mlbTeamStatsStore,
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

struct MLBTeamStatsListItem: View {
    @Bindable var mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>
    
    let data: MLBTeamStats
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
            MLBTeamStatsItem(
                mlbTeamStatsStore: mlbTeamStatsStore,
                data: data,
                showContents: showContents
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct MLBTeamStatsItem: View {
    @Bindable var mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>
    
    let data: MLBTeamStats
    let showContents: Bool

    init(
        mlbTeamStatsStore: StoreOf<MLBTeamStatsStore>,
        data: MLBTeamStats,
        showContents: Bool = true
    ) {
        self.mlbTeamStatsStore = mlbTeamStatsStore
        self.data = data
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = mlbTeamStatsStore.baseStats.displayModel

        HCapsuleBar()
        
        if let team = displayModel?.team, let record = data.recordData,
           let hitting = data.hitting, let pitching = data.pitching,
           let fielding = data.fielding, let catching = data.catching {
            BaseballLeagueTitle(
                logoUrl: MLBUtil.mlbLogoUrl,
                name: "MLB",
                season: team.season
            )
            .padding(.bottom, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "\(MLBUtil.leagueDivisionMap[team.league.id] ?? team.league.name) 순위",
                    data: record.divisionRank,
                    customCategoryFontSize: 11,
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "승",
                    data: "\(record.wins)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "패",
                    data: "\(record.losses)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "경기수",
                    data: "\(record.gamesPlayed)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "게임차",
                    data: record.gamesBack,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "승률",
                    data: record.winningPercentage,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
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
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "사구-[타자]",
                    data: "\(hitting.hitByPitch)",
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
                FBStatDataItem(
                    category: "삼진-[타자]",
                    data: "\(hitting.strikeOuts)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "피안타율",
                    data: pitching.avg,
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
                    category: "피홈런",
                    data: "\(pitching.homeRuns)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "평균자책점",
                    data: pitching.era,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "세이브",
                    data: "\(pitching.saves)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "블론세이브",
                    data: "\(pitching.blownSaves)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "볼넷-[투수]",
                    data: "\(pitching.baseOnBalls)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "보크",
                    data: "\(pitching.balks)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "홀드",
                    data: "\(pitching.holds)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "이닝당 출루허용률",
                    data: pitching.whip,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루성공",
                    data: "\(hitting.stolenBases)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루실패",
                    data: "\(hitting.caughtStealing)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
        }
    }
}
