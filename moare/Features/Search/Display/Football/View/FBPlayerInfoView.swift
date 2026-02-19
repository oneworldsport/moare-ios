//
//  PlayerInfoView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/13/24.
//

import SwiftUI
import ComposableArchitecture

struct FBPlayerInfoView: View {
    let searchStore: StoreOf<SearchStore> // TODO: 구조 고민 필요
    let store: StoreOf<FBPlayerInfoStore>
    let didPop: Bool
    
    @State private var show = false // NOTE: Store 리팩토링 후 처음 오픈 시 애니메이션이 안먹어서 만듬
    
    var body: some View {
        InfoViewContainer(itemCount: 6, measureContent: { scope in
            if show {
                HStack(alignment: .top) {
                    FBPlayerInfoFirstItem(fbPlayerInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                // NOTE: 처음 오픈 시 animation이 적용되기 때문에 onAppear가 아니라 onChange로 해야함
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 0, geometry: geometry)
                                }
                            }
                        )
                    
                    FBPlayerInfoSecondItem(fbPlayerInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 1, geometry: geometry)
                                }
                            }
                        )
                    
                    FBPlayerInfoThirdItem(fbPlayerInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 2, geometry: geometry)
                                }
                            }
                        )
                }
                
                FBPlayerInfoFourthItem(
                    searchStore: searchStore,
                    fbPlayerInfoStore: store
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                            scope.updateItemFrame(index: 3, geometry: geometry)
                        }
                    }
                )
                
                FBPlayerInfoFifthItem(
                    searchStore: searchStore,
                    fbPlayerInfoStore: store
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                            scope.updateItemFrame(index: 4, geometry: geometry)
                        }
                    }
                )
                
                FBPlayerInfoSixthItem(
                    searchStore: searchStore,
                    fbPlayerInfoStore: store
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                            scope.updateItemFrame(index: 5, geometry: geometry)
                        }
                    }
                )
            }
        }, displayContent: { scope in
            if show {
                // photo, name
                FBPlayerInfoFirstItem(
                    fbPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[0],
                    itemOffset: scope.computedOffset(for: 0),
                    showContents: scope.showContents
                )
                
                // age, birth, nationality
                FBPlayerInfoSecondItem(
                    fbPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[1],
                    itemOffset: scope.computedOffset(for: 1),
                    showContents: scope.showContents
                )
                
                // weight, height
                FBPlayerInfoThirdItem(
                    fbPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[2],
                    itemOffset: scope.computedOffset(for: 2),
                    showContents: scope.showContents
                )
                
                // league stats
                FBPlayerInfoFourthItem(
                    searchStore: searchStore,
                    fbPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[3],
                    itemOffset: scope.computedOffset(for: 3),
                    showContents: scope.showContents
                )
                
                // last game stats
                FBPlayerInfoFifthItem(
                    searchStore: searchStore,
                    fbPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[4],
                    itemOffset: scope.computedOffset(for: 4),
                    showContents: scope.showContents
                )
                
                // next game
                FBPlayerInfoSixthItem(
                    searchStore: searchStore,
                    fbPlayerInfoStore: store,
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

struct FBPlayerInfoFirstItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let playerNameDic = fbPlayerInfoStore.baseInfo.playerNameDictionary
        let player = fbPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            URLImage(url: player.photo)
                .opacity(showContents ? 1 : 0)
            
            Text(playerNameDic["\(player.id)"] ?? (player.name))
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            Text(player.name)
                .font(.system(size: 12))
                .fontWeight(.light)
                .lineLimit(2)
                .opacity(showContents ? 1 : 0)
        }
    }
}

struct FBPlayerInfoSecondItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let player = fbPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            (
                Text("국적: ")
                    .font(.system(size: 15))
                + Text(player.nationality)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
            
            (
                Text("출생: ")
                    .font(.system(size: 15))
                + Text(player.birth.date)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("나이: ")
                    .font(.system(size: 15))
                
                Text("\(player.age)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
        }
    }
}

struct FBPlayerInfoThirdItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let player = fbPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
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

struct FBPlayerInfoFourthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbPlayerInfoStore.baseInfo.teamNameDictionary
        let stats = fbPlayerInfoStore.baseInfo.displayModel.stats
        let team = stats?.team
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                fbPlayerInfoStore.send(.showPlayerStats)
            }
        ) {
            if let league = stats?.league {
                FBLeagueTitle(
                    url: league.logo,
                    leagueName: league.name,
                    leagueSeason: league.season
                )
                .opacity(showContents ? 1 : 0)
            }
            
            HStack {
                VStack(spacing: 0) {
                    Text("소속팀")
                        .font(.system(size: 15))
                        .frame(height: fbPlayerInfoStore.itemHeight)
                    
                    if let team {
                        HStack {
                            URLImage(url: team.logo, size: .small)
                            
                            Text(teamNameDic["full_\(team.id)"] ?? team.name)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        .frame(height: fbPlayerInfoStore.itemHeight)
                    }
                }
                
                if let stats {
                    StatsDivider()
                    FBStatDataItem(category: "경기수", data: "\(stats.games.appearences)")
                    StatsDivider()
                    FBStatDataItem(category: "골", data: "\(stats.goals.total)")
                    StatsDivider()
                    FBStatDataItem(category: "도움", data: "\(stats.goals.assists)")
                }
            }
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBPlayerInfoFifthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbPlayerInfoStore.baseInfo.teamNameDictionary
        let lastGame = fbPlayerInfoStore.baseInfo.displayModel.lastGame
        let lastGamePlayerStats = fbPlayerInfoStore.baseInfo.displayModel.lastGamePlayerStats
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                fbPlayerInfoStore.send(.showGameStats())
            }
        ) {
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            HStack {
                if let lastGame {
                    VStack {
                        HStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text(teamNameDic["short_\(lastGame.teams.home.id)"] ?? lastGame.teams.home.name)
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .lineLimit(1)
                                
                                Text(" \(lastGame.goals.home)")
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                    .foregroundStyle((lastGame.goals.home >= lastGame.goals.away) ? .moare : .primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text(" - ")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                            
                            
                            HStack(spacing: 0) {
                                Text("\(lastGame.goals.away) ")
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                    .foregroundStyle((lastGame.goals.away >= lastGame.goals.home) ? .moare : .primary)
                                
                                Text(teamNameDic["short_\(lastGame.teams.away.id)"] ?? lastGame.teams.away.name)
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text(CalendarUtil.formatDate(date: lastGame.fixture.date, outputFormatType: .ampmWithDayOfWeekDate))
                            .font(.system(size: 15))
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.45) // NOTE: 너비를 화면 전체 너비중 45%로 고정
                }
                
                if let lastGamePlayerStats {
                    HStack {
                        StatsDivider()
                        FBStatDataItem(
                            category: "출전시간",
                            data: (lastGamePlayerStats.games.substitute ? "후보" : "선발") + " / \(lastGamePlayerStats.games.minutes)분",
                            customWidth: 80
                        )
                        StatsDivider()
                        FBStatDataItem(category: "골", data: "\(lastGamePlayerStats.goals.total)")
                        StatsDivider()
                        FBStatDataItem(category: "도움", data: "\(lastGamePlayerStats.goals.assists)")
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

struct FBPlayerInfoSixthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbPlayerInfoStore.baseInfo.teamNameDictionary
        let nextGame = fbPlayerInfoStore.baseInfo.displayModel.nextGame
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                fbPlayerInfoStore.send(.showGameStats(isPrevious: false))
            }
        ) {
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame {
                HStack {
                    Text(teamNameDic["short_\(nextGame.teams.home.id)"] ?? nextGame.teams.home.name)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(teamNameDic["short_\(nextGame.teams.away.id)"] ?? nextGame.teams.away.name)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.fixture.date, outputFormatType: .ampmWithDayOfWeekDate))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            } else {
                Text("예정된 경기가 없습니다.")
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
                    .padding(.top, 4)
            }
        } // VStack
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}
