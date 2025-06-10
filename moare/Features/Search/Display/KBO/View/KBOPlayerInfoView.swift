//
//  KBOPlayerInfoView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOPlayerInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: KBOPlayerInfoDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            InfoViewContainer(
                itemCount: 8,
                measureContent: { scope in
                    if let kboPlayerInfoStore {
                        HStack(alignment: .top) {
                            KBOPlayerInfoFirstItem(kboPlayerInfoStore: kboPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            KBOPlayerInfoSecondItem(kboPlayerInfoStore: kboPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 1, geometry: geometry)
                                        }
                                    }
                                )
                            
                            KBOPlayerInfoThirdItem(kboPlayerInfoStore: kboPlayerInfoStore)
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
                            KBOPlayerInfoFourthItem(kboPlayerInfoStore: kboPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 3, geometry: geometry)
                                        }
                                    }
                                )
                            
                            KBOPlayerInfoFifthItem(kboPlayerInfoStore: kboPlayerInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 4, geometry: geometry)
                                        }
                                    }
                                )
                        }
                        
                        KBOPlayerInfoSixthItem(
                            searchStore: searchStore,
                            kboPlayerInfoStore: kboPlayerInfoStore
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 5, geometry: geometry)
                                }
                            }
                        )
                        
                        KBOPlayerInfoSeventhItem(
                            searchStore: searchStore,
                            kboPlayerInfoStore: kboPlayerInfoStore
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 6, geometry: geometry)
                                }
                            }
                        )
                        
                        KBOPlayerInfoEigthItem(
                            searchStore: searchStore,
                            kboPlayerInfoStore: kboPlayerInfoStore
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
                    if let kboPlayerInfoStore {
                        KBOPlayerInfoFirstItem(
                            kboPlayerInfoStore: kboPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[0],
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        KBOPlayerInfoSecondItem(
                            kboPlayerInfoStore: kboPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[1],
                            itemOffset: scope.computedOffset(for: 1),
                            showContents: scope.showContents
                        )
                        KBOPlayerInfoThirdItem(
                            kboPlayerInfoStore: kboPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[2],
                            itemOffset: scope.computedOffset(for: 2),
                            showContents: scope.showContents
                        )
                        KBOPlayerInfoFourthItem(
                            kboPlayerInfoStore: kboPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[3],
                            itemOffset: scope.computedOffset(for: 3),
                            showContents: scope.showContents
                        )
                        KBOPlayerInfoFifthItem(
                            kboPlayerInfoStore: kboPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[4],
                            itemOffset: scope.computedOffset(for: 4),
                            showContents: scope.showContents
                        )
                        KBOPlayerInfoSixthItem(
                            searchStore: searchStore,
                            kboPlayerInfoStore: kboPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[5],
                            itemOffset: scope.computedOffset(for: 5),
                            showContents: scope.showContents
                        )
                        KBOPlayerInfoSeventhItem(
                            searchStore: searchStore,
                            kboPlayerInfoStore: kboPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[6],
                            itemOffset: scope.computedOffset(for: 6),
                            showContents: scope.showContents
                        )
                        KBOPlayerInfoEigthItem(
                            searchStore: searchStore,
                            kboPlayerInfoStore: kboPlayerInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[7],
                            itemOffset: scope.computedOffset(for: 7),
                            showContents: scope.showContents
                        )
                    }
                }
            )
            .onAppear {
                // init KBOPlayerInfoStore
                let kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore> = storeManager.getStore(forKey: StoreKeys.kboPlayerInfoStore) ?? {
                    let newStore = Store(initialState: KBOPlayerInfoStore.State()) { KBOPlayerInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboPlayerInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.kboPlayerInfoStore = kboPlayerInfoStore
                }
                
                if searchStore.poppedView == nil {
                    kboPlayerInfoStore.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .kboPlayerInfo = searchStore.poppedView {
                    kboPlayerInfoStore?.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

// photo, name
struct KBOPlayerInfoFirstItem: View {
    @Bindable var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboPlayerInfoStore = kboPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let player = kboPlayerInfoStore.baseInfo.displayModel?.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            HCapsuleBar()
            
            URLImage(url: KBOUtil.playerPhotoURL(id: player?.id))
                .opacity(showContents ? 1 : 0)
            
            Text(player?.name ?? "")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
        }
    }
}

// logo, team, name
struct KBOPlayerInfoSecondItem: View {
    @Bindable var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboPlayerInfoStore = kboPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = kboPlayerInfoStore.baseInfo.teamNameDictionary
        let player = kboPlayerInfoStore.baseInfo.displayModel?.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset
        ) {
            HCapsuleBar()
            
            URLImage(url: KBOUtil.teamLogoURL(id: player?.teamId))
                .opacity(showContents ? 1 : 0)
            
            Text(teamNameDic["full_\(player?.teamId)"] ?? "")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
        }
    }
}

// jersey, position
struct KBOPlayerInfoThirdItem: View {
    @Bindable var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboPlayerInfoStore = kboPlayerInfoStore
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
            // added HStack to position Capsule at center
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            if let player = kboPlayerInfoStore.baseInfo.displayModel?.info {
                HStack(spacing: 0) {
                    Text("등번호: ")
                        .font(.system(size: 15))
                    
                    Text(player.jersey)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("포지션: ")
                        .font(.system(size: 15))
                    
                    Text(player.position)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// career info
struct KBOPlayerInfoFourthItem: View {
    @Bindable var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboPlayerInfoStore = kboPlayerInfoStore
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
            // added HStack to position Capsule at center
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            if let player = kboPlayerInfoStore.baseInfo.displayModel?.info {
                HStack(spacing: 0) {
                    Text("드래프트: ")
                        .font(.system(size: 15))
                    
                    Text(player.draftRound)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("경력: ")
                        .font(.system(size: 15))
                    
                    Text("\(KBOUtil.getFullYear(fromYear: player.fromYear))~현재 (\(KBOUtil.calculateYear(fromYear: player.fromYear))년차)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("연봉: ")
                        .font(.system(size: 15))
                    
                    Text(KBOUtil.formatMoney(player.salary))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// birth, age, height, weight
struct KBOPlayerInfoFifthItem: View {
    @Bindable var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboPlayerInfoStore = kboPlayerInfoStore
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
            // added HStack to position Capsule at center
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            if let player = kboPlayerInfoStore.baseInfo.displayModel?.info {
                HStack(spacing: 0) {
                    Text("출생: ")
                        .font(.system(size: 15))
                    
                    Text(player.birthdate)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("나이: ")
                        .font(.system(size: 15))
                    
                    Text("\(CalendarUtil.calculateAge(from: player.birthdate))")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("키: ")
                        .font(.system(size: 15))
                    
                    Text(player.height)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("몸무게: ")
                        .font(.system(size: 15))
                    
                    Text(player.weight)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// league stats
struct KBOPlayerInfoSixthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.kboPlayerInfoStore = kboPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = kboPlayerInfoStore.baseInfo.teamNameDictionary
        let stats = kboPlayerInfoStore.baseInfo.displayModel?.stats
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                if let player = kboPlayerInfoStore.baseInfo.displayModel?.info {
                    searchStore.send(.showPlayerStats(playerId: player.id))
                }
            }
        ) {
            HCapsuleBar()
            
            BaseballLeagueTitle(
                logoUrl: KBOUtil.kboLogoUrl,
                name: "KBO",
                season: stats?.season ?? 2025
            )
            .opacity(showContents ? 1 : 0)
            
            if let hitter = stats?.hitter {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "경기수",
                        data: hitter.g,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "타율",
                        data: hitter.avg,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "홈런",
                        data: hitter.hr,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "ops",
                        data: hitter.ops,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "도루",
                        data: hitter.sb,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                }
                .opacity(showContents ? 1 : 0)
            }
            
            if let pitcher = stats?.pitcher {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "경기수",
                        data: pitcher.g,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "평균자책점",
                        data: pitcher.era,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "승",
                        data: pitcher.w,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "패",
                        data: pitcher.l,
                        customCategoryFontSize: 11,
                        customWidth: .infinity
                    )
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

// last game
struct KBOPlayerInfoSeventhItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.kboPlayerInfoStore = kboPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = kboPlayerInfoStore.baseInfo.teamNameDictionary
        let lastGamePlayerHitterStats = kboPlayerInfoStore.baseInfo.displayModel?.lastGamePlayerHitterStats
        let lastGamePlayerPitcherStats = kboPlayerInfoStore.baseInfo.displayModel?.lastGamePlayerPitcherStats
        
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
                if let lastGame = kboPlayerInfoStore.baseInfo.displayModel?.lastGame {
                    let homeTeamScore = Int(lastGame.lineScore.home.r) ?? 0
                    let awayTeamScore = Int(lastGame.lineScore.away.r) ?? 0
                    
                    VStack {
                        HStack {
                            Text(teamNameDic["short_\(lastGame.gameInfo?.homeTeamId)"] ?? "")
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
                            
                            Text(teamNameDic["short_\(lastGame.gameInfo?.awayTeamId)"] ?? "")
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .lineLimit(1)
                        }
                        
                        Text(CalendarUtil.formatDate(date: lastGame.gameInfo?.date))
                            .font(.system(size: 15))
                            .frame(maxHeight: 30)
                    }
                    .padding(.top, 4)
                }
                
                if lastGamePlayerHitterStats != nil && lastGamePlayerPitcherStats == nil {
                    FBStatDataItem(
                        category: "타수",
                        data: lastGamePlayerHitterStats!.ab,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "안타",
                        data: lastGamePlayerHitterStats!.h,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "득점",
                        data: lastGamePlayerHitterStats!.r,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "타점",
                        data: lastGamePlayerHitterStats!.rbi,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                } else if lastGamePlayerPitcherStats != nil && lastGamePlayerHitterStats == nil {
                    FBStatDataItem(
                        category: "이낭",
                        data: lastGamePlayerPitcherStats!.ip,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "삼진",
                        data: lastGamePlayerPitcherStats!.so,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "볼넷",
                        data: lastGamePlayerPitcherStats!.bb,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "실점",
                        data: lastGamePlayerPitcherStats!.r,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                    
                    FBStatDataItem(
                        category: "자책점",
                        data: lastGamePlayerPitcherStats!.er,
                        customCategoryFontSize: 12,
                        customWidth: .infinity
                    )
                }
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

// next game
struct KBOPlayerInfoEigthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        kboPlayerInfoStore: StoreOf<KBOPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.kboPlayerInfoStore = kboPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = kboPlayerInfoStore.baseInfo.teamNameDictionary
        
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
            
            if let nextGame = kboPlayerInfoStore.baseInfo.displayModel?.nextGame {
                HStack {
                    Text(teamNameDic["short_\(nextGame.gameInfo?.homeTeamId)"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(teamNameDic["short_\(nextGame.gameInfo?.awayTeamId)"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.gameInfo?.date))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        } // VStack
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}
