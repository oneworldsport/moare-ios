//
//  FBPlayerStatsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import SwiftUI
import ComposableArchitecture

struct FBPlayerStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBPlayerStatsDisplayModel
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "FBPlayerStatsView"
    
    @State private var firstItemPosition: CGPoint = .zero
    @State private var itemPositions: [Int: CGPoint] = [:]
    
    @State private var animatePositions = false
    @State private var showContents = false
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let fbPlayerStatsStore {
                    // NOTE: Item's position is based on top left corner
                    ZStack(alignment: .topLeading) {
//                        Spacer() // empty space for smooth animation effect
//                            .frame(maxWidth: .infinity, maxHeight: 0)
                        
                        /* ---------------------
                           invisible ui
                           - for position
                           --------------------- */
                        VStack {
                            // player info
                            FBPlayerStatsPlayerInfoItem(fbPlayerStatsStore: fbPlayerStatsStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            firstItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        }
                                    }
                                )
                            
                            // stats list
                            FBPlayerStatsList(fbPlayerStatsStore: fbPlayerStatsStore, itemPositions: $itemPositions)
                        }
                        .opacity(0)
                        
                        /* ---------------------
                           visible ui
                           - with animation effect
                           --------------------- */
                        FBPlayerStatsPlayerInfoItem(fbPlayerStatsStore: fbPlayerStatsStore, showContents: showContents)
                            .offset(
                                x: 0,
                                y: animatePositions ? firstItemPosition.y : centerPosition.height
                            )
                        
                        FBPlayerStatsList(
                            fbPlayerStatsStore: fbPlayerStatsStore,
                            animatePositions: animatePositions,
                            showContents: showContents,
                            isAniList: true,
                            itemPositions: $itemPositions
                        )
                    } // ZStack
                    .coordinateSpace(name: coordinateSpaceName)
                } // if let fbPlayerStatsStore
            } // ScrollView
            .onAppear {
                // init FBPlayerStatsStore
                let fbPlayerStatsStore: StoreOf<FBPlayerStatsStore> = storeManager.getStore(forKey: StoreKeys.fbPlayerStatsStore) ?? {
                    let newStore = Store(initialState: FBPlayerStatsStore.State()) { FBPlayerStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbPlayerStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.fbPlayerStatsStore = fbPlayerStatsStore
                }
                
                if searchStore.poppedView == nil {
                    fbPlayerStatsStore.send(.initData(displayModel: displayModel))
                }
                
                triggerAnimation()
            }
            .onChange(of: displayModel) {
                if case .fbPlayerStats = searchStore.poppedView {
                    fbPlayerStatsStore?.send(.initData(displayModel: displayModel))
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

struct FBPlayerStatsPlayerInfoItem: View {
    @Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let showContents: Bool

    init(fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>, showContents: Bool = true) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.showContents = showContents
    }
    
    var body: some View {
        let player = fbPlayerStatsStore.player
        
        VStack(spacing: UIConstants.Padding.defaultHPadding) {
            HCapsuleBar()
            
            HStack {
                URLImage(url: player?.photo)
                
                VStack(alignment: .leading) {
                    Text("\(player?.krname ?? "")")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    Text("\(player?.name ?? "")")
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .lineLimit(2)
                }
                
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("국적: ")
                            .font(.system(size: 15))
                            
                        Text(fbPlayerStatsStore.nationalityKrName)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                    
                    if let team = fbPlayerStatsStore.team {
                        HStack(spacing: 0) {
                            Text("소속팀: ")
                                .font(.system(size: 15))
                            
                            URLImage(url: team.logo, customSize: CGSize(width: 24, height: 24))
                                .padding(.trailing, 6)
                            
                            Text(EnNameTranslationUtility.translateByDic(type: .team, input: team.name))
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBPlayerStatsList: View {
    @Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let animatePositions: Bool
    let showContents: Bool
    let isAniList: Bool
    
    @Binding var itemPositions: [Int : CGPoint]
    
    init(
        fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>,
        animatePositions: Bool = true,
        showContents: Bool = true,
        isAniList: Bool = false,
        itemPositions: Binding<[Int: CGPoint]>
    ) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.animatePositions = animatePositions
        self.showContents = showContents
        self.isAniList = isAniList
        self._itemPositions = itemPositions
    }
    
    var body: some View {
        ForEach(fbPlayerStatsStore.statsList.indices, id: \.self) { index in
            let stats = fbPlayerStatsStore.statsList[index]
            
            FBPlayerStatsListItem(
                fbPlayerStatsStore: fbPlayerStatsStore,
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

struct FBPlayerStatsListItem: View {
    @Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let stats: FBPlayerStats
    let index: Int
    let animatePositions: Bool
    let showContents: Bool
    let isAniList: Bool
    
    @Binding var itemPositions: [Int : CGPoint]
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        FBPlayerStatsItem(
            fbPlayerStatsStore: fbPlayerStatsStore,
            stats: stats,
            showContents: showContents
        )
        .background(
            GeometryReader { proxy in
                if !isAniList {
                    Color.clear.onAppear {
                        itemPositions[index] = proxy.frame(in: .named("FBPlayerStatsView")).origin
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

struct FBPlayerStatsItem: View {
    @Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let stats: FBPlayerStats
    let showContents: Bool

    init(fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>, stats: FBPlayerStats, showContents: Bool = true) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.stats = stats
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            // league / team
            HStack {
                LeagueTitle(
                    url: stats.league.logo,
                    leagueName: stats.league.name,
                    leagueSeason: stats.league.season
                )
                
                Text(" - ")
                    .fontWeight(.medium)
                
                URLImage(url: stats.team.logo, customSize: CGSize(width: 24, height: 24))
                
                Text(EnNameTranslationUtility.translateByDic(type: .team, input: stats.team.name))
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .padding(.bottom, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "출전 경기수",
                    data: "\(stats.games.appearences)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "평균 평점",
                    data: "\(stats.games.rating.prefix(3))",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "골",
                    data: "\(stats.goals.total)"
                )
                
                FBStatDataItem(
                    category: "패널티 골",
                    data: "\(stats.penalty.scored)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "도움",
                    data: "\(stats.goals.assists)",
                    customWidth: 70
                )
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "슈팅",
                    data: "\(stats.shots.total)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "유효 슈팅",
                    data: "\(stats.shots.on)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "패스",
                    data: "\(stats.passes.total)"
                )
                
                FBStatDataItem(
                    category: "태클",
                    data: "\(stats.tackles.total)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "드리블",
                    data: "\(stats.dribbles.attempts)",
                    customWidth: 70
                )
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "파울",
                    data: "\(stats.fouls.committed)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "경고",
                    data: "\(stats.cards.yellow)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "퇴장",
                    data: "\(stats.cards.red)"
                )
                
                FBStatDataItem(
                    category: "",
                    data: "",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "",
                    data: "",
                    customWidth: 70
                )
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}
