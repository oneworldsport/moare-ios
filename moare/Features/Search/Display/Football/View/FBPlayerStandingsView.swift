//
//  FBPlayerStandingsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import SwiftUI
import ComposableArchitecture

struct FBPlayerStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBPlayerStandingsDisplayModel
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var totalScrollDistance: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack {
                if let fbPlayerStandingsStore = fbPlayerStandingsStore {
                    // league
                    if let league = fbPlayerStandingsStore.league {
                        HStack {
                            LeagueTitle(
                                url: league.logo,
                                leagueName: league.name,
                                leagueSeason: league.season
                            )
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    
                    // standings data
                    ScrollView {
                        HStack(spacing: 0) {
                            FBPlayerStandingsFirstDataList(
                                fbPlayerStandingsStore: fbPlayerStandingsStore,
                                categoryOffset: $totalScrollDistance
                            )
                            
                            
                            ScrollView(.horizontal) {
                                FBPlayerStandingsDataList(
                                    fbPlayerStandingsStore: fbPlayerStandingsStore,
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
                    }
                }
            }
            .onAppear {
                // init FBPlayerStandingsStore
                let fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore> = storeManager.getStore(forKey: StoreKeys.fbPlayerStandingsStore) ?? {
                    let newStore = Store(initialState: FBPlayerStandingsStore.State()) { FBPlayerStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbPlayerStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbPlayerStandingsStore = fbPlayerStandingsStore
                }
                
                fbPlayerStandingsStore.send(.initData(displayModel: displayModel))
            }
        }
    }
}

struct FBPlayerStandingsFirstDataList: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    @Binding var categoryOffset: CGFloat
    
    init(fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>, categoryOffset: Binding<CGFloat>) {
        self.fbPlayerStandingsStore = fbPlayerStandingsStore
        self._categoryOffset = categoryOffset
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            FBPlayerStandingsFirstCategoryItem(category: StringConstants.Football.standingsFirstCategory)
                .frame(height: fbPlayerStandingsStore.categoryItemHeight * 2)
                .background(.white)
                .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
                .zIndex(1)

            LazyVStack(spacing: 0) {
                ForEach(fbPlayerStandingsStore.standings.indices, id: \.self) { index in
                    let data = fbPlayerStandingsStore.standings[index]
                    
                    FBPlayerStandingsFirstDataListItem(
                        fbPlayerStandingsStore: fbPlayerStandingsStore,
                        rank: index + 1,
                        data: data
                    )
                    .frame(height: fbPlayerStandingsStore.dataItemHeight)
                }
            }
            .frame(width: fbPlayerStandingsStore.firstCategoryItemWidth)
            .padding(.top, fbPlayerStandingsStore.categoryItemHeight * 2)
        }
    }
}

struct FBPlayerStandingsFirstCategoryItem: View {
    let category: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(category)
                .font(.system(size: 15, weight: .medium))
                .frame(minWidth: 130)
            
            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
    }
}

struct FBPlayerStandingsFirstDataListItem: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    let rank: Int
    let data: FBPlayerStandingsDisplay
    
    @State private var teamKrName = ""
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(rank)")
                .font(.system(size: fbPlayerStandingsStore.dataFontSize, weight: .medium))
                .frame(width: 22)

            URLImage(url: data.player.photo, customSize: CGSize(width: 25, height: 25))
                .padding(.leading, 4)
                .padding(.trailing, 6)

            VStack(spacing: 2) {
                HStack {
                    Text(data.player.krname)
                        .font(.system(size: 12))
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                HStack {
                    Text(teamKrName)
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer()
                }
            }

            Spacer()

            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
        .padding(.leading, 10)
        .onAppear {
            translate()
        }
    }
    
    private func translate() {
        Task {
            let teamKrName = await EnNameTranslationUtility.translateByAWS(input: data.stats.team.name)
            self.teamKrName = EnNameTranslationUtility.translateByDic(type: .team, input: teamKrName)
        }
    }
}

struct FBPlayerStandingsDataList: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    @Binding var categoryOffset: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                FBPlayerStandingsFirstCategoryList(fbPlayerStandingsStore: fbPlayerStandingsStore)
                
                FBPlayerStandingsSecondCategoryList(fbPlayerStandingsStore: fbPlayerStandingsStore)
            }
            .background(.white)
            .zIndex(1)
            .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
            
            LazyVStack(spacing: 0) {
                ForEach(fbPlayerStandingsStore.standings.indices, id: \.self) { index in
                    let data = fbPlayerStandingsStore.standings[index]
                    
                    HStack(spacing: 0) {
                        ForEach(0..<StringConstants.Football.playerStandingsSecondCategories.count) { index in
                            FBPlayerStandingsDataListItem(
                                fbPlayerStandingsStore: fbPlayerStandingsStore,
                                data: data,
                                index: index
                            )
                            .frame(height: fbPlayerStandingsStore.dataItemHeight)
                            
                            if index == StringConstants.Football.playerStandingsAttackCategories.count - 1 || index == StringConstants.Football.playerStandingsAttackCategories.count + StringConstants.Football.playerStandingsDefendCategories.count - 1 {
                                Rectangle()
                                    .frame(width: 2)
                                    .foregroundStyle(.secondary)
                                    .opacity(0)
                            }
                        }
                    }
                }
            }
            .padding(.top, fbPlayerStandingsStore.categoryItemHeight * 2)
        }
    }
}

struct FBPlayerStandingsFirstCategoryList: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    @State var barOffset: CGSize
    
    init(fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>) {
        self.fbPlayerStandingsStore = fbPlayerStandingsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: fbPlayerStandingsStore.itemWidth * CGFloat(StringConstants.Football.playerStandingsAttackCategories.count), barWidth: 80), height: 0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(StringConstants.Football.statsFirstCategories.indices, id: \.self) { index in
                        let category = StringConstants.Football.statsFirstCategories[index]
                        
                        FBPlayerStandingsFirstCategoryListItem(
                            fbPlayerStandingsStore: fbPlayerStandingsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                        
                        if index != StringConstants.Football.statsFirstCategories.count - 1 {
                            Rectangle()
                                .frame(width: 2)
                                .foregroundStyle(.secondary)
                                .opacity(0.5)
                        }
                    }
                }
                .frame(height: fbPlayerStandingsStore.categoryItemHeight - 2)
            
            HCapsuleBar(customWidth: 80)
                .offset(barOffset)
        }
        .onChange(of: fbPlayerStandingsStore.firstSelectedIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    func moveBar(index: Int) {
        let itemWidth = fbPlayerStandingsStore.itemWidth
        let barWidth = fbPlayerStandingsStore.barWidth
        
        let attackCategoriesCount = CGFloat(StringConstants.Football.playerStandingsAttackCategories.count)
        let defendCategoriesCount = CGFloat(StringConstants.Football.playerStandingsDefendCategories.count)
        let etcCategoriesCount = CGFloat(StringConstants.Football.playerStandingsEtcCategories.count)
        
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: itemWidth * attackCategoriesCount, barWidth: 80), height: 0)
            case 1:
                barOffset = CGSize(width: (itemWidth * attackCategoriesCount) + barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * defendCategoriesCount, barWidth: 80), height: 0)
            default:
                barOffset = CGSize(width: (itemWidth * attackCategoriesCount) + (barWidth * 2) + (itemWidth * defendCategoriesCount) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * etcCategoriesCount, barWidth: 80), height: 0)
            }
        }
    }
}

struct FBPlayerStandingsFirstCategoryListItem: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        
        Button(action: {
            fbPlayerStandingsStore.send(.selectFirstCategory(index))
        }) {
            Text(category)
                .font(.system(size: fbPlayerStandingsStore.categoryFontSize, weight: .medium))
                .frame(width: width)
        }
        .foregroundStyle(.primary)
    }
    
    private var width: CGFloat {
        switch index {
        case 0: fbPlayerStandingsStore.itemWidth * CGFloat(StringConstants.Football.playerStandingsAttackCategories.count)
        case 1: fbPlayerStandingsStore.itemWidth * CGFloat(StringConstants.Football.playerStandingsDefendCategories.count)
        default: fbPlayerStandingsStore.itemWidth * CGFloat(StringConstants.Football.playerStandingsEtcCategories.count)
        }
    }
}

struct FBPlayerStandingsSecondCategoryList: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    @State var barOffset: CGSize
    
    let attackCategoriesCount = StringConstants.Football.playerStandingsAttackCategories.count
    let defendCategoriesCount = StringConstants.Football.playerStandingsDefendCategories.count
    
    init(fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>) {
        self.fbPlayerStandingsStore = fbPlayerStandingsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: fbPlayerStandingsStore.itemWidth), height: 0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(StringConstants.Football.playerStandingsSecondCategories.indices, id: \.self) { index in
                        let category = StringConstants.Football.playerStandingsSecondCategories[index]
                        
                        FBPlayerStandingsSecondCategoryListItem(
                            fbPlayerStandingsStore: fbPlayerStandingsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                        
                        if index == attackCategoriesCount - 1 || index == attackCategoriesCount + defendCategoriesCount - 1 {
                            Rectangle()
                                .frame(width: 2)
                                .foregroundStyle(.secondary)
                                .opacity(0.5)
                        }
                    }
                }
                .frame(height: fbPlayerStandingsStore.categoryItemHeight - 2)
                .onAppear {
                    // TODO: should decide animation type
                    // scroll and move bar to category that matches with the keyword
                    moveBar(index: fbPlayerStandingsStore.secondSelectedIndex)
                    
                    withAnimation {
                        proxy.scrollTo(fbPlayerStandingsStore.secondSelectedIndex, anchor: .leading)
                    }
                }
                .onChange(of: fbPlayerStandingsStore.firstSelectedIndex) { newValue in
                    if fbPlayerStandingsStore.shouldScrollCategory {
                        withAnimation {
                            proxy.scrollTo(fbPlayerStandingsStore.secondSelectedIndex, anchor: .leading)
                        }
                    }
                }
            } // ScrollViewReader
            
            HCapsuleBar()
                .offset(barOffset)
        }
        .onChange(of: fbPlayerStandingsStore.secondSelectedIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    func moveBar(index: Int) {
        let itemWidth = fbPlayerStandingsStore.itemWidth
        let barWidth = fbPlayerStandingsStore.barWidth
        
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0..<attackCategoriesCount:
                barOffset = CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index), height: 0)
            case attackCategoriesCount..<attackCategoriesCount + defendCategoriesCount:
                barOffset = CGSize(width: barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index), height: 0)
            default:
                barOffset = CGSize(width: (barWidth * 2) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index), height: 0)
            }
        }
    }
}

struct FBPlayerStandingsSecondCategoryListItem: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    let index: Int
    let category: String
    
    var fontSize: CGFloat {
        switch index {
        case 2: 13
        default : fbPlayerStandingsStore.categoryFontSize
        }
    }
    
    var body: some View {
        Button(action: {
            fbPlayerStandingsStore.send(.selectSecondCategory(index))
        }) {
            Text(category)
                .font(.system(size: fontSize, weight: .medium))
                .frame(width: fbPlayerStandingsStore.itemWidth)
        }
        .foregroundStyle(.primary)
    }
}

struct FBPlayerStandingsDataListItem: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    let data: FBPlayerStandingsDisplay
    let index: Int
    
    var body: some View {
        Text(intDataText)
            .font(.system(size: fbPlayerStandingsStore.dataFontSize))
            .frame(width: fbPlayerStandingsStore.itemWidth)
    }
    
    private var intDataText: String {
        switch index {
        case 0: "\(data.stats.goals.total)"
        case 1: "\(data.stats.goals.assists)"
        case 2: "\(data.stats.goals.total + data.stats.goals.assists)"
        case 3: "\(data.stats.shots.total)"
        case 4: "\(data.stats.shots.on)"
        case 5: "\(data.stats.passes.key)"
        case 6: "\(data.stats.dribbles.success)"
        case 7: "\(data.stats.penalty.scored)"
        case 8: "\(data.stats.tackles.total)"
        case 9: "\(data.stats.duels.won)"
        case 10: "\(data.stats.passes.total)"
        case 11: "\(data.stats.fouls.committed)"
        case 12: "\(data.stats.cards.yellow)"
        case 13: "\(data.stats.cards.red)"
        case 14: "\(data.stats.games.appearences)"
        case 15: "\(data.stats.games.lineups)"
        case 16: "\(data.stats.substitutes.substituteIn)"
        case 17: "\(data.stats.games.minutes)"
        case 18: "\(Double(data.stats.games.rating)?.rounded(to: 2) ?? 0)"
        default: ""
        }
    }
}

//#Preview {
//    FBPlayerStandingsView()
//}
