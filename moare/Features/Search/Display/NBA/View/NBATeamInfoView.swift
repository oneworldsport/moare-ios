//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamInfoView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<NBATeamInfoStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        InfoViewContainer(itemCount: 6, measureContent: { scope in
            if show {
                HStack(alignment: .top) {
                    // logo, team, name
                    NBATeamInfoFirstItem(nbaTeamInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 0, geometry: geometry)
                                }
                            }
                        )
                    
                    NBATeamInfoSecondItem(nbaTeamInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 1, geometry: geometry)
                                }
                            }
                        )
                    
                    NBATeamInfoThirdItem(nbaTeamInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 2, geometry: geometry)
                                }
                            }
                        )
                }
                
                NBATeamInfoFourthItem(
                    searchStore: searchStore,
                    nbaTeamInfoStore: store
                )
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                scope.updateItemFrame(index: 3, geometry: geometry)
                            }
                        }
                    )
                
                HStack {
                    NBATeamInfoFifthItem(
                        searchStore: searchStore,
                        nbaTeamInfoStore: store
                    )
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 4, geometry: geometry)
                                }
                            }
                        )

                    NBATeamInfoSixthItem(
                        searchStore: searchStore,
                        nbaTeamInfoStore: store
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
            } // if let nbaTeamInfoStore
        }, displayContent: { scope in
            if show {
                // logo, team, name
                NBATeamInfoFirstItem(
                    nbaTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[0],
                    itemOffset: scope.computedOffset(for: 0),
                    showContents: scope.showContents
                )
                
                // founded, state and city, conference and division
                NBATeamInfoSecondItem(
                    nbaTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[1],
                    itemOffset: scope.computedOffset(for: 1),
                    showContents: scope.showContents
                )
                
                // venue
                NBATeamInfoThirdItem(
                    nbaTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[2],
                    itemOffset: scope.computedOffset(for: 2),
                    showContents: scope.showContents
                )
                
                // league stats
                NBATeamInfoFourthItem(
                    searchStore: searchStore,
                    nbaTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[3],
                    itemOffset: scope.computedOffset(for: 3),
                    showContents: scope.showContents
                )
                
                // last game stats
                NBATeamInfoFifthItem(
                    searchStore: searchStore,
                    nbaTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[4],
                    itemOffset: scope.computedOffset(for: 4),
                    showContents: scope.showContents
                )
                
                // next game stats
                NBATeamInfoSixthItem(
                    searchStore: searchStore,
                    nbaTeamInfoStore: store,
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

struct NBATeamInfoFirstItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaTeamInfoStore: StoreOf<NBATeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let team = nbaTeamInfoStore.baseInfo.displayModel.team
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            URLImage(url: NBAUtil.teamLogoURL(id: team.id), isSvg: true)
                .opacity(showContents ? 1 : 0)
            
            Text(nbaTeamInfoStore.baseInfo.teamNameDictionary["full_\(team.id)"] ?? team.fullName)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            Text(team.fullName)
                .font(.system(size: 12))
                .fontWeight(.light)
                .lineLimit(2)
                .opacity(showContents ? 1 : 0)
        }
    }
}

struct NBATeamInfoSecondItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaTeamInfoStore: StoreOf<NBATeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
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
            let team = nbaTeamInfoStore.baseInfo.displayModel.team
            
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
                + Text(team.state)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("컨퍼런스/디비전: ")
                    .font(.system(size: 15))
                
                Text("\(team.teamConference) / \(team.teamDivision)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
        }
    }
}

struct NBATeamInfoThirdItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaTeamInfoStore: StoreOf<NBATeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaTeamInfoStore.baseInfo.displayModel
        let venue = displayModel.venue
        let team = displayModel.team
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            (
                Text("홈구장: ")
                    .font(.system(size: 15))
                + Text(nbaTeamInfoStore.baseInfo.teamNameDictionary["venue_\(team.id)"] ?? venue.name)
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

struct NBATeamInfoFourthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        nbaTeamInfoStore: StoreOf<NBATeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let team = nbaTeamInfoStore.baseInfo.displayModel.team
        let stats = nbaTeamInfoStore.baseInfo.displayModel.stats
        
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                nbaTeamInfoStore.send(.showTeamStats)
            }
        ) {
            NBATitle(
                leagueName: "NBA 정규시즌",
                leagueSeason: Int(stats?.groupValue.split(separator: "-").first ?? "\(CalendarUtil.currentYear)")
            )
            .opacity(showContents ? 1 : 0)
            
            if let stats {
                HStack {
                    FBStatDataItem(
                        category: "\(NBAUtil.translateEastWest(team.teamConference)) 컨퍼런스 순위",
                        data: "\(team.confRank)",
                        customCategoryFontSize: 12,
                        customWidth: 80
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "승",
                        data: "\(stats.wins)"
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "패",
                        data: "\(stats.losses)"
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "경기당 득점",
                        data: "\(stats.ptsPG)",
                        customWidth: 80
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

struct NBATeamInfoFifthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        nbaTeamInfoStore: StoreOf<NBATeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = nbaTeamInfoStore.baseInfo.teamNameDictionary
        let lastGame = nbaTeamInfoStore.baseInfo.displayModel.lastGame
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                nbaTeamInfoStore.send(.showGameStats())
            }
        ) {
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let lastGame {
                let homeTeam = lastGame.boxScoreTraditional?.homeTeam
                let awayTeam = lastGame.boxScoreTraditional?.awayTeam
                let homeTeamScore = lastGame.lineScore?.first { $0.teamId == homeTeam?.teamId }?.pts ?? 0
                let awayTeamScore = lastGame.lineScore?.first { $0.teamId == awayTeam?.teamId }?.pts ?? 0
                
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(homeTeam == nil ? "" : teamNameDic["short_\(homeTeam!.teamId)"] ?? homeTeam!.teamCity)
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
                        
                        Text(awayTeam == nil ? "" : teamNameDic["short_\(awayTeam!.teamId)"] ?? awayTeam!.teamCity)
                            .font(.system(size: 15))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: lastGame.gameSummary?.gameDate, formatType: .ampmWithDayOfWeekDate))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        }
    }
}

struct NBATeamInfoSixthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        nbaTeamInfoStore: StoreOf<NBATeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = nbaTeamInfoStore.baseInfo.teamNameDictionary
        let nextGame = nbaTeamInfoStore.baseInfo.displayModel.nextGame
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                nbaTeamInfoStore.send(.showGameStats(isPrevious: false))
            }
        ) {
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame {
                let homeTeamId = nextGame.gameSummary?.homeTeamId
                let awayTeamId = nextGame.gameSummary?.awayTeamId
                
                HStack {
                    Text(homeTeamId == nil ? "" : teamNameDic["short_\(homeTeamId ?? 0)"] ?? "")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text(awayTeamId == nil ? "" : teamNameDic["short_\(awayTeamId ?? 0)"] ?? "")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.gameSummary?.gameDate, formatType: .ampmWithDayOfWeekDate))
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
