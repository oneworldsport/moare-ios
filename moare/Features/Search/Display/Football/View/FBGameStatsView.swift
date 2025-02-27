//
//  StatisticsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/5/24.
//

import SwiftUI
import ComposableArchitecture

struct FBGameStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbGameStatsStore: StoreOf<FBGameStatsStore>? = nil
    @State var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>? = nil
    
    let displayModel: FBGameStatsDisplayModel
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var totalScrollDistance: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    @State private var coachKrName = ""
    
    var body: some View {
        let game = displayModel.game
        
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 10) {
                if let fbGameStatsStore = fbGameStatsStore, let fbLeagueScheduleStore = fbLeagueScheduleStore {
                    /* ---------------------
                       game title, info
                       - hides when game selected by schedule
                       --------------------- */
                    if searchStore.fbLeagueScheduleData == nil && searchStore.fbTeamScheduleData == nil {
                        HStack {
                            HStack(spacing: 0) {
                                URLImage(url: game.league.logo, customSize: CGSize(width: 23, height: 23))
                                    .padding(.trailing, 4)
                                
                                // TODO: make season text to use util
                                Text("\(game.league.name) \(String(game.league.season).suffix(2))/25")
                                    .font(.system(size: 14))
                            }
                            
                            Text(" - \(MatchDescriptionConverter.convert(input: game.league.round))")
                                .font(.system(size: 14))
                            
                            Spacer()
                        }
                        .padding(.leading, UIConstants.Padding.defaultHPadding)
                        
                        FBLeagueScheduleListItem(
                            searchStore: searchStore,
                            fbLeagueScheduleStore: fbLeagueScheduleStore,
                            data: game
                        )
                    }
                    
                    Capsule()
                        .fill(.moare)
                        .frame(height: 1)
                        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    
                    if game.fixture.status.short != "NS" {
                        /* ---------------------
                           team select button
                           --------------------- */
                        FBGameStatsTeamButtonContainer(
                            searchStore: searchStore,
                            fbGameStatsStore: fbGameStatsStore
                        )
                        
                        /* ---------------------
                           coach
                           --------------------- */
                        HStack {
                            Text("감독:")
                                .font(.system(size: 15))
                            
                            URLImage(url: fbGameStatsStore.coach?.photo, customSize: CGSize(width: 23, height: 23))
                            
                            Text(coachKrName)
                                .font(.system(size: 15))
                            
                            Spacer()
                        }
                        .padding(.leading)
                        
                        /* ---------------------
                           player stats
                           --------------------- */
                        ScrollView {
                            HStack(spacing: 0) {
                                FBGameStatsFirstDataList(
                                    fbGameStatsStore: fbGameStatsStore,
                                    categoryOffset: $totalScrollDistance
                                )
                                
                                
                                ScrollView(.horizontal) {
                                    FBGameStatsDataList(
                                        fbGameStatsStore: fbGameStatsStore,
                                        categoryOffset: $totalScrollDistance
                                    )
                                }
                            }
                            .background(
                                GeometryReader { geometry in
                                    let newOffset = geometry.frame(in: .global).minY
                                    
                                    Color.clear
                                        .onAppear {
                                            oldOffset = newOffset
                                        }
                                        .onChange(of: newOffset) { newOffset in
                                            let delta = oldOffset - newOffset
                                            totalScrollDistance += delta
                                            oldOffset = newOffset
                                        }
                                }
                            )
                        } // ScrollView
                    } else {
                        Text("경기 시작 후 데이터가 업데이트됩니다.")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                } // if let fbGameStatsStore
            } // VStack
            .onAppear {
                // init FBGameStatsStore
                let fbGameStatsStore: StoreOf<FBGameStatsStore> = storeManager.getStore(forKey: StoreKeys.fbGameStatsStore) ?? {
                    let newStore = Store(initialState: FBGameStatsStore.State()) { FBGameStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbGameStatsStore)
                    
                    return newStore
                }()
                
//                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbGameStatsStore = fbGameStatsStore
//                }
                fbGameStatsStore.send(.initData(displayModel: displayModel))
                
                // TODO: has to figure out better structure
                // when game_stats show at first(meaning ScheduleView never showed)
                let scheduleStore: StoreOf<FBLeagueScheduleStore> = storeManager.getStore(forKey: StoreKeys.fbLeagueScheduleStore) ?? {
                    let newStore = Store(initialState: FBLeagueScheduleStore.State(
                        displayModel: nil, yearMonthList: []
                    )) { FBLeagueScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbLeagueScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbLeagueScheduleStore = scheduleStore
                }
                
                translate()
                
                searchStore.send(.refreshGame)
            } // onAppear
            .onChange(of: fbGameStatsStore?.coach) { newValue in
                translate()
            }
        } // if let searchStore
    }
    
    private func translate() {
        Task {
            guard let name = fbGameStatsStore?.coach?.name else { return }
            
            let coachKrName = await EnNameTranslationUtility.translateByAWS(input: name)
            self.coachKrName = coachKrName
        }
    }
}

struct FBGameStatsTeamButtonContainer: View {
    @ComposableArchitecture.Bindable var searchStore: StoreOf<SearchStore>
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    @State var barOffset: CGSize
    
    @State private var homeTeamKrName = ""
    @State private var awayTeamKrName = ""
    
    init(searchStore: StoreOf<SearchStore>, fbGameStatsStore: StoreOf<FBGameStatsStore>) {
        self.searchStore = searchStore
        self.fbGameStatsStore = fbGameStatsStore
        
        self._barOffset = State(initialValue: getOffsetOfAniCapsuleBar(itemWidth: fbGameStatsStore.teamButtonWidth, barWidth: 50))
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    // home
                    FBGameStatsTeamButton(
                        fbGameStatsStore: fbGameStatsStore,
                        team: homeTeamKrName,
                        index: 0
                    )
                    .frame(maxWidth: fbGameStatsStore.teamButtonWidth)
                    
                    VCapsuleBar()
                        .opacity(0.5)
                    
                    // away
                    FBGameStatsTeamButton(
                        fbGameStatsStore: fbGameStatsStore,
                        team: awayTeamKrName,
                        index: 1
                    )
                    .frame(maxWidth: fbGameStatsStore.teamButtonWidth)
                }
                .frame(height: 40)
                
                HCapsuleBar(size: .medium)
                    .offset(barOffset)
            } // VStack
            
            // refresh button
            HStack {
                Spacer()
                
                Button(action: {
                    searchStore.send(.refreshGame)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .tint(.secondary)
                        .padding(5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.secondary, lineWidth: 1)
                        }
                        .opacity(0.6)
                }
                .foregroundStyle(.secondary)
                .padding(.trailing, UIConstants.Padding.defaultHPadding)
            }
        }
        .onAppear {
            translate()
        }
        .onChange(of: fbGameStatsStore.selectedTeamIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    func moveBar(index: Int) {
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = getOffsetOfAniCapsuleBar(itemWidth: fbGameStatsStore.teamButtonWidth, barWidth: 50)
            default:
                barOffset = CGSize(width: fbGameStatsStore.barWidth + getOffsetOfAniCapsuleBar(itemWidth: fbGameStatsStore.teamButtonWidth, barWidth: 50, index: index).width, height: 0)
            }
        }
    }
    
    private func translate() {
        Task {
            let homeTeamKrName = await EnNameTranslationUtility.translateByAWS(input: fbGameStatsStore.displayModel?.game.teams.home.name)
            self.homeTeamKrName = EnNameTranslationUtility.translateByDic(type: .team, input: homeTeamKrName)
        }
        
        Task {
            let awayTeamKrName = await EnNameTranslationUtility.translateByAWS(input: fbGameStatsStore.displayModel?.game.teams.away.name)
            self.awayTeamKrName = EnNameTranslationUtility.translateByDic(type: .team, input: awayTeamKrName)
        }
    }
}

struct FBGameStatsTeamButton: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    let team: String
    let index: Int
    
    init(fbGameStatsStore: StoreOf<FBGameStatsStore>, team: String, index: Int) {
        self.fbGameStatsStore = fbGameStatsStore
        self.team = team
        self.index = index
    }
    
    var body: some View {
        Button(action: {
            fbGameStatsStore.send(.selectTeam(index))
        }) {
            Text(team)
                .lineLimit(2)
                .font(.system(size: 16))
        }
        .foregroundStyle(.primary)
    }
}

struct FBGameStatsFirstDataList: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    @Binding var categoryOffset: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            FBGameStatsFirstCategoryItem(category: StringConstants.Football.gameStatsFirstCategory)
                .frame(height: fbGameStatsStore.categoryItemHeight * 2)
                .background(.white)
                .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
                .zIndex(1)

            LazyVStack(spacing: 0) {
                ForEach(fbGameStatsStore.playerStats, id: \.player.id) { value in
                    let data = value.player
                    
                    FBGameStatsFirstDataListItem(
                        fbGameStatsStore: fbGameStatsStore,
                        data: data
                    )
                    .frame(height: fbGameStatsStore.dataItemHeight)
                }
                
                // TODO: add later
//                HStack(spacing: 0) {
//                    Spacer()
//                    
//                    Text("합계")
//                        .font(.system(size: 12))
//                    
//                    Spacer()
//
//                    Rectangle()
//                        .frame(width: 2)
//                        .foregroundStyle(.secondary)
//                        .opacity(0.5)
//                }
//                .frame(width: 122)
//                .frame(height: fbGameStatsStore.dataItemHeight)
            }
            .frame(width: 132)
            .padding(.top, fbGameStatsStore.categoryItemHeight * 2)
        }
    }
}

struct FBGameStatsFirstCategoryItem: View {
    let category: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(category)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 130)
            
            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
    }
}

struct FBGameStatsFirstDataListItem: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    let data: FBPerson
    
    @State private var krName = ""
    @State private var isStarter = false
    @State private var position = ""
    
    var body: some View {
        HStack(spacing: 0) {
            URLImage(url: data.photo, customSize: CGSize(width: 25, height: 25))
                .padding(.leading, 8)
                .padding(.trailing, 3)

            Text(krName)
                .font(.system(size: 12))
                .lineLimit(2)
                .frame(maxWidth: 80, alignment: .leading)
            
            // TODO: goals, cards, number, captain
            VStack(spacing: 0) {
                Text(isStarter ? "선발" : "후보")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .opacity(isStarter ? 1 : 0.7)
                
                Text(position)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .opacity(0.7)
            }
            .frame(maxWidth: 20)
            .padding(.leading, 2)

            Spacer()

            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
        .onAppear {
            translate()
            checkStarterAndPosition()
        }
        .onChange(of: fbGameStatsStore.selectedTeamIndex) { newValue in
            translate()
        }
        .onChange(of: fbGameStatsStore.secondSelectedIndex) { newValue in
            translate()
        }
    }
    
    private func translate() {
        Task {
            let krName = await EnNameTranslationUtility.translateByAWS(input: data.name)
            self.krName = krName
        }
    }
    
    private func checkStarterAndPosition() {
        guard let lineups = fbGameStatsStore.lineups else { return }
        
        // starter
        for player in lineups.startXI {
            if data.id == player.player.id {
                isStarter = true
                position = player.player.pos
                return
            }
        }
        
        // substitute
        for player in lineups.substitutes {
            if data.id == player.player.id {
                position = player.player.pos
                return
            }
        }
    }
}

struct FBGameStatsDataList: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    @Binding var categoryOffset: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                FBGameStatsFirstCategoryList(fbGameStatsStore: fbGameStatsStore)
                
                FBGameStatsSecondCategoryList(fbGameStatsStore: fbGameStatsStore)
            }
            .background(.white)
            .zIndex(1)
            .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
            
            LazyVStack(spacing: 0) {
                ForEach(fbGameStatsStore.playerStats.indices, id: \.self) { index in
                    let data = fbGameStatsStore.playerStats[index]
                    
                    HStack(spacing: 0) {
                        ForEach(0..<StringConstants.Football.gameStatsSecondCategories.count) { index in
                            if let stats = data.statistics.first {
                                FBGameStatsDataListItem(
                                    fbGameStatsStore: fbGameStatsStore,
                                    data: stats,
                                    index: index
                                )
                                .frame(height: fbGameStatsStore.dataItemHeight)
                            }
                            
                            if index == StringConstants.Football.gameStatsAttackCategories.count - 1 || index == StringConstants.Football.gameStatsAttackCategories.count + StringConstants.Football.gameStatsDefendCategories.count - 1 {
                                VCapsuleBar()
                                    .opacity(0)
                            }
                        }
                    }
                }
            }
            .padding(.top, fbGameStatsStore.categoryItemHeight * 2)
        }
    }
}

struct FBGameStatsFirstCategoryList: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    @State var barOffset: CGSize
    
    init(fbGameStatsStore: StoreOf<FBGameStatsStore>) {
        self.fbGameStatsStore = fbGameStatsStore
        
        self._barOffset = State(initialValue: getOffsetOfAniCapsuleBar(itemWidth: fbGameStatsStore.itemWidth * CGFloat(StringConstants.Football.gameStatsAttackCategories.count), barWidth: 80))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(StringConstants.Football.statsFirstCategories.indices, id: \.self) { index in
                        let category = StringConstants.Football.statsFirstCategories[index]
                        
                        FBGameStatsFirstCategoryListItem(
                            fbGameStatsStore: fbGameStatsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                        
                        if index != StringConstants.Football.statsFirstCategories.count - 1 {
                            VCapsuleBar()
                                .opacity(0.5)
                        }
                    }
                }
                .frame(height: fbGameStatsStore.categoryItemHeight - 2)
            
            HCapsuleBar(size: .large)
                .offset(barOffset)
        }
        .onChange(of: fbGameStatsStore.firstSelectedIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    func moveBar(index: Int) {
        let itemWidth = fbGameStatsStore.itemWidth
        let barWidth = fbGameStatsStore.barWidth
        
        let attackCategoriesCount = CGFloat(StringConstants.Football.gameStatsAttackCategories.count)
        let defendCategoriesCount = CGFloat(StringConstants.Football.gameStatsDefendCategories.count)
        let etcCategoriesCount = CGFloat(StringConstants.Football.gameStatsEtcCategories.count)
        
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = getOffsetOfAniCapsuleBar(itemWidth: itemWidth * attackCategoriesCount, barWidth: 80)
            case 1:
                barOffset = CGSize(width: (itemWidth * attackCategoriesCount) + barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * defendCategoriesCount, barWidth: 80).width, height: 0)
            default:
                barOffset = CGSize(width: (itemWidth * attackCategoriesCount) + (barWidth * 2) + (itemWidth * defendCategoriesCount) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * etcCategoriesCount, barWidth: 80).width, height: 0)
            }
        }
    }
}

struct FBGameStatsFirstCategoryListItem: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        
        Button(action: {
            fbGameStatsStore.send(.selectFirstCategory(index))
        }) {
            Text(category)
                .font(.system(size: 15, weight: .medium))
                .frame(width: width)
        }
        .foregroundStyle(.primary)
    }
    
    private var width: CGFloat {
        switch index {
        case 0: fbGameStatsStore.itemWidth * CGFloat(StringConstants.Football.gameStatsAttackCategories.count)
        case 1: fbGameStatsStore.itemWidth * CGFloat(StringConstants.Football.gameStatsDefendCategories.count)
        default: fbGameStatsStore.itemWidth * CGFloat(StringConstants.Football.gameStatsEtcCategories.count)
        }
    }
}

struct FBGameStatsSecondCategoryList: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    @State var barOffset: CGSize
    
    let attackCategoriesCount = StringConstants.Football.gameStatsAttackCategories.count
    let defendCategoriesCount = StringConstants.Football.gameStatsDefendCategories.count
    
    init(fbGameStatsStore: StoreOf<FBGameStatsStore>) {
        self.fbGameStatsStore = fbGameStatsStore
        
        self._barOffset = State(initialValue: getOffsetOfAniCapsuleBar(itemWidth: fbGameStatsStore.itemWidth))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(StringConstants.Football.gameStatsSecondCategories.indices, id: \.self) { index in
                        let category = StringConstants.Football.gameStatsSecondCategories[index]
                        
                        FBGameStatsSecondCategoryListItem(
                            fbGameStatsStore: fbGameStatsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                        
                        if index == attackCategoriesCount - 1 || index == attackCategoriesCount + defendCategoriesCount - 1 {
                            VCapsuleBar()
                                .opacity(0.5)
                        }
                    }
                }
                .frame(height: fbGameStatsStore.categoryItemHeight - 2)
                .onAppear {
                    // TODO: should decide animation type
                    // scroll and move bar to category that matches with the keyword
                    moveBar(index: fbGameStatsStore.secondSelectedIndex)
                    
                    withAnimation {
                        proxy.scrollTo(fbGameStatsStore.secondSelectedIndex, anchor: .leading)
                    }
                }
                .onChange(of: fbGameStatsStore.firstSelectedIndex) { newValue in
                    if fbGameStatsStore.shouldScrollCategory {
                        withAnimation {
                            proxy.scrollTo(fbGameStatsStore.secondSelectedIndex, anchor: .leading)
                        }
                    }
                }
            } // ScrollViewReader
            
            HCapsuleBar()
                .offset(barOffset)
        }
        .onChange(of: fbGameStatsStore.secondSelectedIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    func moveBar(index: Int) {
        let itemWidth = fbGameStatsStore.itemWidth
        let barWidth = fbGameStatsStore.barWidth
        
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0..<attackCategoriesCount:
                barOffset = getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index)
            case attackCategoriesCount..<attackCategoriesCount + defendCategoriesCount:
                barOffset = CGSize(width: barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index).width, height: 0)
            default:
                barOffset = CGSize(width: (barWidth * 2) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index).width, height: 0)
            }
        }
    }
}

struct FBGameStatsSecondCategoryListItem: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        Button(action: {
            fbGameStatsStore.send(.selectSecondCategory(index))
        }) {
            Text(category)
                .fontWeight(.medium)
                .font(.system(size: fontSize))
                .lineLimit(2)
                .frame(width: fbGameStatsStore.itemWidth)
        }
        .foregroundStyle(.primary)
    }
    
    private var fontSize: CGFloat {
        switch index {
        case 6, 9: 11
        case 16: 13
        default: 15
        }
    }
    
//    private var itemWidth: CGFloat {
//        switch index {
//        case 6, 9: fbGameStatsStore.percentageItemWidth
//        default: fbGameStatsStore.itemWidth
//        }
//    }
}

struct FBGameStatsDataListItem: View {
    @ComposableArchitecture.Bindable var fbGameStatsStore: StoreOf<FBGameStatsStore>
    
    let data: FBGamePlayerStatsDetail
    let index: Int
    
    var body: some View {
        Text(intDataText)
            .font(.system(size: fontSize))
            .frame(width: fbGameStatsStore.itemWidth)
    }
    
    private var intDataText: String {
        switch index {
        case 0: "\(data.goals.total)"
        case 1: "\(data.penalty.scored)"
        case 2: "\(data.goals.assists)"
        case 3: "\(data.shots.total)"
        case 4: "\(data.shots.on)"
        case 5: "\(data.passes.key)"
        case 6: "\(data.dribbles.success)/\(data.dribbles.attempts)(\(data.dribbles.success.percentage(of: data.dribbles.attempts, to: 1))%)"
        case 7: "\(data.offsides)"
        case 8: "\(data.tackles.total)"
        case 9: "\(data.duels.won)/\(data.duels.total)(\(data.duels.won.percentage(of: data.duels.total, to: 1))%)"
        case 10: "\(data.tackles.interceptions)"
        case 11: "\(data.passes.total)"
        case 12: "\(data.fouls.drawn)"
        case 13: "\(data.fouls.committed)"
        case 14: "\(data.cards.yellow)"
        case 15: "\(data.cards.red)"
        case 16: "\(data.games.minutes)"
        case 17: "\(data.games.rating)"
        default: ""
        }
    }
    
    private var fontSize: CGFloat {
        switch index {
        case 6, 9: 11
        default: 15
        }
    }
    
//    private var itemWidth: CGFloat {
//        switch index {
//        case 6, 9: fbGameStatsStore.percentageItemWidth
//        default: fbGameStatsStore.itemWidth
//        }
//    }
}
