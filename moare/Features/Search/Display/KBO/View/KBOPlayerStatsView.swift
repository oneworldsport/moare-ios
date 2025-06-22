//
//  KBOPlayerStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOPlayerStatsView: View {
    /* ---------------------
     store
     --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: KBOPlayerStatsDisplayModel

    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let kboPlayerStatsStore {
                    InfoViewContainer(
                        itemCount: (kboPlayerStatsStore.baseStats.displayModel?.stats.count ?? 0) + 1,
                        measureContent: { scope in
                            KBOPlayerStatsPlayerInfoItem(kboPlayerStatsStore: kboPlayerStatsStore)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                            scope.updateItemFrame(index: 0, geometry: geometry)
                                        }
                                    }
                                )
                            
                            KBOPlayerStatsList(kboPlayerStatsStore: kboPlayerStatsStore) { index, geometry in
                                scope.updateItemFrame(index: index, geometry: geometry)
                            }
                            .frame(maxWidth: .infinity)
                        },
                        displayContent: { scope in
                            KBOPlayerStatsPlayerInfoItem(
                                kboPlayerStatsStore: kboPlayerStatsStore,
                                isAniItem: true,
                                itemOffset: scope.computedOffset(for: 0),
                                showContents: scope.showContents
                            )
                            KBOPlayerStatsList(
                                kboPlayerStatsStore: kboPlayerStatsStore,
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
                // init KBOPlayerStatsStore
                let kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore> = storeManager.getStore(forKey: StoreKeys.kboPlayerStatsStore) ?? {
                    let newStore = Store(initialState: KBOPlayerStatsStore.State()) { KBOPlayerStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboPlayerStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.kboPlayerStatsStore = kboPlayerStatsStore
                }
                
                if searchStore.poppedView == nil {
                    kboPlayerStatsStore.send(.baseStats(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .kboPlayerStats = searchStore.poppedView {
                    kboPlayerStatsStore?.send(.baseStats(.initData(displayModel: displayModel)))
                }
            }
        }
    }
}

struct KBOPlayerStatsPlayerInfoItem: View {
    @Bindable var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool

    init(
        kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.kboPlayerStatsStore = kboPlayerStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = kboPlayerStatsStore.baseStats.displayModel
        let player = displayModel?.player
        let playerNameDic = kboPlayerStatsStore.baseStats.playerNameDictionary
        let teamNameDic = kboPlayerStatsStore.baseStats.teamNameDictionary
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HCapsuleBar()
            
            HStack {
                URLImage(url: KBOUtil.playerPhotoURL(id: player?.id))
                
                VStack(alignment: .leading) {
                    Text(player?.name ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("소속팀: ")
                            .font(.system(size: 15))
                        
                        URLImage(url: KBOUtil.teamLogoURL(id: player?.teamId), customSize: CGSize(width: 24, height: 24))
                            .padding(.trailing, 6)
                        
                        Text(teamNameDic["full_\(player?.teamId ?? 0)"] ?? "")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                }
            }
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct KBOPlayerStatsList: View {
    @Bindable var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool
    
    let updateItemPosition: (Int, GeometryProxy) -> Void
    
    init(
        kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true,
        updateItemPosition: @escaping (Int, GeometryProxy) -> Void = { _, _ in }
    ) {
        self.kboPlayerStatsStore = kboPlayerStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
        self.updateItemPosition = updateItemPosition
    }
    
    var body: some View {
        if let stats = kboPlayerStatsStore.baseStats.displayModel?.stats {
            ForEach(stats.indices, id: \.self) { index in
                let data = stats[index]
                
                KBOPlayerStatsListItem(
                    kboPlayerStatsStore: kboPlayerStatsStore,
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

struct KBOPlayerStatsListItem: View {
    @Bindable var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>
    
    let data: KBOPlayerStats
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
            KBOPlayerStatsItem(
                kboPlayerStatsStore: kboPlayerStatsStore,
                data: data,
                showContents: showContents
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct KBOPlayerStatsItem: View {
    @Bindable var kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>
    
    let data: KBOPlayerStats
    let showContents: Bool

    init(
        kboPlayerStatsStore: StoreOf<KBOPlayerStatsStore>,
        data: KBOPlayerStats,
        showContents: Bool = true
    ) {
        self.kboPlayerStatsStore = kboPlayerStatsStore
        self.data = data
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = kboPlayerStatsStore.baseStats.displayModel

        HCapsuleBar()
        
        if let hitter = data.hitter {
            HStack {
                BaseballLeagueTitle(
                    logoUrl: KBOUtil.kboLogoUrl,
                    name: "KBO",
                    season: data.season
                )
                
                Text(" - [타자]")
                    .fontWeight(.medium)
            }
            .padding(.bottom, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: hitter.g,
                    customCategoryFontSize: 11,
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "타수",
                    data: hitter.ab,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "타율",
                    data: hitter.avg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "안타",
                    data: hitter.h,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "2루타",
                    data: hitter.double,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "3루타",
                    data: hitter.triple,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "홈런",
                    data: hitter.hr,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "출루율",
                    data: hitter.obp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "장타율",
                    data: hitter.slg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "ops",
                    data: hitter.ops,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "득점",
                    data: hitter.r,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "타점",
                    data: hitter.rbi,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "득점권 타율",
                    data: hitter.risp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "볼넷",
                    data: hitter.bb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "삼진",
                    data: hitter.so,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루",
                    data: hitter.sb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루 실패",
                    data: hitter.cs,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "도루 성공률",
                    data: hitter.sbPercent,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "멀티히트",
                    data: hitter.mh,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "사구",
                    data: hitter.hbp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "희생번트",
                    data: hitter.sac,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "희생플라이",
                    data: hitter.sf,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "병살타",
                    data: hitter.gdp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "대타 타율",
                    data: hitter.phBa,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
        } // if let hitter
        
        if let pitcher = data.pitcher {
            HStack {
                BaseballLeagueTitle(
                    logoUrl: KBOUtil.kboLogoUrl,
                    name: "KBO",
                    season: data.season
                )
                
                Text(" - [투수]")
                    .fontWeight(.medium)
            }
            .padding(.bottom, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: pitcher.g,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "이닝",
                    data: pitcher.ip,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "평균자책",
                    data: pitcher.era,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "승",
                    data: pitcher.w,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "패",
                    data: pitcher.l,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "홀드",
                    data: pitcher.hld,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "세이브",
                    data: pitcher.sv,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "삼진",
                    data: pitcher.h,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "볼넷",
                    data: pitcher.bb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "피안타",
                    data: pitcher.h,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "피2루타",
                    data: pitcher.double,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "피3루타",
                    data: pitcher.triple,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "피홈런",
                    data: pitcher.hr,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "피안타율",
                    data: pitcher.avg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "실점",
                    data: pitcher.r,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "자책점",
                    data: pitcher.er,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "블론세이브",
                    data: pitcher.bsv,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "보크",
                    data: pitcher.bk,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "고의4구",
                    data: pitcher.ibb,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "폭투",
                    data: pitcher.wp,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "완투",
                    data: pitcher.cg,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "완봉",
                    data: pitcher.sho,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "투구수",
                    data: pitcher.np,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "퀄리티 스타트",
                    data: pitcher.qs,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "이닝당 출루허용률",
                    data: pitcher.whip,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "승률",
                    data: pitcher.wpct,
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "",
                    data: "",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "",
                    data: "",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "",
                    data: "",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                FBStatDataItem(
                    category: "",
                    data: "",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
        } // if let hitter
    }
}
