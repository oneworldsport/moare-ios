//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBAPlayerStandingsDisplayModel
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var totalScrollDistance: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    
    @State private var canShowMoreStandings = true
    
    @State private var hScrollOffset: CGFloat = 0
    
    let coordinateSpaceName = "PlayerStandings"
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let nbaPlayerStandingsStore {
                    HStack {
                        NBATitle(
                            leagueName: "NBA 정규시즌",
                            leagueSeason: Int(nbaPlayerStandingsStore.displayModel?.standings.first?.stats.groupValue.split(separator: "-").first ?? "2024")!
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                    
                    // category
                    HStack(spacing: 0) {
                        NBAPlayerStandingsFirstCategoryItem(nbaPlayerStandingsStore: nbaPlayerStandingsStore)
                        
                        HSynchronizedScrollView(scrollOffset: $hScrollOffset, itemWidth: nbaPlayerStandingsStore.itemWidth, itemHeight: nbaPlayerStandingsStore.firstCategoryItemHeight) {
                            VStack(spacing: 0) {
                                NBAPlayerStandingsFirstCategoryList(nbaPlayerStandingsStore: nbaPlayerStandingsStore)
                                NBAPlayerStandingsSecondCategoryList(nbaPlayerStandingsStore: nbaPlayerStandingsStore)
                            }
                        }
                        .simultaneousGesture(DragGesture()) // prevent parent view's back handler DragGesture()
                    }
                    .frame(height: nbaPlayerStandingsStore.firstCategoryItemHeight + nbaPlayerStandingsStore.secondCategoryItemHeight)
                    
                    ZStack {
                        // loading
                        if nbaPlayerStandingsStore.displayDataState == .fetching {
                            ProgressView()
                        }
                        
                        // standings
                        if nbaPlayerStandingsStore.displayDataState == .success {
                            ScrollView {
                                ScrollViewReader { proxy in
                                    HStack(alignment: .top, spacing: 0) {
                                        NBAPlayerStandingsFirstDataList(searchStore: searchStore, nbaPlayerStandingsStore: nbaPlayerStandingsStore)
                                        //                                .frame(maxHeight: .infinity, alignment: .top) // 정렬 안맞는 현상때문에 추가
                                        //                                .background(Color.red.opacity(0.3))
                                        
                                        HSynchronizedScrollView(scrollOffset: $hScrollOffset, itemWidth: nbaPlayerStandingsStore.itemWidth, itemHeight: nbaPlayerStandingsStore.dataItemHeight) {
                                            NBAPlayerStandingsDataList(nbaPlayerStandingsStore: nbaPlayerStandingsStore)
                                                .padding(.top, 2) // 하이라이트 선 때문인지는 모르겠는데, 정렬 안맞는 현상 있어서 추가해줌. ScrollView가 문제인듯.
                                            //                                    .frame(maxHeight: .infinity, alignment: .top) // 정렬 안맞는 현상때문에 추가
                                            //                                    .background(Color.blue.opacity(0.3))
                                        }
                                        .frame(height: nbaPlayerStandingsStore.dataItemHeight * CGFloat(nbaPlayerStandingsStore.filteredStandings.count), alignment: .top) // 정렬 안맞는 현상때문에 추가
                                        .simultaneousGesture(DragGesture())
                                    }
                                    .background(
                                        GeometryReader { geometry in
                                            let newOffset = geometry.frame(in: .named(coordinateSpaceName)).minY
                                            
                                            Color.clear
                                                .onAppear {
                                                    oldOffset = newOffset
                                                    
                                                    contentHeight = CGFloat(nbaPlayerStandingsStore.filteredStandings.count) * nbaPlayerStandingsStore.dataItemHeight
                                                }
                                                .onChange(of: nbaPlayerStandingsStore.filteredStandings.count) { newValue in
                                                    contentHeight = CGFloat(newValue) * nbaPlayerStandingsStore.dataItemHeight
                                                    
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
                                                        if nbaPlayerStandingsStore.filteredStandingsStartIndex != 0 && totalScrollDistance <= 0 {
                                                            canShowMoreStandings = false
                                                            nbaPlayerStandingsStore.send(.showMoreStandings(isUp: true))
                                                            //                                                                print("tooooppppp")
                                                        } else if (nbaPlayerStandingsStore.filteredStandingsEndIndex != nbaPlayerStandingsStore.standings.count - 1) &&
                                                                    (totalScrollDistance >= (scrollableDistance - 2)) { // give extra space for possible difference
                                                            canShowMoreStandings = false
                                                            nbaPlayerStandingsStore.send(.showMoreStandings(isUp: false))
                                                            //                                                                print("botttttooom")
                                                        }
                                                    }
                                                }
                                        }
                                    ) // .background()
                                    .onChange(of: nbaPlayerStandingsStore.filteredStandingsStartIndex) { newValue in
                                        if nbaPlayerStandingsStore.filteredStandings.count == 20 {
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
                            .coordinateSpace(name: coordinateSpaceName)
                        } // if nbaPlayerStandingsStore.displayDataState == .success
                        
                        /* ---------------------
                           error
                           --------------------- */
                        if case .failure(let message) = nbaPlayerStandingsStore.displayDataState {
                            Text(message)
                        }
                    } // ZStack
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } // if let nbaPlayerStandingsStore
            } // VStack
            .onAppear {
                // init NBAPlayerStandingsStore
                let nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore> = storeManager.getStore(forKey: StoreKeys.nbaPlayerStandingsStore) ?? {
                    let newStore = Store(initialState: NBAPlayerStandingsStore.State()) { NBAPlayerStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaPlayerStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaPlayerStandingsStore = nbaPlayerStandingsStore
                }
                
                if searchStore.poppedView == nil {
                    nbaPlayerStandingsStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .nbaPlayerStandings = searchStore.poppedView {
                    nbaPlayerStandingsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
}

struct NBAPlayerStandingsFirstCategoryItem: View {
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    var body: some View {
        HStack(spacing: 0) {
            Text(StringConstants.standingsFirstCategory)
                .font(.system(size: nbaPlayerStandingsStore.firstCategoryFontSize, weight: .medium))
                .frame(minWidth: 130)
            
            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
    }
}

struct NBAPlayerStandingsFirstCategoryList: View {
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    @State var barOffset: CGSize
    
    init(nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>) {
        self.nbaPlayerStandingsStore = nbaPlayerStandingsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: nbaPlayerStandingsStore.itemWidth * CGFloat(StringConstants.NBA.playerStandingsAttackCategories.count), barWidth: 80), height: 0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(StringConstants.statsFirstCategories.indices, id: \.self) { index in
                    let category = StringConstants.statsFirstCategories[index]
                    
                    NBAPlayerStandingsFirstCategoryListItem(
                        nbaPlayerStandingsStore: nbaPlayerStandingsStore,
                        index: index,
                        category: category
                    )
                    .id(index)
                    
                    if index != StringConstants.statsFirstCategories.count - 1 {
                        Rectangle()
                            .frame(width: 2)
                            .foregroundStyle(.secondary)
                            .opacity(0.5)
                    }
                }
            }
            .frame(height: nbaPlayerStandingsStore.firstCategoryItemHeight - 2)
            
            HCapsuleBar(customWidth: 80)
                .offset(barOffset)
        }
        .onChange(of: nbaPlayerStandingsStore.firstSelectedIndex) {
            moveBar(index: nbaPlayerStandingsStore.firstSelectedIndex)
        }
    }
    
    func moveBar(index: Int) {
        let itemWidth = nbaPlayerStandingsStore.itemWidth
        let barWidth = nbaPlayerStandingsStore.barWidth
        
        let attackCategoriesCount = CGFloat(StringConstants.NBA.playerStandingsAttackCategories.count)
        let defendCategoriesCount = CGFloat(StringConstants.NBA.playerStandingsDefendCategories.count)
        let commonCategoriesCount = CGFloat(StringConstants.NBA.playerStandingsCommonCategories.count)
        
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: itemWidth * attackCategoriesCount, barWidth: 80), height: 0)
            case 1:
                barOffset = CGSize(width: (itemWidth * attackCategoriesCount) + barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * defendCategoriesCount, barWidth: 80), height: 0)
            default:
                barOffset = CGSize(width: (itemWidth * attackCategoriesCount) + (barWidth * 2) + (itemWidth * defendCategoriesCount) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * commonCategoriesCount, barWidth: 80), height: 0)
            }
        }
    }
}

struct NBAPlayerStandingsFirstCategoryListItem: View {
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        Button(action: {
            nbaPlayerStandingsStore.send(.selectFirstCategory(index: index))
        }) {
            Text(category)
                .font(.system(size: nbaPlayerStandingsStore.firstCategoryFontSize, weight: .medium))
                .frame(width: width)
        }
        .foregroundStyle(.primary)
    }
    
    private var width: CGFloat {
        switch index {
        case 0: nbaPlayerStandingsStore.itemWidth * CGFloat(StringConstants.NBA.playerStandingsAttackCategories.count)
        case 1: nbaPlayerStandingsStore.itemWidth * CGFloat(StringConstants.NBA.playerStandingsDefendCategories.count)
        default: nbaPlayerStandingsStore.itemWidth * CGFloat(StringConstants.NBA.playerStandingsCommonCategories.count)
        }
    }
}

struct NBAPlayerStandingsSecondCategoryList: View {
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    @State var barOffset: CGSize
    
    let attackCategoriesCount = StringConstants.NBA.playerStandingsAttackCategories.count
    let defendCategoriesCount = StringConstants.NBA.playerStandingsDefendCategories.count
    
    init(nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>) {
        self.nbaPlayerStandingsStore = nbaPlayerStandingsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: nbaPlayerStandingsStore.itemWidth), height: 0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(StringConstants.NBA.playerStandingsSecondCategories.indices, id: \.self) { index in
                        let category = StringConstants.NBA.playerStandingsSecondCategories[index]
                        
                        NBAPlayerStandingsSecondCategoryListItem(
                            nbaPlayerStandingsStore: nbaPlayerStandingsStore,
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
                .frame(height: nbaPlayerStandingsStore.secondCategoryItemHeight - 2)
                .onAppear {
                    // TODO: should decide animation type
                    // scroll and move bar to category that matches with the keyword
                    moveBar(index: nbaPlayerStandingsStore.secondSelectedIndex)
                    
                    withAnimation {
                        proxy.scrollTo(nbaPlayerStandingsStore.secondSelectedIndex, anchor: .leading)
                    }
                }
                .onChange(of: nbaPlayerStandingsStore.firstSelectedIndex) { newValue in
                    if nbaPlayerStandingsStore.shouldScrollCategory {
                        withAnimation {
                            proxy.scrollTo(nbaPlayerStandingsStore.secondSelectedIndex, anchor: .leading)
                        }
                    }
                }
            } // ScrollViewReader
            
            HCapsuleBar()
                .offset(barOffset)
        } // VStack
        .onChange(of: nbaPlayerStandingsStore.secondSelectedIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    func moveBar(index: Int) {
        let itemWidth = nbaPlayerStandingsStore.itemWidth
        let barWidth = nbaPlayerStandingsStore.barWidth
        
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

struct NBAPlayerStandingsSecondCategoryListItem: View {
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        Button(action: {
            nbaPlayerStandingsStore.send(.selectSecondCategory(index: index, category: category))
        }) {
            Text(category.contains("경기당") ? "경기당\n\(category.dropFirst(4))" : category)
                .font(.system(size: nbaPlayerStandingsStore.secondCategoryFontSize, weight: .medium))
                .frame(width: nbaPlayerStandingsStore.itemWidth)
        }
        .foregroundStyle(.primary)
    }
}

struct NBAPlayerStandingsFirstDataList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    var body: some View {
        let filteredStandings = nbaPlayerStandingsStore.filteredStandings
        let entityIndex = nbaPlayerStandingsStore.entityIndex
        let filteredStandingsStartIndex = nbaPlayerStandingsStore.filteredStandingsStartIndex
        
        LazyVStack(spacing: 0) {
            ForEach(Array(filteredStandings.enumerated()), id: \.offset) { index, item in
                let standingsIndex = filteredStandingsStartIndex + index
                
                if entityIndex != nil && entityIndex == standingsIndex {
                    Rectangle()
                        .fill(.moare)
                        .frame(height: 1)
                }
                
                NBAPlayerStandingsFirstDataListItem(
                    searchStore: searchStore,
                    nbaPlayerStandingsStore: nbaPlayerStandingsStore,
                    rank: standingsIndex + 1,
                    data: item
                )
                .frame(height: nbaPlayerStandingsStore.dataItemHeight)
                .id(index)
                
                if entityIndex != nil && entityIndex == standingsIndex {
                    Rectangle()
                        .fill(.moare)
                        .frame(height: 1)
                }
            }
        }
        .frame(width: nbaPlayerStandingsStore.firstCategoryItemWidth)
    }
}

struct NBAPlayerStandingsFirstDataListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    let rank: Int
    let data: NBAPlayerStandingsDisplay
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(rank)")
                .font(.system(size: nbaPlayerStandingsStore.dataFontSize, weight: .medium))
                .frame(width: 28)

            URLImage(url: NBAUtil.playerPhotoURL(id: data.player.personId), customSize: CGSize(width: 25, height: 25))
                .padding(.leading, 4)
                .padding(.trailing, 6)

            VStack(spacing: 2) {
                Text(nbaPlayerStandingsStore.playerNameDictionary[data.player.displayFirstLast.lowercased()] ?? data.player.displayFirstLast)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 12))
                    .lineLimit(1)
                
                Text(nbaPlayerStandingsStore.teamNameDictionary["short_\(data.player.teamId)"] ?? data.player.teamCity)
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
        .onTapGesture {
            searchStore.send(.showPlayerStats(category: "basketball", playerId: data.player.personId))
        }
    }
}

struct NBAPlayerStandingsDataList: View {
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    let attackCategoriesCount = StringConstants.NBA.playerStandingsAttackCategories.count
    let defendCategoriesCount = StringConstants.NBA.playerStandingsDefendCategories.count
    
    var body: some View {
        let filteredStandings = nbaPlayerStandingsStore.filteredStandings
        let entityIndex = nbaPlayerStandingsStore.entityIndex
        let filteredStandingsStartIndex = nbaPlayerStandingsStore.filteredStandingsStartIndex
        
        LazyVStack(spacing: 0) {
            ForEach(Array(filteredStandings.enumerated()), id: \.offset) { index, item in
                let standingsIndex = filteredStandingsStartIndex + index
                
                if entityIndex != nil && entityIndex == standingsIndex {
                    Rectangle()
                        .fill(.moare)
                        .frame(height: 1)
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<StringConstants.NBA.playerStandingsSecondCategories.count) { index in
                        NBAPlayerStandingsDataListItem(
                            nbaPlayerStandingsStore: nbaPlayerStandingsStore,
                            data: item,
                            index: index
                        )
                        .frame(height: nbaPlayerStandingsStore.dataItemHeight)
                        .id(index)
                        
                        if index == attackCategoriesCount - 1 || index == attackCategoriesCount + defendCategoriesCount - 1 {
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

struct NBAPlayerStandingsDataListItem: View {
    @Bindable var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>
    
    let data: NBAPlayerStandingsDisplay
    let index: Int
    
    var body: some View {
        Text(intDataText)
            .font(.system(size: nbaPlayerStandingsStore.dataFontSize))
            .frame(width: nbaPlayerStandingsStore.itemWidth)
    }
    
    private var intDataText: String {
        switch index {
        case 0: "\(data.stats.ptsPG)"
        case 1: "\(data.stats.astPG)"
        case 2: "\(data.stats.orebPG)"
        case 3: "\(data.stats.fgaPG)"
        case 4: "\(data.stats.fgmPG)"
        case 5: "\(data.stats.fgPct)"
        case 6: "\(data.stats.fg3aPG)"
        case 7: "\(data.stats.fg3mPG)"
        case 8: "\(data.stats.fg3Pct)"
        case 9: "\(data.stats.ftaPG)"
        case 10: "\(data.stats.ftmPG)"
        case 11: "\(data.stats.ftPct)"
        case 12: "\(data.stats.drebPG)"
        case 13: "\(data.stats.blkPG)"
        case 14: "\(data.stats.stlPG)"
        case 15: "\(data.stats.rebPG)"
        case 16: "\(data.stats.tovPG)"
        case 17: "\(data.stats.pfPG)"
        case 18: "\(data.stats.pfdPG)"
        case 19: "\(data.stats.blkaPG)"
        case 20: "\(data.stats.plusMinusPG)"
        case 21: "\(data.stats.gp)"
        case 22: data.stats.minPG
        case 23: "\(data.stats.wins)"
        case 24: "\(data.stats.losses)"
        case 25: "\(data.stats.winsPct)"
        case 26: "\(data.stats.td3)"
        case 27: "\(data.stats.dd2)"
        case 28: "\(data.stats.ptsPG)"
        default: ""
        }
    }
}
