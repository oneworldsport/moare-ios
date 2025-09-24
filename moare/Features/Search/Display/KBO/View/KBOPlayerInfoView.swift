//
//  KBOPlayerInfoView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOPlayerInfoView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<KBOPlayerInfoStore>
    
    @State private var show = false
    
    var body: some View {
        InfoViewContainer(
            itemCount: 8,
            measureContent: { scope in
                if show {
                    HStack(alignment: .top) {
                        KBOPlayerInfoFirstItem(kboPlayerInfoStore: store)
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 0, geometry: geometry)
                                    }
                                }
                            )
                        
                        KBOPlayerInfoSecondItem(kboPlayerInfoStore: store)
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 1, geometry: geometry)
                                    }
                                }
                            )
                        
                        KBOPlayerInfoThirdItem(kboPlayerInfoStore: store)
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
                        KBOPlayerInfoFourthItem(kboPlayerInfoStore: store)
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 3, geometry: geometry)
                                    }
                                }
                            )
                        
                        KBOPlayerInfoFifthItem(kboPlayerInfoStore: store)
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
                        kboPlayerInfoStore: store
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
                        kboPlayerInfoStore: store
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
                        kboPlayerInfoStore: store
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
                if show {
                    KBOPlayerInfoFirstItem(
                        kboPlayerInfoStore: store,
                        isAniItem: true,
                        itemSize: scope.itemSizes[0],
                        itemOffset: scope.computedOffset(for: 0),
                        showContents: scope.showContents
                    )
                    KBOPlayerInfoSecondItem(
                        kboPlayerInfoStore: store,
                        isAniItem: true,
                        itemSize: scope.itemSizes[1],
                        itemOffset: scope.computedOffset(for: 1),
                        showContents: scope.showContents
                    )
                    KBOPlayerInfoThirdItem(
                        kboPlayerInfoStore: store,
                        isAniItem: true,
                        itemSize: scope.itemSizes[2],
                        itemOffset: scope.computedOffset(for: 2),
                        showContents: scope.showContents
                    )
                    KBOPlayerInfoFourthItem(
                        kboPlayerInfoStore: store,
                        isAniItem: true,
                        itemSize: scope.itemSizes[3],
                        itemOffset: scope.computedOffset(for: 3),
                        showContents: scope.showContents
                    )
                    KBOPlayerInfoFifthItem(
                        kboPlayerInfoStore: store,
                        isAniItem: true,
                        itemSize: scope.itemSizes[4],
                        itemOffset: scope.computedOffset(for: 4),
                        showContents: scope.showContents
                    )
                    KBOPlayerInfoSixthItem(
                        searchStore: searchStore,
                        kboPlayerInfoStore: store,
                        isAniItem: true,
                        itemSize: scope.itemSizes[5],
                        itemOffset: scope.computedOffset(for: 5),
                        showContents: scope.showContents
                    )
                    KBOPlayerInfoSeventhItem(
                        searchStore: searchStore,
                        kboPlayerInfoStore: store,
                        isAniItem: true,
                        itemSize: scope.itemSizes[6],
                        itemOffset: scope.computedOffset(for: 6),
                        showContents: scope.showContents
                    )
                    KBOPlayerInfoEigthItem(
                        searchStore: searchStore,
                        kboPlayerInfoStore: store,
                        isAniItem: true,
                        itemSize: scope.itemSizes[7],
                        itemOffset: scope.computedOffset(for: 7),
                        showContents: scope.showContents
                    )
                }
            }
        )
        .onAppear {
            store.send(.baseInfo(.initData))
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
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
        let player = kboPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
        ) {
            URLImage(url: KBOUtil.playerPhotoURL(id: player.id))
                .opacity(showContents ? 1 : 0)
            
            Text(player.name)
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
        let player = kboPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset
        ) {
            URLImage(url: KBOUtil.teamLogoURL(id: player.teamId))
                .opacity(showContents ? 1 : 0)
            
            Text(teamNameDic["full_\(player.teamId)"] ?? "")
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
        let player = kboPlayerInfoStore.baseInfo.displayModel.info
        
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
            
            (
                Text("포지션: ")
                    .font(.system(size: 15))
                + Text(player.position)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
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
        let player = kboPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
            (
                Text("드래프트: ")
                    .font(.system(size: 15))
                + Text(player.draftRound)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
            
            (
                Text("경력: ")
                    .font(.system(size: 15))
                + Text("\(KBOUtil.getFullYear(fromYear: player.fromYear))~현재 (\(KBOUtil.calculateYear(fromYear: player.fromYear))년차)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
            
            (
                Text("연봉: ")
                    .font(.system(size: 15))
                + Text(KBOUtil.formatMoney(player.salary))
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            )
            .multilineTextAlignment(.leading)
            .opacity(showContents ? 1 : 0)
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
        let player = kboPlayerInfoStore.baseInfo.displayModel.info
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            horizontalAlignment: .leading
        ) {
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
        let stats = kboPlayerInfoStore.baseInfo.displayModel.stats
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemSize: itemSize,
            itemOffset: itemOffset,
            onClick: {
                searchStore.send(.showPlayerStats(playerId: kboPlayerInfoStore.baseInfo.displayModel.info.id))
            }
        ) {
            BaseballLeagueTitle(
                logoUrl: KBOUtil.kboLogoUrl,
                name: "KBO",
                season: stats?.season
            )
            .opacity(showContents ? 1 : 0)
            
            if let hitter = stats?.hitter {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "경기수",
                        data: hitter.g,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "타율",
                        data: hitter.avg,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "홈런",
                        data: hitter.hr,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "ops",
                        data: hitter.ops,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "도루",
                        data: hitter.sb,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                }
                .opacity(showContents ? 1 : 0)
            }
            
            if let pitcher = stats?.pitcher {
                HStack(spacing: 0) {
                    FBStatDataItem(
                        category: "경기수",
                        data: pitcher.g,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "평균자책점",
                        data: pitcher.era,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "승",
                        data: pitcher.w,
                        customCategoryFontSize: 11
                    )
                    .frame(maxWidth: .infinity)
                    StatsDivider()
                    FBStatDataItem(
                        category: "패",
                        data: pitcher.l,
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
        let lastGame = kboPlayerInfoStore.baseInfo.displayModel.lastGame
        let lastGamePlayerHitterStats = kboPlayerInfoStore.baseInfo.displayModel.lastGamePlayerHitterStats
        let lastGamePlayerPitcherStats = kboPlayerInfoStore.baseInfo.displayModel.lastGamePlayerPitcherStats
        
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
                if let lastGame  {
                    let homeTeamScore = Int(lastGame.lineScore?.home.r ?? "0") ?? 0
                    let awayTeamScore = Int(lastGame.lineScore?.away.r ?? "0") ?? 0
                    
                    VStack {
                        HStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text(teamNameDic["short_\(lastGame.gameInfo?.homeTeamId ?? 0)"] ?? "")
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
                                
                                Text(teamNameDic["short_\(lastGame.gameInfo?.awayTeamId ?? 0)"] ?? "")
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text(CalendarUtil.formatDate(date: lastGame.gameInfo?.date, formatType: .ampmWithDayOfWeekDate))
                            .font(.system(size: 15))
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.40) // NOTE: 너비를 화면 전체 너비중 40%로 고정
                }
                
                if lastGamePlayerHitterStats != nil && lastGamePlayerPitcherStats == nil {
                    HStack {
                        StatsDivider()
                        FBStatDataItem(
                            category: "타수",
                            data: "\(lastGamePlayerHitterStats!.ab)",
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivider()
                        FBStatDataItem(
                            category: "안타",
                            data: "\(lastGamePlayerHitterStats!.h)",
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivider()
                        FBStatDataItem(
                            category: "득점",
                            data: "\(lastGamePlayerHitterStats!.r)",
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivider()
                        FBStatDataItem(
                            category: "타점",
                            data: "\(lastGamePlayerHitterStats!.rbi)",
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                } else if lastGamePlayerPitcherStats != nil && lastGamePlayerHitterStats == nil {
                    HStack {
                        StatsDivider()
                        FBStatDataItem(
                            category: "이낭",
                            data: lastGamePlayerPitcherStats!.ip,
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivider()
                        FBStatDataItem(
                            category: "삼진",
                            data: lastGamePlayerPitcherStats!.so,
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivider()
                        FBStatDataItem(
                            category: "볼넷",
                            data: lastGamePlayerPitcherStats!.bb,
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivider()
                        FBStatDataItem(
                            category: "실점",
                            data: lastGamePlayerPitcherStats!.r,
                            customCategoryFontSize: 12
                        )
                        .frame(maxWidth: .infinity)
                        StatsDivider()
                        FBStatDataItem(
                            category: "자책점",
                            data: lastGamePlayerPitcherStats!.er,
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
        let nextGame = kboPlayerInfoStore.baseInfo.displayModel.nextGame
        let teamNameDic = kboPlayerInfoStore.baseInfo.teamNameDictionary
        
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
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(teamNameDic["short_\(nextGame.gameInfo?.awayTeamId ?? 0)"] ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}
