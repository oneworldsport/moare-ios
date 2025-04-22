//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTeamStatsStore: StoreOf<NBATeamStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATeamStatsDisplayModel
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "NBATeamStatsView"
    
    @State private var firstItemPosition: CGPoint = .zero
    @State private var itemPositions: [Int: CGPoint] = [:]
    
    @State private var animatePositions = false
    @State private var showContents = false
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let nbaTeamStatsStore {
                    ZStack(alignment: .topLeading) {
                        /* ---------------------
                           invisible ui
                           - for position
                           --------------------- */
                        VStack {
                            // team info
                            NBATeamStatsTeamInfoItem(nbaTeamStatsStore: nbaTeamStatsStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            firstItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        }
                                    }
                                )
                            
                            // stats list
                            NBATeamStatsList(nbaTeamStatsStore: nbaTeamStatsStore, itemPositions: $itemPositions)
                        }
                        .opacity(0)
                        
                        /* ---------------------
                           visible ui
                           - with animation effect
                           --------------------- */
                        NBATeamStatsTeamInfoItem(nbaTeamStatsStore: nbaTeamStatsStore, showContents: showContents)
                            .offset(
                                x: 0,
                                y: animatePositions ? firstItemPosition.y : centerPosition.height
                            )
                        
                        NBATeamStatsList(
                            nbaTeamStatsStore: nbaTeamStatsStore,
                            animatePositions: animatePositions,
                            showContents: showContents,
                            isAniList: true,
                            itemPositions: $itemPositions
                        )
                    } // ZStack
                    .coordinateSpace(name: coordinateSpaceName)
                } // if let nbaTeamStatsStore
            } // ScrollView
            .onAppear {
                // init NBATeamStatsStore
                let nbaTeamStatsStore: StoreOf<NBATeamStatsStore> = storeManager.getStore(forKey: StoreKeys.nbaTeamStatsStore) ?? {
                    let newStore = Store(initialState: NBATeamStatsStore.State()) { NBATeamStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaTeamStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.nbaTeamStatsStore = nbaTeamStatsStore
                }
                
                if searchStore.poppedView == nil {
                    nbaTeamStatsStore.send(.initData(displayModel: displayModel))
                }
                
                triggerAnimation()
            }
            .onChange(of: displayModel) {
                if case .nbaTeamStats = searchStore.poppedView {
                    nbaTeamStatsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
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

struct NBATeamStatsTeamInfoItem: View {
    @Bindable var nbaTeamStatsStore: StoreOf<NBATeamStatsStore>
    
    let showContents: Bool
    
    init(nbaTeamStatsStore: StoreOf<NBATeamStatsStore>, showContents: Bool = true) {
        self.nbaTeamStatsStore = nbaTeamStatsStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaTeamStatsStore.displayModel
        let teamNameDic = nbaTeamStatsStore.teamNameDictionary
        
        if let team = displayModel?.team,
           let venue = displayModel?.venue {
            VStack {
                HCapsuleBar()
                
                HStack(spacing: 8) {
                    URLImage(url: NBAUtil.teamLogoURL(id: team.id), isSvg: true)
                    
                    // name, state and city
                    VStack(alignment: .leading) {
                        Text(teamNameDic["full_\(team.id)"] ?? team.fullName)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                        
                        Text(team.fullName)
                            .font(.system(size: 15))
                            .fontWeight(.light)
                            .lineLimit(2)
                    }
                    
                    // venue, conference, division
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 0) {
                            Text("홈구장: ")
                                .font(.system(size: 15))
                            
                            Text(teamNameDic["venue_\(team.id)"] ?? venue.name)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 0) {
                            Text("컨퍼런스: ")
                                .font(.system(size: 15))
                            
                            Text(NBAUtil.translateEastWest(input: team.teamConference))
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 0) {
                            Text("디비전: ")
                                .font(.system(size: 15))
                            
                            Text(team.teamDivision)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
                .opacity(showContents ? 1 : 0)
            } // VStack
            .frame(maxWidth: .infinity)
            .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        }
    }
}

struct NBATeamStatsList: View {
    @Bindable var nbaTeamStatsStore: StoreOf<NBATeamStatsStore>
    
    let animatePositions: Bool
    let showContents: Bool
    let isAniList: Bool
    
    @Binding var itemPositions: [Int : CGPoint]

    init(
        nbaTeamStatsStore: StoreOf<NBATeamStatsStore>,
        animatePositions: Bool = true,
        showContents: Bool = true,
        isAniList: Bool = false,
        itemPositions: Binding<[Int: CGPoint]>
    ) {
        self.nbaTeamStatsStore = nbaTeamStatsStore
        self.animatePositions = animatePositions
        self.showContents = showContents
        self.isAniList = isAniList
        self._itemPositions = itemPositions
    }
    
    var body: some View {
        if let statsList = nbaTeamStatsStore.displayModel?.stats {
            ForEach(statsList.indices, id: \.self) { index in
                let stats = statsList[index]
                
                NBATeamStatsListItem(
                    nbaTeamStatsStore: nbaTeamStatsStore,
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

struct NBATeamStatsListItem: View {
    @Bindable var nbaTeamStatsStore: StoreOf<NBATeamStatsStore>
    
    let stats: NBATeamStats
    let index: Int
    let animatePositions: Bool
    let showContents: Bool
    let isAniList: Bool
    
    @Binding var itemPositions: [Int : CGPoint]
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        NBATeamStatsItem(
            nbaTeamStatsStore: nbaTeamStatsStore,
            stats: stats,
            showContents: showContents
        )
            .background(
                GeometryReader { proxy in
                    if !isAniList {
                        Color.clear.onAppear {
                            itemPositions[index] = proxy.frame(in: .named("NBATeamStatsView")).origin
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

struct NBATeamStatsItem: View {
    @Bindable var nbaTeamStatsStore: StoreOf<NBATeamStatsStore>
    
    let stats: NBATeamStats
    let showContents: Bool
    
    init(nbaTeamStatsStore: StoreOf<NBATeamStatsStore>, stats: NBATeamStats, showContents: Bool = true) {
        self.nbaTeamStatsStore = nbaTeamStatsStore
        self.stats = stats
        self.showContents = showContents
    }
    
    var body: some View {
        let team = nbaTeamStatsStore.displayModel?.team
        
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
                    category: "\(NBAUtil.translateEastWest(input: team?.teamConference ?? ""))컨퍼런스 순위",
                    data: "\(team?.confRank ?? 0)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "승",
                    data: "\(stats.wins)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "패",
                    data: "\(stats.losses)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기수",
                    data: "\(stats.gp)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "승률",
                    data: "\(stats.winsPct)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
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
                    data: "\(stats.blkPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 스틸",
                    data: "\(stats.stlPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 턴오버",
                    data: "\(stats.tovPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 파울",
                    data: "\(stats.pfPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 파울 유도",
                    data: "\(stats.pfdPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "경기당 야투 시도",
                    data: "\(stats.fgaPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 야투 성공",
                    data: "\(stats.fgmPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "야투 성공률",
                    data: "\(stats.fgPct)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 3점 시도",
                    data: "\(stats.fg3aPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 3점 성공",
                    data: "\(stats.fg3mPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "3점 성공률",
                    data: "\(stats.fg3Pct)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 자유투 시도",
                    data: "\(stats.ftaPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 자유투 성공",
                    data: "\(stats.ftmPG)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "자유투 성공률",
                    data: "\(stats.ftPct)",
                    customCategoryFontSize: 11
                )
                .frame(maxWidth: .infinity)
                
                FBStatDataItem(
                    category: "경기당 득실마진",
                    data: "\(stats.plusMinusPG)",
                    customCategoryFontSize: 11
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
