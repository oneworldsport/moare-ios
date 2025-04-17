//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATeamStandingsDisplayModel
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var totalScrollDistance: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    
    let coordinateSpaceName = "TeamStandings"
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack {
                if let nbaTeamStandingsStore {
                    // league
                    HStack {
                        NBATitle(
                            leagueName: "NBA 정규시즌",
                            leagueSeason: Int(nbaTeamStandingsStore.displayModel?.standings.first?.stats.groupValue.split(separator: "-").first ?? "2024")!
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // conference
                    NBAConferenceButtonContainer(
                        nbaTeamStandingsStore: nbaTeamStandingsStore
                    )
                    .padding(.top, 6)
                    
                    // category, standings data
                    ScrollView {
                        HStack(spacing: 0) {
                            NBATeamStandingsFirstDataList(
                                searchStore: searchStore,
                                nbaTeamStandingsStore: nbaTeamStandingsStore,
                                categoryOffset: $totalScrollDistance
                            )
                            
                            
                            ScrollView(.horizontal) {
                                NBATeamStandingsDataList(
                                    nbaTeamStandingsStore: nbaTeamStandingsStore,
                                    categoryOffset: $totalScrollDistance
                                )
                            }
                            .simultaneousGesture(DragGesture())
                        }
                        .background(
                            GeometryReader { geometry in
                                let newOffset = geometry.frame(in: .named(coordinateSpaceName)).minY
                                
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
                    .coordinateSpace(name: coordinateSpaceName)
                } // if let nbaTeamStandingsStore
            } // VStack
            .onAppear {
                // init NBATeamStandingsStore
                let nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore> = storeManager.getStore(forKey: StoreKeys.nbaTeamStandingsStore) ?? {
                    let newStore = Store(initialState: NBATeamStandingsStore.State()) { NBATeamStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaTeamStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaTeamStandingsStore = nbaTeamStandingsStore
                }
                
                if searchStore.poppedView == nil {
                    nbaTeamStandingsStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .nbaTeamStandings = searchStore.poppedView {
                    nbaTeamStandingsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
}

struct NBAConferenceButtonContainer: View {
    @Bindable var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>
    
    @State var barOffset: CGSize
    
    init(nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>) {
        self.nbaTeamStandingsStore = nbaTeamStandingsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: UIConstants.Width.screenWidth / 2), height: 0))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<2, id:\.self) { index in
                    Button(action: {
                        nbaTeamStandingsStore.send(.selectConference(index: index))
                    }) {
                        Text(index == 0 ? "서부 컨퍼런스" : "동부 컨퍼런스")
                            .font(.system(size: nbaTeamStandingsStore.categoryFontSize, weight: .medium))
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(.primary)
                    
                    if index == 0 {
                        Rectangle()
                            .frame(width: 2)
                            .foregroundStyle(.secondary)
                            .opacity(0.5)
                    }
                }
            }
            .frame(maxHeight: nbaTeamStandingsStore.categoryItemHeight - 2)
            
            HCapsuleBar()
                .offset(barOffset)
        }
        .onChange(of: nbaTeamStandingsStore.selectedConferenceIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    private func moveBar(index: Int) {
        withAnimation(.spring(duration: 0.5)) {
            barOffset = CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: UIConstants.Width.screenWidth / 2, index: index) + (index == 1 ? 2 : 0), height: 0)
        }
    }
}

struct NBATeamStandingsFirstDataList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>
    @Binding var categoryOffset: CGFloat
    
    init(searchStore: StoreOf<SearchStore>, nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>, categoryOffset: Binding<CGFloat>) {
        self.searchStore = searchStore
        self.nbaTeamStandingsStore = nbaTeamStandingsStore
        self._categoryOffset = categoryOffset
    }

    var body: some View {
        let standings = nbaTeamStandingsStore.standings
        
        ZStack(alignment: .top) {
            NBATeamStandingsFirstCategoryItem(nbaTeamStandingsStore: nbaTeamStandingsStore)
                .frame(height: nbaTeamStandingsStore.categoryItemHeight)
                .background(.white)
                .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
                .zIndex(1)

            LazyVStack(spacing: 0) {
                ForEach(standings.indices, id: \.self) { index in
                    let data = standings[index]
                    
                    NBATeamStandingsFirstDataListItem(
                        searchStore: searchStore,
                        nbaTeamStandingsStore: nbaTeamStandingsStore,
                        rank: index + 1,
                        data: data
                    )
                }
            }
            .frame(width: nbaTeamStandingsStore.firstCategoryItemWidth)
            .padding(.top, nbaTeamStandingsStore.categoryItemHeight)
        }
    }
}

struct NBATeamStandingsFirstCategoryItem: View {
    @Bindable var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>

    var body: some View {
        HStack(spacing: 0) {
            Text(StringConstants.standingsFirstCategory)
                .font(.system(size: 15, weight: .medium))
                .frame(minWidth: 130)

            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
    }
}

struct NBATeamStandingsFirstDataListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>
    
    let rank: Int
    let data: NBATeamStandingsDisplay

    var body: some View {
        HStack(spacing: 0) {
            Text("\(rank)")
                .font(.system(size: nbaTeamStandingsStore.dataFontSize, weight: .medium))
                .frame(width: 22)

            URLImage(
                url: NBAUtil.teamLogoURL(id: data.team.id),
                customSize: CGSize(width: 25, height: 25),
                isSvg: true
            )
            .padding(.leading, 4)
            .padding(.trailing, 6)

            Text(nbaTeamStandingsStore.teamNameDictionary["short_\(data.team.id)"] ?? data.team.fullName)
                .font(.system(size: 12))
                .lineLimit(2)

            Spacer()

            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
        .padding(.leading, 10)
        .frame(height: nbaTeamStandingsStore.dataItemHeight)
        .onTapGesture {
            searchStore.send(.showTeamStats(teamId: data.team.id))
        }
    }
}

struct NBATeamStandingsDataList: View {
    @Bindable var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>
    
    @Binding var categoryOffset: CGFloat
    
    var body: some View {
        let standings = nbaTeamStandingsStore.standings
        
        ZStack(alignment: .top) {
            NBATeamStandingsCategoryList(nbaTeamStandingsStore: nbaTeamStandingsStore)
            .background(.white)
            .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
            .zIndex(1)
            
            LazyVStack(spacing: 0) {
                ForEach(standings.indices, id: \.self) { index in
                    let data = standings[index]
                    
                    HStack(spacing: 0) {
                        ForEach(0..<StringConstants.NBA.teamStandingsCategories.count) { index in
                            NBATeamStandingsDataListItem(
                                nbaTeamStandingsStore: nbaTeamStandingsStore,
                                data: data,
                                index: index
                            )
                            .frame(height: nbaTeamStandingsStore.dataItemHeight)
                        }
                    }
                }
            }
            .padding(.top, nbaTeamStandingsStore.categoryItemHeight)
        }
    }
}

struct NBATeamStandingsCategoryList: View {
    @Bindable var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>
    
    @State var barOffset: CGSize
    
    let categories = StringConstants.NBA.teamStandingsCategories
    
    init(nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>) {
        self.nbaTeamStandingsStore = nbaTeamStandingsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: nbaTeamStandingsStore.dataItemWidth), height: 0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(categories.indices, id: \.self) { index in
                        let category = categories[index]
                        
                        NBATeamStandingsCategoryListItem(
                            nbaTeamStandingsStore: nbaTeamStandingsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                    }
                }
                .frame(height: nbaTeamStandingsStore.categoryItemHeight - 2)
                .onAppear {
                    // TODO: should decide animation type
                    // scroll and move bar to category that matches with the keyword
                    moveBar(index: nbaTeamStandingsStore.selectedCategoryIndex)
                    
                    withAnimation {
                        proxy.scrollTo(nbaTeamStandingsStore.selectedCategoryIndex, anchor: .leading)
                    }
                }
            } // ScrollViewReader
            
            HCapsuleBar()
                .offset(barOffset)
        } // VStack
        .onChange(of: nbaTeamStandingsStore.selectedCategoryIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    private func moveBar(index: Int) {
        withAnimation(.spring(duration: 0.5)) {
            barOffset = CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: nbaTeamStandingsStore.dataItemWidth, index: index), height: 0)
        }
    }
}

struct NBATeamStandingsCategoryListItem: View {
    @Bindable var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        Button(action: {
            nbaTeamStandingsStore.send(.selectCategory(index: index))
        }) {
            Text(category.contains("경기당") ? "경기당\n\(category.dropFirst(4))" : category)
                .font(.system(size: nbaTeamStandingsStore.categoryFontSize, weight: .medium))
                .frame(width: nbaTeamStandingsStore.dataItemWidth)
        }
        .foregroundStyle(.primary)
    }
}

struct NBATeamStandingsDataListItem: View {
    @Bindable var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>
    
    let data: NBATeamStandingsDisplay
    let index: Int
    
    var body: some View {
        Text(dataText)
            .font(.system(size: nbaTeamStandingsStore.dataFontSize))
            .frame(width: nbaTeamStandingsStore.dataItemWidth)
    }
    
    private var dataText: String {
        switch index {
        case 0: "\(calculateGamesBack(team: data.stats))"
        case 1: "\(data.stats.winsPct)"
        case 2: "\(data.stats.wins)"
        case 3: "\(data.stats.losses)"
        case 4: "\(data.stats.gp)"
        case 5: "\(data.stats.ptsPG)"
        case 6: "\(data.stats.plusMinusPG)"
        case 7: "\(data.stats.astPG)"
        case 8: "\(data.stats.rebPG)"
        case 9: "\(data.stats.fgPct)"
        case 10: "\(data.stats.fg3Pct)"
        case 11: "\(data.stats.ftPct)"
        case 12: "\(data.stats.blkPG)"
        case 13: "\(data.stats.stlPG)"
        case 14: "\(data.stats.tovPG)"
        case 15: "\(data.stats.pfPG)"
        default: ""
        }
    }
    
    private func calculateGamesBack(team: NBATeamStats) -> Double {
        guard let leader = nbaTeamStandingsStore.standings.max(by: { $0.stats.winsPct < $1.stats.winsPct }) else {
            return 0
        }
        
        return Double((leader.stats.wins - team.wins) + (team.losses - leader.stats.losses)) / 2.0
    }
}
