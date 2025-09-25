//
//  KBOTeamInfoView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTeamInfoView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<KBOTeamInfoStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        InfoViewContainer(itemCount: 8, measureContent: { scope in
            if show {
                HStack(alignment: .top) {
                    KBOTeamInfoFirstItem(kboTeamInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 0, geometry: geometry)
                                }
                            }
                        )
                    
                    KBOTeamInfoSecondItem(kboTeamInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 1, geometry: geometry)
                                }
                            }
                        )
                    
                    KBOTeamInfoThirdItem(kboTeamInfoStore: store)
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
                    kboTeamInfoStore: store
                )
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
                        kboTeamInfoStore: store
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
                        kboTeamInfoStore: store
                    )
                    .frame(maxWidth: .infinity)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                scope.updateItemFrame(index: 5, geometry: geometry)
                            }
                        }
                    )
                }
            }
        }, displayContent: { scope in
            if show {
                KBOTeamInfoFirstItem(
                    kboTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[0],
                    itemOffset: scope.computedOffset(for: 0),
                    showContents: scope.showContents
                )
                KBOTeamInfoSecondItem(
                    kboTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[1],
                    itemOffset: scope.computedOffset(for: 1),
                    showContents: scope.showContents
                )
                KBOTeamInfoThirdItem(
                    kboTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[2],
                    itemOffset: scope.computedOffset(for: 2),
                    showContents: scope.showContents
                )
                KBOTeamInfoFourthItem(
                    searchStore: searchStore,
                    kboTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[3],
                    itemOffset: scope.computedOffset(for: 3),
                    showContents: scope.showContents
                )
                KBOTeamInfoFifthItem(
                    searchStore: searchStore,
                    kboTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[4],
                    itemOffset: scope.computedOffset(for: 4),
                    showContents: scope.showContents
                )
                KBOTeamInfoSixthItem(
                    searchStore: searchStore,
                    kboTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[5],
                    itemOffset: scope.computedOffset(for: 5),
                    showContents: scope.showContents
                )
            }
        })
        .onAppear {
            if !didPop {
                store.send(.baseInfo(.initData))
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
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
        let team = kboTeamInfoStore.baseInfo.displayModel.team
        let teamNameDic = kboTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            URLImage(url: KBOUtil.teamLogoURL(id: team.id))
                .opacity(showContents ? 1 : 0)
            
            Text(teamNameDic["full_\(team.id)"] ?? team.teamName)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
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
        let team = kboTeamInfoStore.baseInfo.displayModel.team
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            HStack(spacing: 0) {
                Text("창단연도: ")
                    .font(.system(size: 15))
                
                Text(String(team.yearFounded))
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            (
                Text("연고지: ")
                    .font(.system(size: 15))
                + Text(team.city)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
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
        let displayModel = kboTeamInfoStore.baseInfo.displayModel
        let teamNameDic = kboTeamInfoStore.baseInfo.teamNameDictionary
        let venue = displayModel.venue
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            (
                Text("홈구장: ")
                    .font(.system(size: 15))
                + Text(teamNameDic["venue_\(displayModel.team.id)"] ?? venue.name)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
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
        let team = kboTeamInfoStore.baseInfo.displayModel.team
        let stats = kboTeamInfoStore.baseInfo.displayModel.stats
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                kboTeamInfoStore.send(.showTeamStats)
            }
        ) {
            BaseballLeagueTitle(
                logoUrl: KBOUtil.kboLogoUrl,
                name: "KBO",
                season: stats?.season
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
                    StatsDivider()
                    FBStatDataItem(
                        category: "승",
                        data: stats.rankData.wins,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "패",
                        data: stats.rankData.losses,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "무",
                        data: stats.rankData.draws,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
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
        .frame(maxWidth: .infinity)
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
        let lastGame = kboTeamInfoStore.baseInfo.displayModel.lastGame
        
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
            
            if let lastGame {
                let homeTeamScore = Int(lastGame.lineScore?.home.r ?? "0") ?? 0
                let awayTeamScore = Int(lastGame.lineScore?.away.r ?? "0") ?? 0
                
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(teamNameDic["short_\(lastGame.gameInfo?.homeTeamId ?? 0)"] ?? "")
                            .font(.system(size: 15))
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
                        
                        Text(teamNameDic["short_\(lastGame.gameInfo?.awayTeamId ?? 0)"] ?? "")
                            .font(.system(size: 15))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: lastGame.gameInfo?.date, formatType: .ampmWithDayOfWeekDate))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        }
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
        let nextGame = kboTeamInfoStore.baseInfo.displayModel.nextGame
        let teamNameDic = kboTeamInfoStore.baseInfo.teamNameDictionary
        
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
            
            if let nextGame {
                HStack {
                    Text(teamNameDic["short_\(nextGame.gameInfo?.homeTeamId ?? 0)"] ?? "")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text(teamNameDic["short_\(nextGame.gameInfo?.awayTeamId ?? 0)"] ?? "")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.gameInfo?.date, formatType: .ampmWithDayOfWeekDate))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            } else {
                Text("예정된 경기가 없습니다.")
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
                    .padding(.top, 4)
            }
        }
    }
}
