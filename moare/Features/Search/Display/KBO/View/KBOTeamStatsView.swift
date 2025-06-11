//
//  KBOTeamStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTeamStatsView: View {
    /* ---------------------
     store
     --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: KBOTeamStatsDisplayModel

    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let kboTeamStatsStore {
                    InfoViewContainer(
                        itemCount: (kboTeamStatsStore.baseStats.displayModel?.stats.count ?? 0) + 1,
                        measureContent: { scope in
                            KBOTeamStatsPlayerInfoItem(kboTeamStatsStore: kboTeamStatsStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            KBOTeamStatsList(kboTeamStatsStore: kboTeamStatsStore) { index, geometry in
                                scope.updateItemFrame(index: index, geometry: geometry)
                            }
                            .frame(maxWidth: .infinity)
                        },
                        displayContent: { scope in
                            KBOTeamStatsPlayerInfoItem(
                                kboTeamStatsStore: kboTeamStatsStore,
                                isAniItem: true,
                                itemOffset: scope.computedOffset(for: 0),
                                showContents: scope.showContents
                            )
                            KBOTeamStatsList(
                                kboTeamStatsStore: kboTeamStatsStore,
                                isAniItem: true,
                                itemOffset: scope.computedOffset(for: 1),
                                showContents: scope.showContents
                            )
                        }
                    )
                }
            } // ScrollView
            .padding(.top, 6)
            .onAppear {
                // init KBOTeamStatsStore
                let kboTeamStatsStore: StoreOf<KBOTeamStatsStore> = storeManager.getStore(forKey: StoreKeys.kboTeamStatsStore) ?? {
                    let newStore = Store(initialState: KBOTeamStatsStore.State()) { KBOTeamStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboTeamStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.kboTeamStatsStore = kboTeamStatsStore
                }
                
                if searchStore.poppedView == nil {
                    kboTeamStatsStore.send(.baseStats(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .kboPlayerStats = searchStore.poppedView {
                    kboTeamStatsStore?.send(.baseStats(.initData(displayModel: displayModel)))
                }
            }
        }
    }
}

struct KBOTeamStatsPlayerInfoItem: View {
    @Bindable var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool

    init(
        kboTeamStatsStore: StoreOf<KBOTeamStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboTeamStatsStore = kboTeamStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = kboTeamStatsStore.baseStats.displayModel
        let playerNameDic = kboTeamStatsStore.baseStats.playerNameDictionary
        let teamNameDic = kboTeamStatsStore.baseStats.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HCapsuleBar()
            
            if let team = displayModel?.team {
                HStack {
                    URLImage(url: KBOUtil.teamLogoURL(id: team.id), isSvg: true)
                    
                    // name, city
                    VStack(alignment: .leading) {
                        Text(teamNameDic["full_\(team.id)"] ?? team.teamName)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                        
                        HStack(spacing: 0) {
                            Text("연고지: ")
                                .font(.system(size: 15))
                            
                            Text(team.city)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 0) {
                            Text("홈구장: ")
                                .font(.system(size: 15))
                            
                            Text(teamNameDic["venue_\(team.id)"] ?? (displayModel?.venue.name ?? ""))
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct KBOTeamStatsList: View {
    @Bindable var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool
    
    let updateItemPosition: (Int, GeometryProxy) -> Void
    
    init(
        kboTeamStatsStore: StoreOf<KBOTeamStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true,
        updateItemPosition: @escaping (Int, GeometryProxy) -> Void = { _, _ in }
    ) {
        self.kboTeamStatsStore = kboTeamStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
        self.updateItemPosition = updateItemPosition
    }
    
    var body: some View {
        if let stats = kboTeamStatsStore.baseStats.displayModel?.stats {
            ForEach(stats.indices, id: \.self) { index in
                let data = stats[index]
                
                KBOTeamStatsListItem(
                    kboTeamStatsStore: kboTeamStatsStore,
                    data: data,
                    index: index,
                    isAniItem: isAniItem,
                    itemOffset: itemOffset,
                    showContents: showContents,
                    updateItemPosition: updateItemPosition
                )
            }
        }
    }
}

struct KBOTeamStatsListItem: View {
    @Bindable var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>
    
    let data: KBOTeamStats
    let index: Int
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool
    
    let updateItemPosition: (Int, GeometryProxy) -> Void
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset,
            updateItemPosition: { geometry in
                updateItemPosition(index + 1, geometry)
            }
        ) {
            KBOTeamStatsItem(
                kboTeamStatsStore: kboTeamStatsStore,
                data: data,
                showContents: showContents
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct KBOTeamStatsItem: View {
    @Bindable var kboTeamStatsStore: StoreOf<KBOTeamStatsStore>
    
    let data: KBOTeamStats
    let showContents: Bool

    init(
        kboTeamStatsStore: StoreOf<KBOTeamStatsStore>,
        data: KBOTeamStats,
        showContents: Bool = true
    ) {
        self.kboTeamStatsStore = kboTeamStatsStore
        self.data = data
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = kboTeamStatsStore.baseStats.displayModel
        let rank = data.rankData
        let hitting = data.hitterData
        let pitching = data.pitcherData
        let running = data.runnerData

        HCapsuleBar()
        
        BaseballLeagueTitle(
            logoUrl: KBOUtil.kboLogoUrl,
            name: "KBO",
            season: data.season
        )
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
        .opacity(showContents ? 1 : 0)
        
        // stats
        HStack {
            FBStatDataItem(
                category: "순위",
                data: rank.rank,
                customCategoryFontSize: 11,
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "승",
                data: rank.wins,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "패",
                data: rank.losses,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "경기수",
                data: rank.gp,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "게임차",
                data: rank.gb,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "승률",
                data: rank.winpct,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
        }
        .opacity(showContents ? 1 : 0)
        
        HStack {
            FBStatDataItem(
                category: "타율",
                data: hitting.avg,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "안타",
                data: hitting.h,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "홈런",
                data: hitting.hr,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "출루율",
                data: hitting.obp,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "장타율",
                data: hitting.slg,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "ops",
                data: hitting.ops,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
        }
        .opacity(showContents ? 1 : 0)
        
        HStack {
            FBStatDataItem(
                category: "득점권타율",
                data: hitting.risp,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "사구-[타자]",
                data: hitting.hbp,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "병살타",
                data: hitting.gdp,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "득점",
                data: hitting.r,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "타점",
                data: hitting.rbi,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "삼진-[타자]",
                data: hitting.so,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
        }
        .opacity(showContents ? 1 : 0)
        
        HStack {
            FBStatDataItem(
                category: "피안타율",
                data: pitching.avg,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "피안타",
                data: pitching.h,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "피홈런",
                data: pitching.hr,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "평균자책점",
                data: pitching.era,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "세이브",
                data: pitching.sv,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "블론세이브",
                data: pitching.bsv,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
        }
        .opacity(showContents ? 1 : 0)
        
        HStack {
            FBStatDataItem(
                category: "볼넷-[투수]",
                data: pitching.bb,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "보크",
                data: pitching.bk,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "홀드",
                data: pitching.hld,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "이닝당 출루허용률",
                data: pitching.whip,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "도루성공",
                data: running.sb,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
            FBStatDataItem(
                category: "도루실패",
                data: running.cs,
                customCategoryFontSize: 11
            )
            .frame(maxWidth: .infinity)
        }
        .opacity(showContents ? 1 : 0)
    }
}
