//
//  KBOTeamInfoView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTeamInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var kboTeamInfoStore: StoreOf<KBOTeamInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: KBOTeamInfoDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            InfoViewContainer(
                itemCount: 8,
                measureContent: { scope in
                    if let kboTeamInfoStore {
                        HStack(alignment: .top) {
                            KBOTeamInfoFirstItem(kboTeamInfoStore: kboTeamInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            KBOTeamInfoSecondItem(kboTeamInfoStore: kboTeamInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 1, geometry: geometry)
                                        }
                                    }
                                )
                            
                            KBOTeamInfoThirdItem(kboTeamInfoStore: kboTeamInfoStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 2, geometry: geometry)
                                        }
                                    }
                                )
                        }
                        
                        KBOTeamInfoFourthItem(
                            searchStore: searchStore,
                            kboTeamInfoStore: kboTeamInfoStore
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
                            KBOTeamInfoFifthItem(
                                searchStore: searchStore,
                                kboTeamInfoStore: kboTeamInfoStore
                            )
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 4, geometry: geometry)
                                        }
                                    }
                                )
                            
                            KBOTeamInfoSixthItem(
                                searchStore: searchStore,
                                kboTeamInfoStore: kboTeamInfoStore
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
                    if let kboTeamInfoStore {
                        KBOTeamInfoFirstItem(
                            kboTeamInfoStore: kboTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[0],
                            itemOffset: scope.computedOffset(for: 0),
                            showContents: scope.showContents
                        )
                        KBOTeamInfoSecondItem(
                            kboTeamInfoStore: kboTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[1],
                            itemOffset: scope.computedOffset(for: 1),
                            showContents: scope.showContents
                        )
                        KBOTeamInfoThirdItem(
                            kboTeamInfoStore: kboTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[2],
                            itemOffset: scope.computedOffset(for: 2),
                            showContents: scope.showContents
                        )
                        KBOTeamInfoFourthItem(
                            searchStore: searchStore,
                            kboTeamInfoStore: kboTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[3],
                            itemOffset: scope.computedOffset(for: 3),
                            showContents: scope.showContents
                        )
                        KBOTeamInfoFifthItem(
                            searchStore: searchStore,
                            kboTeamInfoStore: kboTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[4],
                            itemOffset: scope.computedOffset(for: 4),
                            showContents: scope.showContents
                        )
                        KBOTeamInfoSixthItem(
                            searchStore: searchStore,
                            kboTeamInfoStore: kboTeamInfoStore,
                            isAniItem: true,
                            itemSize: scope.itemSizes[5],
                            itemOffset: scope.computedOffset(for: 5),
                            showContents: scope.showContents
                        )
                    }
                }
            )
            .onAppear {
                // init KBOTeamInfoStore
                let kboTeamInfoStore: StoreOf<KBOTeamInfoStore> = storeManager.getStore(forKey: StoreKeys.kboTeamInfoStore) ?? {
                    let newStore = Store(initialState: KBOTeamInfoStore.State()) { KBOTeamInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboTeamInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.kboTeamInfoStore = kboTeamInfoStore
                }
                
                if searchStore.poppedView == nil {
                    kboTeamInfoStore.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .kboTeamInfo = searchStore.poppedView {
                    kboTeamInfoStore?.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

// logo, team, name
struct KBOTeamInfoFirstItem: View {
    @Bindable var kboTeamInfoStore: StoreOf<KBOTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboTeamInfoStore: StoreOf<KBOTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboTeamInfoStore = kboTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = kboTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            HCapsuleBar()
            
            if let team = kboTeamInfoStore.baseInfo.displayModel?.team {
                URLImage(url: KBOUtil.teamLogoURL(id: team.id))
                    .opacity(showContents ? 1 : 0)
                
                Text(teamNameDic["full_\(team.id)"] ?? team.teamName)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// founded, city, coach
struct KBOTeamInfoSecondItem: View {
    @Bindable var kboTeamInfoStore: StoreOf<KBOTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboTeamInfoStore: StoreOf<KBOTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboTeamInfoStore = kboTeamInfoStore
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
            
            if let team = kboTeamInfoStore.baseInfo.displayModel?.team {
                HStack(spacing: 0) {
                    Text("창단연도: ")
                        .font(.system(size: 15))
                    
                    Text(String(team.yearFounded))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("연고지: ")
                        .font(.system(size: 15))
                    
                    Text(team.city)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.vertical, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("감독: ")
                        .font(.system(size: 15))
                    
                    Text(team.coach)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// venue
struct KBOTeamInfoThirdItem: View {
    @Bindable var kboTeamInfoStore: StoreOf<KBOTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        kboTeamInfoStore: StoreOf<KBOTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboTeamInfoStore = kboTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = kboTeamInfoStore.baseInfo.teamNameDictionary
        
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
            
            if let displayModel = kboTeamInfoStore.baseInfo.displayModel {
                let venue = displayModel.venue
                
                HStack(spacing: 0) {
                    Text("홈구장: ")
                        .font(.system(size: 15))
                    
                    Text(teamNameDic["venue_\(displayModel.team.id)"] ?? venue.name)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("좌석수: ")
                        .font(.system(size: 15))
                    
                    Text(String(venue.capacity))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("개장: ")
                        .font(.system(size: 15))
                    
                    Text(String(venue.opened))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

// league stats
struct KBOTeamInfoFourthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboTeamInfoStore: StoreOf<KBOTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        kboTeamInfoStore: StoreOf<KBOTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.kboTeamInfoStore = kboTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let team = kboTeamInfoStore.baseInfo.displayModel?.team
        let stats = kboTeamInfoStore.baseInfo.displayModel?.stats
        
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
                logoUrl: KBOUtil.kboLogoUrl,
                name: "KBO",
                season: stats?.season ?? 2025
            )
            .opacity(showContents ? 1 : 0)
            
            if let stats {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "순위",
                        data: stats.rankData.rank,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    FBStatDataItem(
                        category: "승",
                        data: stats.rankData.wins,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    FBStatDataItem(
                        category: "패",
                        data: stats.rankData.losses,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    FBStatDataItem(
                        category: "무",
                        data: stats.rankData.draws,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    FBStatDataItem(
                        category: "타율",
                        data: stats.hitterData.avg,
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
struct KBOTeamInfoFifthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboTeamInfoStore: StoreOf<KBOTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        kboTeamInfoStore: StoreOf<KBOTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.kboTeamInfoStore = kboTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = kboTeamInfoStore.baseInfo.teamNameDictionary
        
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
                if let lastGame = kboTeamInfoStore.baseInfo.displayModel?.lastGame {
                    let homeTeamScore = lastGame.lineScore.home.r
                    let awayTeamScore = lastGame.lineScore.away.r
                    
                    VStack {
                        HStack {
                            Text(teamNameDic["short_\(lastGame.gameInfo?.homeTeamId ?? "")"] ?? "")
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
                            
                            Text(teamNameDic["short_\(lastGame.gameInfo?.awayTeamId ?? "")"] ?? "")
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
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

// next game
struct KBOTeamInfoSixthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboTeamInfoStore: StoreOf<KBOTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        kboTeamInfoStore: StoreOf<KBOTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.kboTeamInfoStore = kboTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = kboTeamInfoStore.baseInfo.teamNameDictionary
        
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
            
            if let nextGame = kboTeamInfoStore.baseInfo.displayModel?.nextGame {
                HStack {
                    Text(teamNameDic["short_\(nextGame.gameInfo?.homeTeamId ?? "")"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(teamNameDic["short_\(nextGame.gameInfo?.awayTeamId ?? "")"] ?? "")
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
