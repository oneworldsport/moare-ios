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
                storeManager.setStore(
                    Store(initialState: FBPlayerStandingsStore.State(
                        displayModel: displayModel, standings: displayModel.standings
                    )) { FBPlayerStandingsStore() },
                    forKey: StoreKeys.fbPlayerStandingsStore
                )
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    fbPlayerStandingsStore = storeManager.getStore(forKey: StoreKeys.fbPlayerStandingsStore)                    
                }
                
                fbPlayerStandingsStore?.send(.initData)
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
            FBPlayerStandingsFirstCategoryItem(category: fbPlayerStandingsStore.firstCategory)
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
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(rank)")
                .font(.system(size: fbPlayerStandingsStore.dataFontSize, weight: .medium))
                .frame(width: 22)

            URLImage(url: data.player.photo, customSize: CGSize(width: 25, height: 25))
                .padding(.leading, 4)
                .padding(.trailing, 6)

            Text(data.player.krname)
                .font(.system(size: 12))
                .lineLimit(2)

            Spacer()

            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
        .padding(.leading, 10)
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
                        ForEach(0..<11) { index in
                            FBPlayerStandingsDataListItem(
                                fbPlayerStandingsStore: fbPlayerStandingsStore,
                                data: data,
                                index: index
                            )
                            .frame(height: fbPlayerStandingsStore.dataItemHeight)
                            
                            if index == fbPlayerStandingsStore.attackCategoryList.count - 1 || index == fbPlayerStandingsStore.attackCategoryList.count + fbPlayerStandingsStore.defendCategoryList.count - 1 {
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
        
        self._barOffset = State(initialValue: getOffsetOfAniCapsuleBar(itemWidth: fbPlayerStandingsStore.itemWidth * 5, barWidth: 80))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(fbPlayerStandingsStore.firstCategoryList.indices, id: \.self) { index in
                        let category = fbPlayerStandingsStore.firstCategoryList[index]
                        
                        FBPlayerStandingsFirstCategoryListItem(
                            fbPlayerStandingsStore: fbPlayerStandingsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                        
                        if index != fbPlayerStandingsStore.firstCategoryList.count - 1 {
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
        
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = getOffsetOfAniCapsuleBar(itemWidth: itemWidth * 5, barWidth: 80)
            case 1:
                barOffset = CGSize(width: (itemWidth * 5) + barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * 2, barWidth: 80).width, height: 0)
            default:
                barOffset = CGSize(width: (itemWidth * 5) + (barWidth * 2) + (itemWidth * 2) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * 4, barWidth: 80).width, height: 0)
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
        case 0: fbPlayerStandingsStore.itemWidth * 5
        case 1: fbPlayerStandingsStore.itemWidth * 2
        default: fbPlayerStandingsStore.itemWidth * 4
        }
    }
}

struct FBPlayerStandingsSecondCategoryList: View {
    @ComposableArchitecture.Bindable var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>
    
    @State var barOffset: CGSize
    
    init(fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>) {
        self.fbPlayerStandingsStore = fbPlayerStandingsStore
        
        self._barOffset = State(initialValue: getOffsetOfAniCapsuleBar(itemWidth: fbPlayerStandingsStore.itemWidth))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(fbPlayerStandingsStore.secondCategoryList.indices, id: \.self) { index in
                        let category = fbPlayerStandingsStore.secondCategoryList[index]
                        
                        FBPlayerStandingsSecondCategoryListItem(
                            fbPlayerStandingsStore: fbPlayerStandingsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                        
                        if index == fbPlayerStandingsStore.attackCategoryList.count - 1 || index == fbPlayerStandingsStore.attackCategoryList.count + fbPlayerStandingsStore.defendCategoryList.count - 1 {
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
            case 0..<fbPlayerStandingsStore.attackCategoryList.count:
                barOffset = getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index)
            case fbPlayerStandingsStore.attackCategoryList.count..<fbPlayerStandingsStore.attackCategoryList.count + fbPlayerStandingsStore.debugDescription.count:
                barOffset = CGSize(width: barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index).width, height: 0)
            default:
                barOffset = CGSize(width: (barWidth * 2) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index).width, height: 0)
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
        case 5: "\(data.stats.tackles.total)"
        case 6: "\(data.stats.passes.total)"
        case 7: "\(data.stats.fouls.committed)"
        case 8: "\(data.stats.cards.yellow)"
        case 9: "\(data.stats.cards.red)"
        case 10: "\(data.stats.games.appearences)"
        default: ""
        }
    }
}

//#Preview {
//    FBPlayerStandingsView()
//}
