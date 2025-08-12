//
//  MLBPlayerInfoView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBPlayerInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: MLBPlayerInfoDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            InfoViewContainer(
                itemCount: 8,
                measureContent: { scope in
                    if let mlbPlayerInfoStore {
                        HStack(alignment: .top) {
                            MLBPlayerInfoFirstItem(mlbPlayerInfoStore: mlbPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            MLBPlayerInfoSecondItem(mlbPlayerInfoStore: mlbPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 1, geometry: geometry)
                                        }
                                    }
                                )
                            
                            MLBPlayerInfoThirdItem(mlbPlayerInfoStore: mlbPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 2, geometry: geometry)
                                        }
                                    }
                                )
                        }
                        
                        HStack(alignment: .top) {
                            MLBPlayerInfoFourthItem(mlbPlayerInfoStore: mlbPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 3, geometry: geometry)
                                        }
                                    }
                                )
                            
                            MLBPlayerInfoFifthItem(mlbPlayerInfoStore: mlbPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 4, geometry: geometry)
                                        }
                                    }
                                )
                        }
                        
                        MLBPlayerInfoSixthItem(
                            searchStore: searchStore,
                            mlbPlayerInfoStore: mlbPlayerInfoStore
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 5, geometry: geometry)
                                }
                            }
                        )
                        
                        MLBPlayerInfoSeventhItem(
                            searchStore: searchStore,
                            mlbPlayerInfoStore: mlbPlayerInfoStore
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 6, geometry: geometry)
                                }
                            }
                        )
                        
                        MLBPlayerInfoEigthItem(
                            searchStore: searchStore,
                            mlbPlayerInfoStore: mlbPlayerInfoStore
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 7, geometry: geometry)
                                }
                            }
                        )
                    }
                },
                displayContent: { scope in
                    if let mlbPlayerInfoStore {
                        MLBPlayerInfoFirstItem(
                            mlbPlayerInfoStore: mlbPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[0],
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        MLBPlayerInfoSecondItem(
                            mlbPlayerInfoStore: mlbPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[1],
                            itemOffset: scope.computedOffset(for: 1),
                            showContents: scope.showContents
                        )
                        MLBPlayerInfoThirdItem(
                            mlbPlayerInfoStore: mlbPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[2],
                            itemOffset: scope.computedOffset(for: 2),
                            showContents: scope.showContents
                        )
                        MLBPlayerInfoFourthItem(
                            mlbPlayerInfoStore: mlbPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[3],
                            itemOffset: scope.computedOffset(for: 3),
                            showContents: scope.showContents
                        )
                        MLBPlayerInfoFifthItem(
                            mlbPlayerInfoStore: mlbPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[4],
                            itemOffset: scope.computedOffset(for: 4),
                            showContents: scope.showContents
                        )
                        MLBPlayerInfoSixthItem(
                            searchStore: searchStore,
                            mlbPlayerInfoStore: mlbPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[5],
                            itemOffset: scope.computedOffset(for: 5),
                            showContents: scope.showContents
                        )
                        MLBPlayerInfoSeventhItem(
                            searchStore: searchStore,
                            mlbPlayerInfoStore: mlbPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[6],
                            itemOffset: scope.computedOffset(for: 6),
                            showContents: scope.showContents
                        )
                        MLBPlayerInfoEigthItem(
                            searchStore: searchStore,
                            mlbPlayerInfoStore: mlbPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[7],
                            itemOffset: scope.computedOffset(for: 7),
                            showContents: scope.showContents
                        )
                    }
                }
            )
            .onAppear {
                // init MLBPlayerInfoStore
                let mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore> = storeManager.getStore(forKey: StoreKeys.mlbPlayerInfoStore) ?? {
                    let newStore = Store(initialState: MLBPlayerInfoStore.State()) { MLBPlayerInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.mlbPlayerInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.mlbPlayerInfoStore = mlbPlayerInfoStore
                }
                
                if searchStore.poppedView == nil {
                    mlbPlayerInfoStore.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .mlbPlayerInfo = searchStore.poppedView {
                    mlbPlayerInfoStore?.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

// photo, name
struct MLBPlayerInfoFirstItem: View {
    @Bindable var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbPlayerInfoStore = mlbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let playerNameDic = mlbPlayerInfoStore.baseInfo.playerNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            if let player = mlbPlayerInfoStore.baseInfo.displayModel?.info {
                URLImage(url: MLBUtil.playerPhotoURL(id: player.id))
                    .opacity(showContents ? 1 : 0)
                
                Text(playerNameDic["\(player.id)"] ?? player.fullName)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
                
                Text(player.fullName)
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .lineLimit(2)
                    .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// logo, team, name
struct MLBPlayerInfoSecondItem: View {
    @Bindable var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbPlayerInfoStore = mlbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = mlbPlayerInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset
        ) {
            if let displayModel = mlbPlayerInfoStore.baseInfo.displayModel {
                URLImage(url: MLBUtil.teamLogoURL(id: displayModel.teamId), isSvg: true)
                    .opacity(showContents ? 1 : 0)
                
                Text(teamNameDic["full_\(displayModel.teamId ?? 0)"] ?? "")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// jersey, position, debut
struct MLBPlayerInfoThirdItem: View {
    @Bindable var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbPlayerInfoStore = mlbPlayerInfoStore
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
            if let player = mlbPlayerInfoStore.baseInfo.displayModel?.info {
                HStack(spacing: 0) {
                    Text("등번호: ")
                        .font(.system(size: 15))
                    
                    Text(player.primaryNumber)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("포지션: ")
                        .font(.system(size: 15))
                    
                    Text(MLBUtil.getPositionName(input: player.primaryPosition.abbreviation))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("데뷔년도: ")
                        .font(.system(size: 15))
                    
                    Text(player.mlbDebutDate.split(separator: "-").first ?? "2025")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// country, birth, age
struct MLBPlayerInfoFourthItem: View {
    @Bindable var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbPlayerInfoStore = mlbPlayerInfoStore
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
            if let player = mlbPlayerInfoStore.baseInfo.displayModel?.info {
                HStack(spacing: 0) {
                    Text("국적: ")
                        .font(.system(size: 15))
                    
                    Text(player.birthCountry)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("출생: ")
                        .font(.system(size: 15))
                    
                    Text(player.birthDate)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("나이: ")
                        .font(.system(size: 15))
                    
                    Text(String(CalendarUtil.calculateAge(from: player.birthDate)))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// height(cm/feet), weight(kg/pound)
struct MLBPlayerInfoFifthItem: View {
    @Bindable var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.mlbPlayerInfoStore = mlbPlayerInfoStore
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
            if let player = mlbPlayerInfoStore.baseInfo.displayModel?.info {
                HStack(spacing: 0) {
                    Text("키(cm/ft): ")
                        .font(.system(size: 15))
                    
                    Text("\(MLBUtil.changeToCm(input: player.height)) / \(player.height)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("몸무게(kg/lb): ")
                        .font(.system(size: 15))
                    
                    Text("\(Int(player.weight.toKg())) / \(player.weight)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// league stats
struct MLBPlayerInfoSixthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.mlbPlayerInfoStore = mlbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let stats = mlbPlayerInfoStore.baseInfo.displayModel?.stats
        let season = stats?.hitting?.season ?? stats?.pitching?.season ?? stats?.fielding?.season ?? stats?.catching?.season ?? "2025"
        
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                if let player = mlbPlayerInfoStore.baseInfo.displayModel?.info {
                    searchStore.send(.showPlayerStats(playerId: player.id))
                }
            }
        ) {
            BaseballLeagueTitle(
                logoUrl: MLBUtil.mlbLogoUrl,
                name: "MLB",
                season: Int(season)
            )
            .opacity(showContents ? 1 : 0)
            
            if let hitting = stats?.hitting?.stat {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "경기수",
                        data: String(hitting.gamesPlayed),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivder()
                    FBStatDataItem(
                        category: "타율",
                        data: hitting.avg,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivder()
                    FBStatDataItem(
                        category: "홈런",
                        data: String(hitting.homeRuns),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivder()
                    FBStatDataItem(
                        category: "ops",
                        data: hitting.ops,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivder()
                    FBStatDataItem(
                        category: "도루",
                        data: String(hitting.stolenBases),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                }
                .opacity(showContents ? 1 : 0)
            }
            
            if let pitching = stats?.pitching?.stat {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "경기수",
                        data: String(pitching.gamesPitched),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivder()
                    FBStatDataItem(
                        category: "평균자책점",
                        data: pitching.era,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivder()
                    FBStatDataItem(
                        category: "피안타율",
                        data: pitching.avg,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivder()
                    FBStatDataItem(
                        category: "승",
                        data: String(pitching.wins),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivder()
                    FBStatDataItem(
                        category: "이닝당 평균 투구수",
                        data: pitching.pitchesPerInning,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

// last game
struct MLBPlayerInfoSeventhItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.mlbPlayerInfoStore = mlbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = mlbPlayerInfoStore.baseInfo.teamNameDictionary
        let lastGamePlayerHitterStats = mlbPlayerInfoStore.baseInfo.displayModel?.lastGamePlayerStats?.stats?.batting
        let lastGamePlayerPitcherStats = mlbPlayerInfoStore.baseInfo.displayModel?.lastGamePlayerStats?.stats?.pitching
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                searchStore.send(.showGameStats(gameType: "previous"))
            }
        ) {
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            HStack {
                if let lastGame = mlbPlayerInfoStore.baseInfo.displayModel?.lastGame {
                    let homeTeamScore = lastGame.linescore.teams.home.runs
                    let awayTeamScore = lastGame.linescore.teams.away.runs
                    
                    VStack {
                        HStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text(teamNameDic["short_\(lastGame.teams.home.id)"] ?? "")
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .lineLimit(1)
                                
                                Text(" \(homeTeamScore)")
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                    .foregroundStyle((homeTeamScore >= awayTeamScore) ? .moare : .primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text(" - ")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                            
                            HStack(spacing: 0) {
                                Text("\(awayTeamScore) ")
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                    .foregroundStyle((awayTeamScore >= homeTeamScore) ? .moare : .primary)
                                
                                Text(teamNameDic["short_\(lastGame.teams.away.id)"] ?? "")
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text(CalendarUtil.formatDate(date: lastGame.gameInfo.gameDate, formatType: .ampmWithDayOfWeekDate))
                            .font(.system(size: 15))
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.40) // NOTE: 너비를 화면 전체 너비중 40%로 고정
                }
                
                // NOTE: lastGamePlayerHitterStats, lastGamePlayerPitcherStats가 null인 경우는 없어서 안에 있는 기본 데이터로 해당 선수 기록 보여줘야할지 판단
                if lastGamePlayerHitterStats?._atBats != nil && lastGamePlayerPitcherStats?._numberOfPitches == nil {
                    HStack {
                        StatsDivder()
                        FBStatDataItem(
                            category: "타수",
                            data: String(lastGamePlayerHitterStats!.atBats),
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivder()
                        FBStatDataItem(
                            category: "안타",
                            data: String(lastGamePlayerHitterStats!.hits),
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivder()
                        FBStatDataItem(
                            category: "득점",
                            data: String(lastGamePlayerHitterStats!.runs),
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivder()
                        FBStatDataItem(
                            category: "타점",
                            data: String(lastGamePlayerHitterStats!.rbi),
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                } else if lastGamePlayerPitcherStats?._numberOfPitches != nil && lastGamePlayerHitterStats?._atBats == nil {
                    HStack {
                        StatsDivder()
                        FBStatDataItem(
                            category: "이낭",
                            data: lastGamePlayerPitcherStats!.inningsPitched,
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivder()
                        FBStatDataItem(
                            category: "삼진",
                            data: String(lastGamePlayerPitcherStats!.strikeOuts),
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivder()
                        FBStatDataItem(
                            category: "볼넷",
                            data: String(lastGamePlayerPitcherStats!.baseOnBalls),
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivder()
                        FBStatDataItem(
                            category: "실점",
                            data: String(lastGamePlayerPitcherStats!.runs),
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivder()
                        FBStatDataItem(
                            category: "자책점",
                            data: String(lastGamePlayerPitcherStats!.earnedRuns),
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

// next game
struct MLBPlayerInfoEigthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        mlbPlayerInfoStore: StoreOf<MLBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.mlbPlayerInfoStore = mlbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = mlbPlayerInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                searchStore.send(.showGameStats(gameType: "next"))
            }
        ) {
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame = mlbPlayerInfoStore.baseInfo.displayModel?.nextGame {
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
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.gameInfo.gameDate, formatType: .ampmWithDayOfWeekDate))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            } else {
                Text("예정된 경기가 없습니다.")
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}
