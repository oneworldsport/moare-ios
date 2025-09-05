//
//  FBTeamInfoView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import SwiftUI
import ComposableArchitecture

struct FBTeamInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbTeamInfoStore: StoreOf<FBTeamInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBTeamInfoDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            InfoViewContainer(itemCount: 6, measureContent: { scope in
                if let fbTeamInfoStore {
                    HStack(alignment: .top) {
                        FBTeamInfoFirstItem(fbTeamInfoStore: fbTeamInfoStore)
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 0, geometry: geometry)
                                    }
                                }
                            )
                        
                        FBTeamInfoSecondItem(fbTeamInfoStore: fbTeamInfoStore)
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 1, geometry: geometry)
                                    }
                                }
                            )
                        
                        FBTeamInfoThirdItem(fbTeamInfoStore: fbTeamInfoStore)
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 2, geometry: geometry)
                                    }
                                }
                            )
                    }
                    
                    FBTeamInfoFourthItem(
                        searchStore: searchStore,
                        fbTeamInfoStore: fbTeamInfoStore
                    )
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                scope.updateItemFrame(index: 3, geometry: geometry)
                            }
                        }
                    )
                    
                    HStack(alignment: .top) {
                        FBTeamInfoFifthItem(
                            searchStore: searchStore,
                            fbTeamInfoStore: fbTeamInfoStore
                        )
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 4, geometry: geometry)
                                }
                            }
                        )
                        
                        FBTeamInfoSixthItem(
                            searchStore: searchStore,
                            fbTeamInfoStore: fbTeamInfoStore
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
                if let fbTeamInfoStore {
                    // logo, name
                    FBTeamInfoFirstItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        isAniItem: true,
                        itemSize: scope.itemSizes[0],
                        itemOffset: scope.computedOffset(for: 0),
                        showContents: scope.showContents
                    )
                    
                    // founded, city, country
                    FBTeamInfoSecondItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        isAniItem: true,
                        itemSize: scope.itemSizes[1],
                        itemOffset: scope.computedOffset(for: 1),
                        showContents: scope.showContents
                    )
                    
                    // venue
                    FBTeamInfoThirdItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        isAniItem: true,
                        itemSize: scope.itemSizes[2],
                        itemOffset: scope.computedOffset(for: 2),
                        showContents: scope.showContents
                    )
                    
                    // league stats
                    FBTeamInfoFourthItem(
                        searchStore: searchStore,
                        fbTeamInfoStore: fbTeamInfoStore,
                        isAniItem: true,
                        itemSize: scope.itemSizes[3],
                        itemOffset: scope.computedOffset(for: 3),
                        showContents: scope.showContents
                    )
                    
                    // last game stats
                    FBTeamInfoFifthItem(
                        searchStore: searchStore,
                        fbTeamInfoStore: fbTeamInfoStore,
                        isAniItem: true,
                        itemSize: scope.itemSizes[4],
                        itemOffset: scope.computedOffset(for: 4),
                        showContents: scope.showContents
                    )
                    
                    // next game stats
                    FBTeamInfoSixthItem(
                        searchStore: searchStore,
                        fbTeamInfoStore: fbTeamInfoStore,
                        isAniItem: true,
                        itemSize: scope.itemSizes[5],
                        itemOffset: scope.computedOffset(for: 5),
                        showContents: scope.showContents
                    )
                }
            })
            .onAppear {
                // init FBTeamInfoStore
                let fbTeamInfoStore: StoreOf<FBTeamInfoStore> = storeManager.getStore(forKey: StoreKeys.fbTeamInfoStore) ?? {
                    let newStore = Store(initialState: FBTeamInfoStore.State()) { FBTeamInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTeamInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.fbTeamInfoStore = fbTeamInfoStore
                }
                
                if searchStore.poppedView == nil {
                    fbTeamInfoStore.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .fbTeamInfo = searchStore.poppedView {
                    fbTeamInfoStore?.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

struct FBTeamInfoFirstItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbTeamInfoStore: StoreOf<FBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            if let team = fbTeamInfoStore.baseInfo.displayModel?.team {
                URLImage(url: team.logo)
                    .opacity(showContents ? 1 : 0)
                
                Text(teamNameDic["full_\(team.id)"] ?? team.name)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
                
                Text(team.name)
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .lineLimit(2)
                    .opacity(showContents ? 1 : 0)
            }
        }
    }
}

struct FBTeamInfoSecondItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbTeamInfoStore: StoreOf<FBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbTeamInfoStore = fbTeamInfoStore
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
            if let team = fbTeamInfoStore.baseInfo.displayModel?.team {
                HStack(spacing: 0) {
                    Text("창단연도: ")
                        .font(.system(size: 15))
                        
                    Text(String(team.founded))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("연고지: ")
                        .font(.system(size: 15))
                        
                    Text(fbTeamInfoStore.baseInfo.displayModel!.venue.city)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("소속나라: ")
                        .font(.system(size: 15))
                        
                    Text(EnNameTranslationUtility.translateByDic(type: .country, input: team.country))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
    }
}

struct FBTeamInfoThirdItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbTeamInfoStore: StoreOf<FBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            if let displayModel = fbTeamInfoStore.baseInfo.displayModel {
                let team = displayModel.team
                let venue = displayModel.venue
                
                (
                    Text("홈구장: ")
                        .font(.system(size: 15))
                    + Text(teamNameDic["venue_\(team.id)"] ?? (venue.name))
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
            }
        }
    }
}

struct FBTeamInfoFourthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        fbTeamInfoStore: StoreOf<FBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.fbTeamInfoStore = fbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = fbTeamInfoStore.baseInfo.displayModel
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                if let team = fbTeamInfoStore.baseInfo.displayModel?.team {
                    searchStore.send(.showTeamStats(teamId: team.id))
                }
            }
        ) {
            if let league = displayModel?.stats?.league {
                LeagueTitle(
                    url: league.logo,
                    leagueName: league.name,
                    leagueSeason: league.season
                )
                .opacity(showContents ? 1 : 0)
            }
            
            if let stats = displayModel?.stats {
                HStack(spacing: 0) {
                    FBStatDataItem(category: "승", data: "\(stats.fixtures.wins.total)")
                        .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(category: "무", data: "\(stats.fixtures.draws.total)")
                        .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(category: "패", data: "\(stats.fixtures.loses.total)")
                        .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(category: "득점", data: "\(stats.goals.teamGoalsFor.total.total)")
                        .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(category: "실점", data: "\(stats.goals.teamGoalsAgainst.total.total)")
                        .frame(maxWidth: .infinity)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBTeamInfoFifthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        fbTeamInfoStore: StoreOf<FBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.fbTeamInfoStore = fbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbTeamInfoStore.baseInfo.teamNameDictionary
        
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
            
            if let lastGame = fbTeamInfoStore.baseInfo.displayModel?.lastGame {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(teamNameDic["short_\(lastGame.teams.home.id)"] ?? lastGame.teams.home.name)
                            .font(.system(size: 15))
                            .lineLimit(1)
                        
                        Text(" \(lastGame.goals.home)")
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                            .foregroundStyle((lastGame.goals.home > lastGame.goals.away) ? .moare : .primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" - ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    HStack(spacing: 0) {
                        Text("\(lastGame.goals.away) ")
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                            .foregroundStyle((lastGame.goals.away > lastGame.goals.home) ? .moare : .primary)
                        
                        Text(teamNameDic["short_\(lastGame.teams.away.id)"] ?? lastGame.teams.away.name)
                            .font(.system(size: 15))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: lastGame.fixture.date, formatType: .ampmWithDayOfWeekDate))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        }
    }
}

struct FBTeamInfoSixthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        fbTeamInfoStore: StoreOf<FBTeamInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.fbTeamInfoStore = fbTeamInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbTeamInfoStore.baseInfo.teamNameDictionary
        
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
            
            if let nextGame = fbTeamInfoStore.baseInfo.displayModel?.nextGame {
                HStack {
                    Text(teamNameDic["short_\(nextGame.teams.home.id)"] ?? nextGame.teams.home.name)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text(teamNameDic["short_\(nextGame.teams.away.id)"] ?? nextGame.teams.away.name)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.fixture.date, formatType: .ampmWithDayOfWeekDate))
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
