//
//  FBTeamStandingsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/17/24.
//

import SwiftUI
import ComposableArchitecture

struct FBTeamStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBTeamStandingsDisplayModel
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var totalScrollDistance: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack {
                if let fbTeamStandingsStore = fbTeamStandingsStore {
                    // league
                    if let league = fbTeamStandingsStore.league {
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
                            FBTeamStandingsFirstDataList(
                                searchStore: searchStore,
                                fbTeamStandingsStore: fbTeamStandingsStore,
                                categoryOffset: $totalScrollDistance
                            )
                            
                            
                            ScrollView(.horizontal) {
                                FBTeamStandingsDataList(
                                    fbTeamStandingsStore: fbTeamStandingsStore,
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
                // init FBTeamStandingsStore
                let fbTeamStandingsStore: StoreOf<FBTeamStandingsStore> = storeManager.getStore(forKey: StoreKeys.fbTeamStandingsStore) ?? {
                    let newStore = Store(initialState: FBTeamStandingsStore.State()) { FBTeamStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTeamStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbTeamStandingsStore = fbTeamStandingsStore
                }
                
                fbTeamStandingsStore.send(.initData(displayModel: displayModel))
            }
        }
    }
}

struct FBTeamStandingsFirstDataList: View {
    @ComposableArchitecture.Bindable var searchStore: StoreOf<SearchStore>
    @ComposableArchitecture.Bindable var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>
    @Binding var categoryOffset: CGFloat
    
    init(searchStore: StoreOf<SearchStore>, fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>, categoryOffset: Binding<CGFloat>) {
        self.searchStore = searchStore
        self.fbTeamStandingsStore = fbTeamStandingsStore
        self._categoryOffset = categoryOffset
    }

    var body: some View {
        ZStack(alignment: .top) {
            FBTeamStandingsFirstCategoryItem(category: fbTeamStandingsStore.firstCategory)
                .frame(height: fbTeamStandingsStore.categoryItemHeight)
                .background(.white)
                .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
                .zIndex(1)

            LazyVStack(spacing: 0) {
                ForEach(fbTeamStandingsStore.standings.indices, id: \.self) { index in
                    let data = fbTeamStandingsStore.standings[index]
                    
                    FBTeamStandingsFirstDataListItem(
                        searchStore: searchStore,
                        fbTeamStandingsStore: fbTeamStandingsStore,
                        rank: index + 1,
                        data: data
                    )
                    .frame(height: fbTeamStandingsStore.dataItemHeight)
                }
            }
            .frame(width: fbTeamStandingsStore.firstCategoryItemWidth)
            .padding(.top, fbTeamStandingsStore.categoryItemHeight)
        }
    }
}

struct FBTeamStandingsFirstCategoryItem: View {
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

struct FBTeamStandingsFirstDataListItem: View {
    @ComposableArchitecture.Bindable var searchStore: StoreOf<SearchStore>
    @ComposableArchitecture.Bindable var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>
    
    let rank: Int
    let data: FBTeamStandingsDisplay
    
    @State private var teamKrName = ""

    var body: some View {
        HStack(spacing: 0) {
            Text("\(rank)")
                .font(.system(size: fbTeamStandingsStore.dataFontSize, weight: .medium))
                .frame(width: 22)

            URLImage(url: data.team.logo, customSize: CGSize(width: 25, height: 25))
                .padding(.leading, 4)
                .padding(.trailing, 6)

            Text(EnNameTranslationUtility.translateByDic(type: .team, input: teamKrName))
                .font(.system(size: 12))
                .lineLimit(2)

            Spacer()

            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
        .padding(.leading, 10)
        .onTapGesture {
            searchStore.send(.showTeamStats(data.team.id))
        }
        .onAppear {
            translate()
        }
    }
    
    private func translate() {
        Task {
            let teamKrName = await EnNameTranslationUtility.translateByAWS(input: data.team.name)
            self.teamKrName = teamKrName
        }
    }
}

struct FBTeamStandingsDataList: View {
    @ComposableArchitecture.Bindable var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>
    
    @Binding var categoryOffset: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            FBTeamStandingsCategoryList(fbTeamStandingsStore: fbTeamStandingsStore)
            .background(.white)
            .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
            .zIndex(1)
            
            LazyVStack(spacing: 0) {
                ForEach(fbTeamStandingsStore.standings.indices, id: \.self) { index in
                    let data = fbTeamStandingsStore.standings[index]
                    
                    HStack(spacing: 0) {
                        ForEach(0..<10) { index in
                            FBTeamStandingsDataListItem(
                                fbTeamStandingsStore: fbTeamStandingsStore,
                                data: data,
                                isInt: index == 8 || index == 9 ? false : true,
                                index: index
                            )
                            .frame(height: fbTeamStandingsStore.dataItemHeight)
                        }
                    }
                }
            }
            .padding(.top, fbTeamStandingsStore.categoryItemHeight)
        }
    }
}

struct FBTeamStandingsCategoryList: View {
    @ComposableArchitecture.Bindable var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>
    
    @State var barOffset: CGSize
    
    init(fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>) {
        self.fbTeamStandingsStore = fbTeamStandingsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: fbTeamStandingsStore.intDataItemWidth), height: 0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(fbTeamStandingsStore.categoryList.indices, id: \.self) { index in
                        let category = fbTeamStandingsStore.categoryList[index]
                        
                        // 홈성적, 원정성적(index 8, 9) is not int
                        FBTeamStandingsCategoryListItem(
                            fbTeamStandingsStore: fbTeamStandingsStore,
                            index: index,
                            category: category,
                            isInt: index == 8 || index == 9 ? false : true
                        )
                        .id(index)
                    }
                }
                .frame(height: fbTeamStandingsStore.categoryItemHeight - 2)
                .onAppear {
                    // TODO: should decide animation type
                    // scroll and move bar to category that matches with the keyword
                    moveBar(index: fbTeamStandingsStore.selectedIndex)
                    
                    withAnimation {
                        proxy.scrollTo(fbTeamStandingsStore.selectedIndex, anchor: .leading)
                    }
                }
            } // ScrollViewReader
            
            HCapsuleBar()
                .offset(barOffset)
        } // VStack
        .onChange(of: fbTeamStandingsStore.selectedIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    private func moveBar(index: Int) {
        withAnimation(.spring(duration: 0.5)) {
            if index == 8 || index == 9 {
                if index == 8 {
                    barOffset = CGSize(width: fbTeamStandingsStore.intDataItemWidth * CGFloat(index) + getOffsetOfAniCapsuleBar(itemWidth: fbTeamStandingsStore.stringDataItemWidth), height: 0)
                } else {
                    barOffset = CGSize(width: fbTeamStandingsStore.intDataItemWidth * CGFloat(index - 1) + getOffsetOfAniCapsuleBar(itemWidth: fbTeamStandingsStore.stringDataItemWidth, index: 1), height: 0)
                }
            } else {
                barOffset = CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: fbTeamStandingsStore.intDataItemWidth, index: index), height: 0)
            }
        }
    }
}

struct FBTeamStandingsCategoryListItem: View {
    @ComposableArchitecture.Bindable var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>
    
    let index: Int
    let category: String
    let isInt: Bool
    
    var body: some View {
        Button(action: {
            fbTeamStandingsStore.send(.selectCategory(index))
        }) {
            Text(category)
                .font(.system(size: fbTeamStandingsStore.categoryFontSize, weight: .medium))
                .frame(width: isInt ? fbTeamStandingsStore.intDataItemWidth : fbTeamStandingsStore.stringDataItemWidth)
        }
        .foregroundStyle(.primary)
    }
}

struct FBTeamStandingsDataListItem: View {
    @ComposableArchitecture.Bindable var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>
    
    let data: FBTeamStandingsDisplay
    let isInt: Bool
    let index: Int
    
    var body: some View {
        if isInt {
            Text(intDataText)
                .font(.system(size: fbTeamStandingsStore.dataFontSize))
                .frame(width: fbTeamStandingsStore.intDataItemWidth)
        } else {
            if index == 8 {
                HStack(spacing: 0) {
                    Text("\(data.homeAwayStats.wins.home)승")
                        .font(.system(size: 16))
                        .frame(width: 34)
                    Text("\(data.homeAwayStats.draws.home)무")
                        .font(.system(size: 16))
                        .frame(width: 34)
                    Text("\(data.homeAwayStats.loses.home)패")
                        .font(.system(size: 16))
                        .frame(width: 34)
                }
                .padding(.horizontal, 4)
            } else if index == 9 {
                HStack(spacing: 0) {
                    Text("\(data.homeAwayStats.wins.away)승")
                        .font(.system(size: 16))
                        .frame(width: fbTeamStandingsStore.stringDataItemTextWidth)
                    Text("\(data.homeAwayStats.draws.away)무")
                        .font(.system(size: 16))
                        .frame(width: fbTeamStandingsStore.stringDataItemTextWidth)
                    Text("\(data.homeAwayStats.loses.away)패")
                        .font(.system(size: 16))
                        .frame(width: fbTeamStandingsStore.stringDataItemTextWidth)
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var intDataText: String {
        switch index {
        case 0:
            calculatePoints(data: data.homeAwayStats)
        case 1:
            "\(data.homeAwayStats.wins.total)"
        case 2:
            "\(data.homeAwayStats.draws.total)"
        case 3:
            "\(data.homeAwayStats.loses.total)"
        case 4:
            "\(data.homeAwayStats.played.total)"
        case 5:
            "\(data.goalsFor.total)"
        case 6:
            "\(data.goalsAgainst.total)"
        case 7:
            "\(data.goalsFor.total - data.goalsAgainst.total)"
        default:
            ""
        }
    }
    
    private func calculatePoints(data: FBTeamStatsFixtures) -> String {
        return "\((data.wins.total * 3) + data.draws.total)"
    }
}
