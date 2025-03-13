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
    
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    
    @State private var canShowMoreStandings = true
    
    @State private var hScrollOffset: CGFloat = 0
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
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
                        .padding(.bottom, 8)
                    }
                    
                    /* ---------------------
                       category
                       --------------------- */
                    HStack(spacing: 0) {
                        FBPlayerStandingsFirstCategoryItem(category: StringConstants.Football.standingsFirstCategory)
                        
                        HSynchronizedScrollView(scrollOffset: $hScrollOffset, itemWidth: fbPlayerStandingsStore.itemWidth, itemHeight: fbPlayerStandingsStore.categoryItemHeight) {
                            VStack(spacing: 0) {
                                FBPlayerStandingsFirstCategoryList(fbPlayerStandingsStore: fbPlayerStandingsStore)
                                FBPlayerStandingsSecondCategoryList(fbPlayerStandingsStore: fbPlayerStandingsStore)
                            }
                        }
                        .simultaneousGesture(DragGesture()) // prevent parent view's back handler DragGesture()
                    }
                    .frame(height: fbPlayerStandingsStore.categoryItemHeight * 2)
                    
                    ZStack {
                        /* ---------------------
                           loading
                           --------------------- */
                        if fbPlayerStandingsStore.displayDataState == .fetching {
                            ProgressView()
                        }
                        
                        /* ---------------------
                           standings
                           --------------------- */
                        if fbPlayerStandingsStore.displayDataState == .success {
                            ScrollView {
                                ScrollViewReader { proxy in
                                    HStack(alignment: .top, spacing: 0) {
                                        FBPlayerStandingsFirstDataList(fbPlayerStandingsStore: fbPlayerStandingsStore)
                                        //                                .frame(maxHeight: .infinity, alignment: .top) // 정렬 안맞는 현상때문에 추가
                                        //                                .background(Color.red.opacity(0.3))
                                        
                                        // TODO: 아직도 1픽셀정도 미세한 차이가 있음
                                        HSynchronizedScrollView(scrollOffset: $hScrollOffset, itemWidth: fbPlayerStandingsStore.itemWidth, itemHeight: fbPlayerStandingsStore.dataItemHeight) {
                                            FBPlayerStandingsDataList(fbPlayerStandingsStore: fbPlayerStandingsStore)
                                                .padding(.top, 2) // 하이라이트 선 때문인지는 모르겠는데, 정렬 안맞는 현상 있어서 추가해줌. ScrollView가 문제인듯.
                                            //                                    .frame(maxHeight: .infinity, alignment: .top) // 정렬 안맞는 현상때문에 추가
                                            //                                    .background(Color.blue.opacity(0.3))
                                        }
                                        .frame(height: fbPlayerStandingsStore.categoryItemHeight * CGFloat(fbPlayerStandingsStore.filteredStandings.count), alignment: .top) // 정렬 안맞는 현상때문에 추가
                                        .simultaneousGesture(DragGesture())
                                    }
                                    .background(
                                        GeometryReader { geometry in
                                            let newOffset = geometry.frame(in: .global).minY
                                            
                                            Color.clear
                                                .onAppear {
                                                    oldOffset = newOffset
                                                    
                                                    contentHeight = CGFloat(fbPlayerStandingsStore.filteredStandings.count) * fbPlayerStandingsStore.dataItemHeight
                                                }
                                                .onChange(of: fbPlayerStandingsStore.filteredStandings.count) { newValue in
                                                    contentHeight = CGFloat(newValue) * fbPlayerStandingsStore.dataItemHeight
                                                    
                                                    // 추가로 10개의 standings가 나오고 다시 상단/하단으로 이동하는데 시간이 걸리기때문에, 다시 showMoreStandings를 가능하게 하는데 1초 delay를 주는건 괜찮아 보인다.
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                        canShowMoreStandings = true
                                                    }
                                                }
                                                .onChange(of: newOffset) { newOffset in
                                                    let delta = oldOffset - newOffset
                                                    totalScrollDistance += delta
                                                    oldOffset = newOffset
                                                    
                                                    let scrollableDistance = contentHeight - scrollViewHeight
                                                    
                                                    if canShowMoreStandings {
                                                        if fbPlayerStandingsStore.filteredStandingsStartIndex != 0 && totalScrollDistance <= 0 {
                                                            canShowMoreStandings = false
                                                            fbPlayerStandingsStore.send(.showMoreStandings(isUp: true))
                                                            //                                                                print("tooooppppp")
                                                        } else if (fbPlayerStandingsStore.filteredStandingsEndIndex != fbPlayerStandingsStore.standings.count - 1) &&
                                                                    (totalScrollDistance >= (scrollableDistance - 2)) { // give extra space for possible difference
                                                            canShowMoreStandings = false
                                                            fbPlayerStandingsStore.send(.showMoreStandings(isUp: false))
                                                            //                                                                print("botttttooom")
                                                        }
                                                    }
                                                }
                                        }
                                    ) // .background()
                                    .onChange(of: fbPlayerStandingsStore.filteredStandingsStartIndex) { newValue in
                                        if fbPlayerStandingsStore.filteredStandings.count == 20 {
                                            proxy.scrollTo(1, anchor: .top)
                                        } else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                proxy.scrollTo(10, anchor: .top)
                                            }
                                        }
                                    }
                                } // ScrollViewReader
                            } // ScrollView
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            scrollViewHeight = geometry.size.height
                                        }
                                }
                            )
                        } // if fbPlayerStandingsStore.displayDataState == .success
                        
                        /* ---------------------
                           error
                           --------------------- */
                        if case .failure(let message) = fbPlayerStandingsStore.displayDataState {
                            Text(message)
                        }
                    } // ZStack
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    @Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    init(fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>) {
        self.fbPlayerStandingsStore = fbPlayerStandingsStore
    }
    
    var body: some View {
        let entityIndex = fbPlayerStandingsStore.entityIndex
        let filteredStandingsStartIndex = fbPlayerStandingsStore.filteredStandingsStartIndex
        
        //            ScrollViewReader { proxy in
        LazyVStack(spacing: 0) {
            ForEach(Array(fbPlayerStandingsStore.filteredStandings.enumerated()), id: \.offset) { index, item in
                let standingsIndex = filteredStandingsStartIndex + index
                
                if entityIndex != nil && entityIndex == standingsIndex {
                    Rectangle()
                        .fill(.moare)
                        .frame(height: 1)
                }
                
                FBPlayerStandingsFirstDataListItem(
                    fbPlayerStandingsStore: fbPlayerStandingsStore,
                    rank: standingsIndex + 1,
                    data: item
                )
                .frame(height: fbPlayerStandingsStore.dataItemHeight)
                .id(index)
                
                if entityIndex != nil && entityIndex == standingsIndex {
                    Rectangle()
                        .fill(.moare)
                        .frame(height: 1)
                }
            }
        }
        //                .onChange(of: fbPlayerStandingsStore.filteredStandingsStartIndex) { newValue in
        //                    if fbPlayerStandingsStore.filteredStandings.count == 20 {
        //                        proxy.scrollTo(1, anchor: .top)
        //                    } else {
        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //                            proxy.scrollTo(10, anchor: .top)
        //                        }
        //                    }
        //                }
        //            }
        .frame(width: fbPlayerStandingsStore.firstCategoryItemWidth)
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
    @Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    let rank: Int
    let data: FBPlayerStandingsDisplay
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(rank)")
                .font(.system(size: fbPlayerStandingsStore.dataFontSize, weight: .medium))
                .frame(width: 28)

            URLImage(url: data.player.photo, customSize: CGSize(width: 25, height: 25))
                .padding(.leading, 4)
                .padding(.trailing, 6)

            VStack(spacing: 2) {
                Text(data.player.krname)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 12))
                    .lineLimit(1)
                
                Text(EnNameTranslationUtility.translateByDic(type: .team, input: data.stats.team.name))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
        .padding(.leading, 10)
    }
}

struct FBPlayerStandingsDataList: View {
    @Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    var body: some View {
        let entityIndex = fbPlayerStandingsStore.entityIndex
        let filteredStandingsStartIndex = fbPlayerStandingsStore.filteredStandingsStartIndex
        
        LazyVStack(spacing: 0) {
            ForEach(Array(fbPlayerStandingsStore.filteredStandings.enumerated()), id: \.offset) { index, item in
                let standingsIndex = filteredStandingsStartIndex + index
                
                if entityIndex != nil && entityIndex == standingsIndex {
                    Rectangle()
                        .fill(.moare)
                        .frame(height: 1)
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<StringConstants.Football.playerStandingsSecondCategories.count) { index in
                        FBPlayerStandingsDataListItem(
                            fbPlayerStandingsStore: fbPlayerStandingsStore,
                            data: item,
                            index: index
                        )
                        .frame(height: fbPlayerStandingsStore.dataItemHeight)
                        .id(index)
                        
                        if index == StringConstants.Football.playerStandingsAttackCategories.count - 1 || index == StringConstants.Football.playerStandingsAttackCategories.count + StringConstants.Football.playerStandingsDefendCategories.count - 1 {
                            Rectangle()
                                .frame(width: 2)
                                .foregroundStyle(.secondary)
                                .opacity(0)
                        }
                    }
                }
                
                if entityIndex != nil && entityIndex == standingsIndex {
                    Rectangle()
                        .fill(.moare)
                        .frame(height: 1)
                }
            }
        }
    }
}

struct FBPlayerStandingsFirstCategoryList: View {
    @Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
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
    @Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        
        Button(action: {
            fbPlayerStandingsStore.send(.selectFirstCategory(index: index))
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
    @Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
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
        } // VStack
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
    @Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
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
            fbPlayerStandingsStore.send(.selectSecondCategory(index: index, category: category))
        }) {
            Text(category)
                .font(.system(size: fontSize, weight: .medium))
                .frame(width: fbPlayerStandingsStore.itemWidth)
        }
        .foregroundStyle(.primary)
    }
}

struct FBPlayerStandingsDataListItem: View {
    @Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
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
