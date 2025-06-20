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
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "FBTeamStatsView"
    
    @State private var firstItemPosition: CGPoint = .zero
    @State private var itemPositions: [Int: CGPoint] = [:]
    
    @State private var animatePositions = false
    @State private var showContents = false
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let fbTeamStatsStore {
                    ZStack(alignment: .topLeading) {
//                        Spacer() // empty space for smooth animation effect
//                            .frame(maxWidth: .infinity, maxHeight: 0)
                        
                        /* ---------------------
                           invisible ui
                           - for position
                           --------------------- */
                        VStack {
                            // team info
                            FBTeamStatsTeamInfoItem(fbTeamStatsStore: fbTeamStatsStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            firstItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        }
                                    }
                                )
                            
                            // stats list
                            FBTeamStatsList(fbTeamStatsStore: fbTeamStatsStore, itemPositions: $itemPositions)
                        }
                        .opacity(0)
                        
                        /* ---------------------
                           visible ui
                           - with animation effect
                           --------------------- */
                        FBTeamStatsTeamInfoItem(fbTeamStatsStore: fbTeamStatsStore, showContents: showContents)
                            .offset(
                                x: 0,
                                y: animatePositions ? firstItemPosition.y : centerPosition.height
                            )
                        
                        FBTeamStatsList(
                            fbTeamStatsStore: fbTeamStatsStore,
                            animatePositions: animatePositions,
                            showContents: showContents,
                            isAniList: true,
                            itemPositions: $itemPositions
                        )
                    } // ZStack
                    .coordinateSpace(name: coordinateSpaceName)
                } // if let fbTeamStatsStore
            } // ScrollView
            .padding(.top, 6)
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
                
                triggerAnimation()
            }
            .onChange(of: displayModel) {
                if case .fbTeamStats = searchStore.poppedView {
                    fbTeamStatsStore?.send(.initData(displayModel: displayModel))
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

struct FBTeamStatsTeamInfoItem: View {
    @Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let showContents: Bool
    
    init(fbTeamStatsStore: StoreOf<FBTeamStatsStore>, showContents: Bool = true) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbTeamStatsStore.teamNameDictionary
        
        if let team = fbTeamStatsStore.team, let venue = fbTeamStatsStore.venue {
            VStack {
                HCapsuleBar()
                
                HStack(spacing: 8) {
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
                        HStack(spacing: 0) {
                            Text("연고지: ")
                                .font(.system(size: 15))
                            
                            Text(venue.city)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 0) {
                            Text("홈구장: ")
                                .font(.system(size: 15))
                            
                            Text(venue.name)
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

struct FBTeamStatsList: View {
    @Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let animatePositions: Bool
    let showContents: Bool
    let isAniList: Bool
    
    @Binding var itemPositions: [Int : CGPoint]

    init(
        fbTeamStatsStore: StoreOf<FBTeamStatsStore>,
        animatePositions: Bool = true,
        showContents: Bool = true,
        isAniList: Bool = false,
        itemPositions: Binding<[Int: CGPoint]>
    ) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.animatePositions = animatePositions
        self.showContents = showContents
        self.isAniList = isAniList
        self._itemPositions = itemPositions
    }
    
    var body: some View {
        ForEach(fbTeamStatsStore.statsList.indices, id: \.self) { index in
            let stats = fbTeamStatsStore.statsList[index]
            
            FBTeamStatsListItem(
                fbTeamStatsStore: fbTeamStatsStore,
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

struct FBTeamStatsListItem: View {
    @Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let stats: FBTeamStats
    let index: Int
    let animatePositions: Bool
    let showContents: Bool
    let isAniList: Bool
    
    @Binding var itemPositions: [Int : CGPoint]
    
    var centerPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    var body: some View {
        FBTeamStatsItem(stats: stats, showContents: showContents)
            .background(
                GeometryReader { proxy in
                    if !isAniList {
                        // NOTE: InfoView에서는 onChange로 하였는데, 여기서는 onAppear로만 해도 문제가 없어보임. 정확한 원인은 더 리서치 해야함.
                        Color.clear
                            .onAppear {
                                itemPositions[index] = proxy.frame(in: .named("FBTeamStatsView")).origin
                            }
//                            .onChange(of: proxy.frame(in: .named("FBTeamStatsView")).origin) {
//                                itemPositions[index] = proxy.frame(in: .named("FBTeamStatsView")).origin
//                            }
                    }
                }
            )
            .offset(
                x: 0,
                y: isAniList ? (animatePositions ? (itemPositions[index]?.y ?? 0) : centerPosition.height) : 0
            )
    }
}

struct FBTeamStatsItem: View {
    let stats: FBTeamStats
    let showContents: Bool
    
    init(stats: FBTeamStats, showContents: Bool = true) {
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
                
//                Text(" - ")
//                    .fontWeight(.medium)
//                
//                URLImage(url: stats.team.logo, customSize: CGSize(width: 24, height: 24))
//                
//                Text(EnNameTranslationUtility.translateByDic(type: .team, input: stats.team.name))
//                    .font(.system(size: 16))
//                    .fontWeight(.medium)
            }
            .padding(.bottom, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            // stats
            HStack {
                FBStatDataItem(
                    category: "경기수",
                    data: "\(stats.fixtures.played.total)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "승",
                    data: "\(stats.fixtures.wins.total)",
                    customWidth: 80
                )
                
                FBStatDataItem(
                    category: "무",
                    data: "\(stats.fixtures.draws.total)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "패",
                    data: "\(stats.fixtures.loses.total)",
                    customWidth: 80
                )
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "득점",
                    data: "\(stats.goals.teamGoalsFor.total.total)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "경기당 평균득점",
                    data: "\(stats.goals.teamGoalsFor.average.total)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
                
                FBStatDataItem(
                    category: "실점",
                    data: "\(stats.goals.teamGoalsAgainst.total.total)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "경기당 평균실점",
                    data: "\(stats.goals.teamGoalsAgainst.average.total)",
                    customCategoryFontSize: 11,
                    customWidth: 80
                )
            }
            .opacity(showContents ? 1 : 0)
            
            HStack {
                FBStatDataItem(
                    category: "득실차",
                    data: "\(stats.goals.teamGoalsFor.total.total - stats.goals.teamGoalsAgainst.total.total)",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "클린시트",
                    data: "\(stats.cleanSheet?.total ?? 0)",
                    customWidth: 80
                )
                
                FBStatDataItem(
                    category: "홈성적",
                    data: "",
                    customWidth: 70
                )
                
                FBStatDataItem(
                    category: "원정성적",
                    data: "",
                    customWidth: 80
                )
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

//#Preview {
//    FBTeamStatsView()
//}
