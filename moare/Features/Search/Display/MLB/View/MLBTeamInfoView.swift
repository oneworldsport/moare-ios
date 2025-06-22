//
//  MLBTeamInfoView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBTeamInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: MLBTeamInfoDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            InfoViewContainer(
                itemCount: 8,
                measureContent: { scope in
                    if let mlbTeamInfoStore {
                        HStack(alignment: .top) {
                            MLBTeamInfoFirstItem(mlbTeamInfoStore: mlbTeamInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            MLBTeamInfoSecondItem(mlbTeamInfoStore: mlbTeamInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 1, geometry: geometry)
                                        }
                                    }
                                )
                            
                            MLBTeamInfoThirdItem(mlbTeamInfoStore: mlbTeamInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 2, geometry: geometry)
                                        }
                                    }
                                )
                        }
                        
                        MLBTeamInfoFourthItem(
                            searchStore: searchStore,
                            mlbTeamInfoStore: mlbTeamInfoStore
                        )
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 3, geometry: geometry)
                                    }
                                }
                            )
                        
                        HStack(alignment: .top) {
                            MLBTeamInfoFifthItem(
                                searchStore: searchStore,
                                mlbTeamInfoStore: mlbTeamInfoStore
                            )
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 4, geometry: geometry)
                                        }
                                    }
                                )
                            
                            MLBTeamInfoSixthItem(
                                searchStore: searchStore,
                                mlbTeamInfoStore: mlbTeamInfoStore
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 5, geometry: geometry)
                                    }
                                }
                            )
                        }
                    }
                },
                displayContent: { scope in
                    if let mlbTeamInfoStore {
                        MLBTeamInfoFirstItem(
                            mlbTeamInfoStore: mlbTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[0],
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        MLBTeamInfoSecondItem(
                            mlbTeamInfoStore: mlbTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[1],
                            itemOffset: scope.computedOffset(for: 1),
                            showContents: scope.showContents
                        )
                        MLBTeamInfoThirdItem(
                            mlbTeamInfoStore: mlbTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[2],
                            itemOffset: scope.computedOffset(for: 2),
                            showContents: scope.showContents
                        )
                        MLBTeamInfoFourthItem(
                            searchStore: searchStore,
                            mlbTeamInfoStore: mlbTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[3],
                            itemOffset: scope.computedOffset(for: 3),
                            showContents: scope.showContents
                        )
                        MLBTeamInfoFifthItem(
                            searchStore: searchStore,
                            mlbTeamInfoStore: mlbTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[4],
                            itemOffset: scope.computedOffset(for: 4),
                            showContents: scope.showContents
                        )
                        MLBTeamInfoSixthItem(
                            searchStore: searchStore,
                            mlbTeamInfoStore: mlbTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[5],
                            itemOffset: scope.computedOffset(for: 5),
                            showContents: scope.showContents
                        )
                    }
                }
            )
            .onAppear {
                // init MLBTeamInfoStore
                let mlbTeamInfoStore: StoreOf<MLBTeamInfoStore> = storeManager.getStore(forKey: StoreKeys.mlbTeamInfoStore) ?? {
                    let newStore = Store(initialState: MLBTeamInfoStore.State()) { MLBTeamInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.mlbTeamInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.mlbTeamInfoStore = mlbTeamInfoStore
                }
                
                if searchStore.poppedView == nil {
                    mlbTeamInfoStore.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .mlbTeamInfo = searchStore.poppedView {
                    mlbTeamInfoStore?.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

// logo, team, name
struct MLBTeamInfoFirstItem: View {
    @Bindable var mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbTeamInfoStore = mlbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = mlbTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            HCapsuleBar()
            
            if let team = mlbTeamInfoStore.baseInfo.displayModel?.team {
                URLImage(url: MLBUtil.teamLogoURL(id: team.id), isSvg: true)
                    .opacity(showContents ? 1 : 0)
                
                Text(teamNameDic["full_\(team.id)"] ?? team.teamName)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
                
                Text(team.teamName)
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .lineLimit(2)
                    .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// founded, city, conference, division
struct MLBTeamInfoSecondItem: View {
    @Bindable var mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbTeamInfoStore = mlbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            if let team = mlbTeamInfoStore.baseInfo.displayModel?.team {
                HStack(spacing: 0) {
                    Text("창단연도: ")
                        .font(.system(size: 15))
                    
                    Text(team.firstYearOfPlay)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("연고지: ")
                        .font(.system(size: 15))
                    
                    Text(team.locationName)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.vertical, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("컨퍼런스/디비전: ")
                        .font(.system(size: 15))
                    
                    Text("\(team.league.name) / \(team.division.name)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// venue
struct MLBTeamInfoThirdItem: View {
    @Bindable var mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbTeamInfoStore = mlbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = mlbTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            // added HStack to position Capsule at center
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            if let displayModel = mlbTeamInfoStore.baseInfo.displayModel {
                HStack(spacing: 0) {
                    Text("홈구장: ")
                        .font(.system(size: 15))
                    
                    Text(teamNameDic["venue_\(displayModel.team.id)"] ?? displayModel.venue.name)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// league stats
struct MLBTeamInfoFourthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.mlbTeamInfoStore = mlbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let team = mlbTeamInfoStore.baseInfo.displayModel?.team
        let stats = mlbTeamInfoStore.baseInfo.displayModel?.stats
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                if let team {
                    searchStore.send(.showTeamStats(teamId: team.id))
                }
            }
        ) {
            HCapsuleBar()
            
            BaseballLeagueTitle(
                logoUrl: MLBUtil.mlbLogoUrl,
                name: "MLB",
                season: team?.season ?? 2025
            )
            .opacity(showContents ? 1 : 0)
            
            if let recordData = stats?.recordData {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "디비전 순위",
                        data: recordData.divisionRank,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    FBStatDataItem(
                        category: "승",
                        data: String(recordData.wins),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    FBStatDataItem(
                        category: "패",
                        data: String(recordData.losses),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    FBStatDataItem(
                        category: "무",
                        data: String(recordData.leagueRecord.ties),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    FBStatDataItem(
                        category: "타율",
                        data: stats?.hitting?.avg ?? "0.0",
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

// last game
struct MLBTeamInfoFifthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.mlbTeamInfoStore = mlbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = mlbTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                searchStore.send(.showGameStats(gameType: "previous"))
            }
        ) {
            HCapsuleBar()
            
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            HStack {
                if let lastGame = mlbTeamInfoStore.baseInfo.displayModel?.lastGame {
                    let homeTeamScore = lastGame.linescore.teams.home.runs
                    let awayTeamScore = lastGame.linescore.teams.away.runs
                    
                    VStack {
                        HStack {
                            Text(teamNameDic["short_\(lastGame.teams.home.id)"] ?? "")
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .lineLimit(1)
                            
                            Text("\(homeTeamScore)")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .foregroundStyle((homeTeamScore >= awayTeamScore) ? .moare : .primary)
                            
                            Text(" vs ")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                            
                            Text("\(awayTeamScore)")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .foregroundStyle((awayTeamScore >= homeTeamScore) ? .moare : .primary)
                            
                            Text(teamNameDic["short_\(lastGame.teams.away.id)"] ?? "")
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .lineLimit(1)
                        }
                        
                        Text(CalendarUtil.formatDate(date: lastGame.gameInfo.gameDate))
                            .font(.system(size: 15))
                            .frame(maxHeight: 30)
                    }
                    .padding(.top, 4)
                }
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

// next game
struct MLBTeamInfoSixthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        mlbTeamInfoStore: StoreOf<MLBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.mlbTeamInfoStore = mlbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = mlbTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                searchStore.send(.showGameStats(gameType: "next"))
            }
        ) {
            HCapsuleBar()
            
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame = mlbTeamInfoStore.baseInfo.displayModel?.nextGame {
                HStack {
                    Text(teamNameDic["short_\(nextGame.teams.home.id)"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(teamNameDic["short_\(nextGame.teams.away.id)"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.gameInfo.gameDate))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        } // VStack
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}
