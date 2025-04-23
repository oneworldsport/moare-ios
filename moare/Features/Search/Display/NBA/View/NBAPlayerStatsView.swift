//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBAPlayerStatsDisplayModel
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "NBAPlayerStatsView"
    
    @State private var firstItemPosition: CGPoint = .zero
    @State private var itemPositions: [Int: CGPoint] = [:]
    
    @State private var animatePositions = false
    @State private var showContents = false
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let nbaPlayerStatsStore {
                    ZStack(alignment: .topLeading) {
                        /* ---------------------
                           invisible ui
                           - for position
                           --------------------- */
                        VStack {
                            // player info
                            NBAPlayerStatsPlayerInfoItem(nbaPlayerStatsStore: nbaPlayerStatsStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            firstItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        }
                                    }
                                )
                            
                            // stats list
                            NBAPlayerStatsList(nbaPlayerStatsStore: nbaPlayerStatsStore, itemPositions: $itemPositions)
                        }
                        .opacity(0)
                        
                        /* ---------------------
                           visible ui
                           - with animation effect
                           --------------------- */
                        NBAPlayerStatsPlayerInfoItem(nbaPlayerStatsStore: nbaPlayerStatsStore, showContents: showContents)
                            .offset(
                                x: 0,
                                y: animatePositions ? firstItemPosition.y : centerPosition.height
                            )
                        
                        NBAPlayerStatsList(
                            nbaPlayerStatsStore: nbaPlayerStatsStore,
                            animatePositions: animatePositions,
                            showContents: showContents,
                            isAniList: true,
                            itemPositions: $itemPositions
                        )
                    } // ZStack
                    .coordinateSpace(name: coordinateSpaceName)
                } // if let nbaPlayerStatsStore
            } // ScrollView
            .padding(.top, 6)
            .onAppear {
                // init NBAPlayerStatsStore
                let nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore> = storeManager.getStore(forKey: StoreKeys.nbaPlayerStatsStore) ?? {
                    let newStore = Store(initialState: NBAPlayerStatsStore.State()) { NBAPlayerStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaPlayerStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.nbaPlayerStatsStore = nbaPlayerStatsStore
                }
                
                if searchStore.poppedView == nil {
                    nbaPlayerStatsStore.send(.initData(displayModel: displayModel))
                }
                
                triggerAnimation()
            }
            .onChange(of: displayModel) {
                if case .nbaPlayerStats = searchStore.poppedView {
                    nbaPlayerStatsStore?.send(.initData(displayModel: displayModel))
                }
            }
        }
    }
    
    private func triggerAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.short) {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                animatePositions = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.short + AnimationConstants.Duration.medium) {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                showContents = true
            }
        }
    }
}

struct NBAPlayerStatsPlayerInfoItem: View {
    @Bindable var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>
    
    let showContents: Bool

    init(nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>, showContents: Bool = true) {
        self.nbaPlayerStatsStore = nbaPlayerStatsStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerStatsStore.displayModel
        
        if let player = displayModel?.player {
            VStack(spacing: UIConstants.Padding.defaultHPadding) {
                HCapsuleBar()
                
                HStack {
                    URLImage(url: NBAUtil.playerPhotoURL(id: player.personId))
                    
                    // name
                    VStack(alignment: .leading) {
                        Text(nbaPlayerStatsStore.playerNameDictionary[player.displayFirstLast.lowercased()] ?? player.displayFirstLast)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                        
                        Text(player.displayFirstLast)
                            .font(.system(size: 15))
                            .fontWeight(.light)
                            .lineLimit(2)
                        
                        HStack {
                            Text("국적: ")
                                .font(.system(size: 15))
                            
                            Text(player.country)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                    
                    URLImage(url: NBAUtil.teamLogoURL(id: player.teamId), isSvg: true)
                    
                    // nationality, team, jersey, position
                    VStack(alignment: .leading) {
                        Text(nbaPlayerStatsStore.teamNameDictionary["full_\(player.teamId)"] ?? "\(player.teamCity) \(player.teamName)")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                        
                        HStack(spacing: 0) {
                            Text("등번호: ")
                                .font(.system(size: 15))
                            
                            Text(player.jersey)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 0) {
                            Text("포지션: ")
                                .font(.system(size: 15))
                            
                            Text(player.position)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
                .opacity(showContents ? 1 : 0)
            } // VStack
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        } // if let player
    }
}

struct NBAPlayerStatsList: View {
    @Bindable var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>
    
    let animatePositions: Bool
    let showContents: Bool
    let isAniList: Bool
    
    @Binding var itemPositions: [Int : CGPoint]
    
    init(
        nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>,
        animatePositions: Bool = true,
        showContents: Bool = true,
        isAniList: Bool = false,
        itemPositions: Binding<[Int: CGPoint]>
    ) {
        self.nbaPlayerStatsStore = nbaPlayerStatsStore
        self.animatePositions = animatePositions
        self.showContents = showContents
        self.isAniList = isAniList
        self._itemPositions = itemPositions
    }
    
    var body: some View {
        if let statsList = nbaPlayerStatsStore.displayModel?.stats {
            ForEach(statsList.indices, id: \.self) { index in
                let stats = statsList[index]
                
                NBAPlayerStatsListItem(
                    nbaPlayerStatsStore: nbaPlayerStatsStore,
                    stats: stats,
                    index: index,
                    animatePositions: animatePositions,
                    showContents: showContents,
                    isAniList: isAniList,
                    itemPositions: $itemPositions
                )
            }
        }
    }
}

struct NBAPlayerStatsListItem: View {
    @Bindable var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>
    
    let stats: NBAPlayerStats
    let index: Int
    let animatePositions: Bool
    let showContents: Bool
    let isAniList: Bool
    
    @Binding var itemPositions: [Int : CGPoint]
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        NBAPlayerStatsItem(
            nbaPlayerStatsStore: nbaPlayerStatsStore,
            stats: stats,
            showContents: showContents
        )
        .background(
            GeometryReader { proxy in
                if !isAniList {
                    Color.clear.onAppear {
                        itemPositions[index] = proxy.frame(in: .named("NBAPlayerStatsView")).origin
                    }
                }
            }
        )
        .offset(
            x: 0,
            y: isAniList ? (animatePositions ? (itemPositions[index]?.y ?? 0) : centerPosition.height) : 0
        )
    }
}

struct NBAPlayerStatsItem: View {
    @Bindable var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>
    
    let stats: NBAPlayerStats
    let showContents: Bool

    init(nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>, stats: NBAPlayerStats, showContents: Bool = true) {
        self.nbaPlayerStatsStore = nbaPlayerStatsStore
        self.stats = stats
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            // league
            NBATitle(
                leagueName: "NBA 정규시즌",
                leagueSeason: Int(stats.groupValue.split(separator: "-").first ?? "2024")!
            )
            .padding(.bottom, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: "\(stats.gp)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 득점",
                    data: "\(stats.ptsPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 리바운드",
                    data: "\(stats.rebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 수비 리바운드",
                    data: "\(stats.drebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 공격 리바운드",
                    data: "\(stats.orebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 어시스트",
                    data: "\(stats.astPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "경기당 블록",
                    data: "\(stats.gp)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 스틸",
                    data: "\(stats.ptsPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 턴오버",
                    data: "\(stats.rebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 야투 시도",
                    data: "\(stats.drebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 야투 성공",
                    data: "\(stats.orebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "야투 성공률",
                    data: "\(stats.astPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "경기당 3점 시도",
                    data: "\(stats.gp)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 3점 성공",
                    data: "\(stats.ptsPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "3점 성공률",
                    data: "\(stats.rebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 자유투 시도",
                    data: "\(stats.drebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 자유투 성공",
                    data: "\(stats.orebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "자유투 성공률",
                    data: "\(stats.astPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "경기당 파울",
                    data: "\(stats.gp)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 파울 유도",
                    data: "\(stats.ptsPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 득실마진",
                    data: "\(stats.rebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 피블록",
                    data: "\(stats.drebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "더블더블",
                    data: "\(stats.orebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "트리플더블",
                    data: "\(stats.astPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "(출전 경기)승",
                    data: "\(stats.gp)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "(출전 경기)패",
                    data: "\(stats.ptsPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 출전시간",
                    data: "\(stats.rebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "(출전 경기)승률",
                    data: "\(stats.drebPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "",
                    data: "\(stats.orebPG)"
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "",
                    data: "\(stats.astPG)"
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}
