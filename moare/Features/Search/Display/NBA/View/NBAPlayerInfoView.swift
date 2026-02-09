//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerInfoView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<NBAPlayerInfoStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        InfoViewContainer(itemCount: 6, measureContent: { scope in
            if show {
                HStack(alignment: .top) {
                    NBAPlayerInfoFirstItem(nbaPlayerInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                // NOTE: 처음 오픈 시 animation이 적용되기 때문에 onAppear가 아니라 onChange로 해야함
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 0, geometry: geometry)
                                }
                            }
                        )
                    
                    NBAPlayerInfoSecondItem(nbaPlayerInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 1, geometry: geometry)
                                }
                            }
                        )
                    
                    NBAPlayerInfoThirdItem(nbaPlayerInfoStore: store)
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
                    NBAPlayerInfoFourthItem(nbaPlayerInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 3, geometry: geometry)
                                }
                            }
                        )
                    
                    NBAPlayerInfoFifthItem(nbaPlayerInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 4, geometry: geometry)
                                }
                            }
                        )
                    
                    NBAPlayerInfoSixthItem(nbaPlayerInfoStore: store)
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 5, geometry: geometry)
                                }
                            }
                        )
                }
                
                NBAPlayerInfoSeventhItem(
                    searchStore: searchStore,
                    nbaPlayerInfoStore: store
                )
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                scope.updateItemFrame(index: 6, geometry: geometry)
                            }
                        }
                    )
                
                NBAPlayerInfoEighthItem(
                    searchStore: searchStore,
                    nbaPlayerInfoStore: store
                )
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                scope.updateItemFrame(index: 7, geometry: geometry)
                            }
                        }
                    )
                
                NBAPlayerInfoNinthItem(
                    searchStore: searchStore,
                    nbaPlayerInfoStore: store
                )
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                scope.updateItemFrame(index: 8, geometry: geometry)
                            }
                        }
                    )
            } // if let nbaPlayerInfoStore
        }, displayContent: { scope in
            if show {
                // photo, name
                NBAPlayerInfoFirstItem(
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[0],
                    itemOffset: scope.computedOffset(for: 0),
                    showContents: scope.showContents
                )
                
                // logo, team, name
                NBAPlayerInfoSecondItem(
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[1],
                    itemOffset: scope.computedOffset(for: 1),
                    showContents: scope.showContents
                )
                
                // jersey, position
                NBAPlayerInfoThirdItem(
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[2],
                    itemOffset: scope.computedOffset(for: 2),
                    showContents: scope.showContents
                )
                
                // from school/team, draft info, career info
                NBAPlayerInfoFourthItem(
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[3],
                    itemOffset: scope.computedOffset(for: 3),
                    showContents: scope.showContents
                )
                
                // country, birth, age
                NBAPlayerInfoFifthItem(
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[4],
                    itemOffset: scope.computedOffset(for: 4),
                    showContents: scope.showContents
                )
                
                // weight(kg/pound), height(cm/feet)
                NBAPlayerInfoSixthItem(
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[5],
                    itemOffset: scope.computedOffset(for: 5),
                    showContents: scope.showContents
                )
                
                // league stats
                NBAPlayerInfoSeventhItem(
                    searchStore: searchStore,
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[6],
                    itemOffset: scope.computedOffset(for: 6),
                    showContents: scope.showContents
                )
                
                // last game
                NBAPlayerInfoEighthItem(
                    searchStore: searchStore,
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[7],
                    itemOffset: scope.computedOffset(for: 7),
                    showContents: scope.showContents
                )
                
                // next game
                NBAPlayerInfoNinthItem(
                    searchStore: searchStore,
                    nbaPlayerInfoStore: store,
                    isAniItem: true,
                    itemSize: scope.itemSizes[8],
                    itemOffset: scope.computedOffset(for: 8),
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

struct NBAPlayerInfoFirstItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let playerNameDic = nbaPlayerInfoStore.baseInfo.playerNameDictionary
        let player = nbaPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            URLImage(url: NBAUtil.playerPhotoURL(id: player.personId))
                .opacity(showContents ? 1 : 0)
            
            Text(playerNameDic["\(player.personId)"] ?? player.displayFirstLast)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            Text(player.displayFirstLast)
                .font(.system(size: 12))
                .fontWeight(.light)
                .lineLimit(2)
                .opacity(showContents ? 1 : 0)
        }
    }
}

struct NBAPlayerInfoSecondItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = nbaPlayerInfoStore.baseInfo.teamNameDictionary
        let player = nbaPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            URLImage(url: NBAUtil.teamLogoURL(id: player.teamId), isSvg: true)
                .opacity(showContents ? 1 : 0)
            
            Text(teamNameDic["full_\(player.teamId)"] ?? "\(player.teamCity) \(player.teamName)")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
        }
    }
}

struct NBAPlayerInfoThirdItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let player = nbaPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
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

struct NBAPlayerInfoFourthItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let player = nbaPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            VStack(alignment: .leading, spacing: 0) {
                Text("출신(학교 또는 팀): ")
                    .font(.system(size: 15))
                
                Text(player.school)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("드래프트 순위/년도: ")
                    .font(.system(size: 15))
                
                Text("\(player.draftNumber) / \(player.draftYear)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            (
                Text("경력: ")
                    .font(.system(size: 15))
                + Text("\(player.fromYear)~현재 (\(player.seasonExp + 1))년차")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
        }
    }
}

struct NBAPlayerInfoFifthItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let player = nbaPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            HStack(spacing: 0) {
                Text("국적: ")
                    .font(.system(size: 15))
                
                Text(player.country)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("출생: ")
                    .font(.system(size: 15))
                
                Text(player.birthdate.split(separator: "T").first ?? "")
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
        }
    }
}

struct NBAPlayerInfoSixthItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let player = nbaPlayerInfoStore.baseInfo.displayModel.info
        let components = player.height.split(separator: "-")
        let playerCmHeight = Int(NBAUtil.toCm(feet: Int(components.first ?? "0")!, inches: Int(components.last ?? "0")!))
        let playerKgWeight = Int((Double(player.weight) ?? 0).toKg())
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            VStack(alignment: .leading, spacing: 0) {
                Text("키(cm/ft): ")
                    .font(.system(size: 15))
                
                Text("\(playerCmHeight) / \(player.height)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("몸무게(kg/lb): ")
                    .font(.system(size: 15))
                
                Text("\(playerKgWeight) / \(player.weight)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
        }
    }
}

struct NBAPlayerInfoSeventhItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let stats = nbaPlayerInfoStore.baseInfo.displayModel.stats
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                nbaPlayerInfoStore.send(.showPlayerStats)
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
                        category: "경기수",
                        data: "\(stats.gp)",
                        customCategoryFontSize: 11
                    )
                    StatsDivider()
                    FBStatDataItem(
                        category: "경기당 득점",
                        data: "\(stats.ptsPG)",
                        customCategoryFontSize: 11
                    )
                    StatsDivider()
                    FBStatDataItem(
                        category: "경기당 리바운드",
                        data: "\(stats.rebPG)",
                        customCategoryFontSize: 11
                    )
                    StatsDivider()
                    FBStatDataItem(
                        category: "경기당 어시스트",
                        data: "\(stats.astPG)",
                        customCategoryFontSize: 11
                    )
                    StatsDivider()
                    FBStatDataItem(
                        category: "출전 경기 승률",
                        data: "\(stats.winsPct)",
                        customCategoryFontSize: 11
                    )
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct NBAPlayerInfoEighthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        let teamNameDic = nbaPlayerInfoStore.baseInfo.teamNameDictionary
        let lastGame = displayModel.lastGame
        let lastGamePlayerStats = displayModel.lastGamePlayerStats
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                nbaPlayerInfoStore.send(.showGameStats())
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
                
                HStack {
                    VStack {
                        HStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text(homeTeam == nil ? "" : teamNameDic["short_\(homeTeam!.teamId)"] ?? homeTeam!.teamCity)
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
                                
                                Text(awayTeam == nil ? "" : teamNameDic["short_\(awayTeam!.teamId)"] ?? awayTeam!.teamCity)
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text(CalendarUtil.formatDate(date: lastGame.gameSummary?.gameDate, outputFormatType: .ampmWithDayOfWeekDate))
                            .font(.system(size: 15))
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.40) // NOTE: 너비를 화면 전체 너비중 40%로 고정
                    
                    if let lastGamePlayerStats {
                        HStack {
                            StatsDivider()
                            FBStatDataItem(
                                category: "출전시간",
                                data: "\(lastGamePlayerStats.position.isEmpty ? "후보" : "선발") / \(lastGamePlayerStats.statistics.minutes)",
                                customCategoryFontSize: 12,
                                customDataFontSize: 15,
                                customWidth: 70
                            )
                            StatsDivider()
                            FBStatDataItem(
                                category: "득점",
                                data: "\(lastGamePlayerStats.statistics.points)",
                                customCategoryFontSize: 12
                            )
                            StatsDivider()
                            FBStatDataItem(
                                category: "리바운드",
                                data: "\(lastGamePlayerStats.statistics.reboundsTotal)",
                                customCategoryFontSize: 12
                            )
                            StatsDivider()
                            FBStatDataItem(
                                category: "어시스트",
                                data: "\(lastGamePlayerStats.statistics.assists)",
                                customCategoryFontSize: 12
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct NBAPlayerInfoNinthItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        searchStore: StoreOf<SearchStore>,
        nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.searchStore = searchStore
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.itemSize = itemSize
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = nbaPlayerInfoStore.baseInfo.teamNameDictionary
        let nextGame = nbaPlayerInfoStore.baseInfo.displayModel.nextGame
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                nbaPlayerInfoStore.send(.showGameStats(isPrevious: false))
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
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(awayTeamId == nil ? "" : teamNameDic["short_\(awayTeamId ?? 0)"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.gameSummary?.gameDate, outputFormatType: .ampmWithDayOfWeekDate))
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
