//
//  MLBTeamInfoView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBTeamInfoView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<MLBTeamInfoStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        InfoViewContainer(itemCount: 8, measureContent: { scope in
            if show {
                HStack(alignment: .top) {
                    MLBTeamInfoFirstItem(mlbTeamInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 0, geometry: geometry)
                                }
                            }
                        )
                    
                    MLBTeamInfoSecondItem(mlbTeamInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 1, geometry: geometry)
                                }
                            }
                        )
                    
                    MLBTeamInfoThirdItem(mlbTeamInfoStore: store)
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
                    mlbTeamInfoStore: store
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
                        mlbTeamInfoStore: store
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
                        mlbTeamInfoStore: store
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
        }, displayContent: { scope in
            if show {
                MLBTeamInfoFirstItem(
                    mlbTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[0],
                    itemOffset: scope.computedOffset(for: 0),
                    showContents: scope.showContents
                )
                MLBTeamInfoSecondItem(
                    mlbTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[1],
                    itemOffset: scope.computedOffset(for: 1),
                    showContents: scope.showContents
                )
                MLBTeamInfoThirdItem(
                    mlbTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[2],
                    itemOffset: scope.computedOffset(for: 2),
                    showContents: scope.showContents
                )
                MLBTeamInfoFourthItem(
                    searchStore: searchStore,
                    mlbTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[3],
                    itemOffset: scope.computedOffset(for: 3),
                    showContents: scope.showContents
                )
                MLBTeamInfoFifthItem(
                    searchStore: searchStore,
                    mlbTeamInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[4],
                    itemOffset: scope.computedOffset(for: 4),
                    showContents: scope.showContents
                )
                MLBTeamInfoSixthItem(
                    searchStore: searchStore,
                    mlbTeamInfoStore: store,
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
        let team = mlbTeamInfoStore.baseInfo.displayModel.team
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
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
        let team = mlbTeamInfoStore.baseInfo.displayModel.team
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            HStack(spacing: 0) {
                Text("창단연도: ")
                    .font(.system(size: 15))
                
                Text(team.firstYearOfPlay)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            (
                Text("연고지: ")
                    .font(.system(size: 15))
                + Text(team.locationName)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("컨퍼런스/디비전: ")
                    .font(.system(size: 15))
                
                Text("\(MLBUtil.leagueDivisionMap[team.league.id] ?? team.league.name) / " +
                     "\(MLBUtil.leagueDivisionMap[team.division.id] ?? team.division.name)")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
            }
            .opacity(showContents ? 1 : 0)
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
        let displayModel = mlbTeamInfoStore.baseInfo.displayModel
        let teamNameDic = mlbTeamInfoStore.baseInfo.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
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
        let team = mlbTeamInfoStore.baseInfo.displayModel.team
        let stats = mlbTeamInfoStore.baseInfo.displayModel.stats
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                mlbTeamInfoStore.send(.showTeamStats)
            }
        ) {
            BaseballLeagueTitle(
                logoUrl: MLBUtil.mlbLogoUrl,
                name: "MLB",
                season: team.season
            )
            .opacity(showContents ? 1 : 0)
            
            if let recordData = stats?.recordData {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "디비전 순위",
                        data: recordData.divisionRank,
                        customCategoryFontSize: 11,
                        customWidth: 80
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "승",
                        data: String(recordData.wins),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "패",
                        data: String(recordData.losses),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "무",
                        data: String(recordData.leagueRecord.ties),
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
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
        .frame(maxWidth: .infinity)
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
        let lastGame = mlbTeamInfoStore.baseInfo.displayModel.lastGame
        
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
                let homeTeamScore = lastGame.linescore?.teams.home.runs ?? 0
                let awayTeamScore = lastGame.linescore?.teams.away.runs ?? 0
                
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(teamNameDic["short_\(lastGame.teams.home.id)"] ?? "")
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
                        
                        Text(teamNameDic["short_\(lastGame.teams.away.id)"] ?? "")
                            .font(.system(size: 15))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: lastGame.gameInfo.gameDate, formatType: .ampmWithDayOfWeekDate))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        }
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
        let nextGame = mlbTeamInfoStore.baseInfo.displayModel.nextGame
        
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
                    Text(teamNameDic["short_\(nextGame.teams.home.id)"] ?? "")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text(teamNameDic["short_\(nextGame.teams.away.id)"] ?? "")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
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
    }
}
