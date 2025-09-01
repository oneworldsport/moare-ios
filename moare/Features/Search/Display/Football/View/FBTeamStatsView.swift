//
//  FBTeamStatsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import SwiftUI
import ComposableArchitecture

struct FBTeamStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbTeamStatsStore: StoreOf<FBTeamStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBTeamStatsDisplayModel
    
    var startOffset = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                InfoViewContainer(
                    itemCount: (fbTeamStatsStore?.displayModel?.stats.count ?? 0) + 1,
                    shouldShowMeasureContent: true,
                    measureContent: { scope in
                        if let fbTeamStatsStore {
                            FBTeamStatsTeamInfoItem(fbTeamStatsStore: fbTeamStatsStore)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onAppear {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            FBTeamStatsList(fbTeamStatsStore: fbTeamStatsStore, scope: scope)
                        }
                    }, displayContent: { scope in
                        if let fbTeamStatsStore {
                            // team info
                            FBTeamStatsTeamInfoItem(
                                fbTeamStatsStore: fbTeamStatsStore,
                                isAniItem: true,
                                itemOffset: scope.computedOffset(for: 0, startOffset: startOffset),
                                showContents: scope.showContents
                            )
                            
                            // stats list
                            FBTeamStatsList(
                                fbTeamStatsStore: fbTeamStatsStore,
                                isAniItem: true,
                                scope: scope
                            )
                        }
                    }
                )
            } // ScrollView
            .onAppear {
                // init FBTeamStatsStore
                let fbTeamStatsStore: StoreOf<FBTeamStatsStore> = storeManager.getStore(forKey: StoreKeys.fbTeamStatsStore) ?? {
                    let newStore = Store(initialState: FBTeamStatsStore.State()) { FBTeamStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTeamStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.fbTeamStatsStore = fbTeamStatsStore
                }
                
                if searchStore.poppedView == nil {
                    fbTeamStatsStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .fbTeamStats = searchStore.poppedView {
                    fbTeamStatsStore?.send(.initData(displayModel: displayModel))
                }
            }
        }
    }
}

struct FBTeamStatsTeamInfoItem: View {
    @Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbTeamStatsStore: StoreOf<FBTeamStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbTeamStatsStore.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            if let team = fbTeamStatsStore.team, let venue = fbTeamStatsStore.venue {
                HStack {
                    URLImage(url: team.logo)
                    
                    VStack(alignment: .leading) {
                        Text(teamNameDic["full_\(team.id)"] ?? team.name)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                        
                        Text("\(team.name)")
                            .font(.system(size: 15))
                            .fontWeight(.light)
                            .lineLimit(2)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        (
                            Text("연고지: ")
                                .font(.system(size: 15))
                            + Text(venue.city)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        )
                        .multilineTextAlignment(.leading)
                        
                        (
                            Text("홈구장: ")
                                .font(.system(size: 15))
                            + Text(teamNameDic["venue_\(team.id)"] ?? venue.name)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        )
                        .multilineTextAlignment(.leading)
                    }
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBTeamStatsList: View {
    @Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let isAniItem: Bool
    let scope: InfoViewScope
    
    var startOffset = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)

    init(
        fbTeamStatsStore: StoreOf<FBTeamStatsStore>,
        isAniItem: Bool = false,
        scope: InfoViewScope,
    ) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.isAniItem = isAniItem
        self.scope = scope
    }
    
    var body: some View {
        ForEach(fbTeamStatsStore.statsList.indices, id: \.self) { index in
            let stats = fbTeamStatsStore.statsList[index]
            let itemIndex = index + 1
            
            FBTeamStatsListItem(
                fbTeamStatsStore: fbTeamStatsStore,
                stats: stats,
                isAniItem: isAniItem,
                itemSize: scope.itemSizes[itemIndex],
                itemOffset: scope.computedOffset(for: itemIndex, startOffset: startOffset),
                showContents: scope.showContents
            )
            .background(
                GeometryReader { geometry in
                    if !isAniItem {
                        // 1) 최초 한 번은 무조건 측정 - gpt
                        // NOTE: Color.clear.onChange()만 했을때는 update가 안돼서 Color.clear.onAppear 추가해줌
                        Color.clear.onAppear {
                            scope.updateItemFrame(index: itemIndex, geometry: geometry)
                        }
                        // 2) 위치 변하면 - gpt
                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                            scope.updateItemFrame(index: itemIndex, geometry: geometry)
                        }
                    }
                }
            )
        }
    }
}

struct FBTeamStatsListItem: View {
    @Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let stats: FBTeamStats
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbTeamStatsStore: StoreOf<FBTeamStatsStore>,
        stats: FBTeamStats,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.stats = stats
        self.isAniItem = isAniItem
        
        if isAniItem {
            self.itemSize = itemSize
            self.itemOffset = itemOffset
            self.showContents = showContents
        } else {
            self.itemSize = nil
            self.itemOffset = nil
            self.showContents = true
        }
    }
    
    var body: some View {
        MovingCapsuleItemContainer(
            isButton: false,
            isAniItem: isAniItem,
            itemOffset: itemOffset,
        ) {
            FBTeamStatsItem(stats: stats)
                .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct FBTeamStatsItem: View {
    let stats: FBTeamStats
    
    @State private var isBasicStatsOpened = true
    @State private var isAttackStatsOpened = false
    @State private var isDefendStatsOpened = false
    
    var body: some View {
        // league / team
        LeagueTitle(
            url: stats.league.logo,
            leagueName: stats.league.name,
            leagueSeason: stats.league.season
        )
        
        // stats
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isBasicStatsOpened.toggle()
            }
        }) {
            Text("기본 기록")
            
            Image(systemName: "chevron.\(isBasicStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isBasicStatsOpened {
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: "\(stats.fixtures.played.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "승",
                    data: "\(stats.fixtures.wins.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "무",
                    data: "\(stats.fixtures.draws.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "패",
                    data: "\(stats.fixtures.loses.total)"
                )
                .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isAttackStatsOpened.toggle()
            }
        }) {
            Text("공격 기록")
            
            Image(systemName: "chevron.\(isAttackStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isAttackStatsOpened {
            HStack {
                FBStatDataItem(
                    category: "득점",
                    data: "\(stats.goals.teamGoalsFor.total.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 평균득점",
                    data: "\(stats.goals.teamGoalsFor.average.total)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "득실차",
                    data: "\(stats.goals.teamGoalsFor.total.total - stats.goals.teamGoalsAgainst.total.total)",
                )
                .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isDefendStatsOpened.toggle()
            }
        }) {
            Text("수비 기록")
            
            Image(systemName: "chevron.\(isDefendStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isDefendStatsOpened {
            HStack {
                FBStatDataItem(
                    category: "실점",
                    data: "\(stats.goals.teamGoalsAgainst.total.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경기당 평균실점",
                    data: "\(stats.goals.teamGoalsAgainst.average.total)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "클린시트",
                    data: "\(stats.cleanSheet?.total ?? 0)",
                    customWidth: 70
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}
