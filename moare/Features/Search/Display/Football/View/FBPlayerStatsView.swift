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
    let statsList: [FBPlayerStats]
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "FBPlayerStatsView"
    
    private var parentCenterPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    @State private var itemPositions: [Int: CGSize] = [:]
    @State private var animatePositions = false
    @State private var showContents = false
    
    @State private var mainUIVisibleState = false
    
    init(displayModel: FBPlayerStatsDisplayModel) {
        self.displayModel = displayModel
        self.statsList = displayModel.stats
    }
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let fbPlayerStatsStore = fbPlayerStatsStore {
                    ZStack(alignment: .topLeading) {
                        /* ---------------------
                         ui
                         - invisible first
                         - set ani ui's position
                         - visible after ani ui
                         --------------------- */
                        VStack {
                            FBPlayerStatsPlayerInfoItem(
                                fbPlayerStatsStore: fbPlayerStatsStore
                            )
                            .background(
                                GeometryReader { geometry in
                                    if itemPositions[0] == nil {
                                        Color.clear.preference(
                                            key: ItemPositionsPreferenceKey.self,
                                            value: [0: CGSize(
                                                width: geometry.frame(in: .named(coordinateSpaceName)).minX,
                                                height: geometry.frame(in: .named(coordinateSpaceName)).minY)]
                                        )
                                    }
                                }
                            )
                            
                            FBPlayerStatsList(fbPlayerStatsStore: fbPlayerStatsStore, itemPositions: itemPositions)
                        }
                        .opacity(mainUIVisibleState ? 1 : 0)
                        
                        /* ---------------------
                         aimation ui
                         - invisible after ani
                         --------------------- */
                        if !mainUIVisibleState {
                            FBPlayerStatsPlayerInfoItem(
                                fbPlayerStatsStore: fbPlayerStatsStore,
                                showContents: showContents
                            )
                            .offset(animatePositions ? itemPositions[0] ?? parentCenterPosition : parentCenterPosition)
                            
                            FBPlayerStatsAniList(
                                fbPlayerStatsStore: fbPlayerStatsStore,
                                itemPositions: itemPositions,
                                animatePositions: animatePositions,
                                showContents: showContents
                            )
                        }
                    } // ZStack
                } // if let fbPlayerStatsStore
            } // ScrollView
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(ItemPositionsPreferenceKey.self) { positions in
                self.itemPositions = positions
                
                if positions.count == statsList.count + 1 {
                    withAnimation(.spring(response: 1)) {
                        animatePositions = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showContents = true
                        }
                    }
                    
                    // make animation ui invisible after all animation ends
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        mainUIVisibleState = true
                    }
                }
            }
            .onAppear {
                // init FBPlayerStatsStore
                storeManager.setStore(
                    Store(initialState: FBPlayerStatsStore.State(
                        displayModel: displayModel,
                        statsList: statsList,
                        player: displayModel.player
                    )) { FBPlayerStatsStore() },
                    forKey: StoreKeys.fbPlayerStatsStore
                )
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    fbPlayerStatsStore = storeManager.getStore(forKey: StoreKeys.fbPlayerStatsStore)
                }
                
                fbPlayerStatsStore?.send(.initData)
            }
        }
    }
}

struct FBPlayerStatsPlayerInfoItem: View {
    @ComposableArchitecture.Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let showContents: Bool
    
    @State var teamKrName = ""

    init(fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>, showContents: Bool = true) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.showContents = showContents
    }
    
    var body: some View {
        let player = fbPlayerStatsStore.player
        
        VStack(spacing: UIConstants.Padding.defaultHPadding) {
            HCapsuleBar()
            
            HStack {
                URLImage(url: player.photo)
                
                VStack(alignment: .leading) {
                    Text("\(player.krname)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    Text("\(player.name)")
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
                            
                            Text(EnNameTranslationUtility.translateByDic(type: .team, input: teamKrName))
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .onAppear {
            translate()
        }
    }
    
    private func translate() {
        guard let team = fbPlayerStatsStore.team else { return }
        
        Task {
            let teamKrName = await EnNameTranslationUtility.translateByAWS(input: team.name)
            self.teamKrName = teamKrName
        }
    }
}

struct FBPlayerStatsList: View {
    @ComposableArchitecture.Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let itemPositions: [Int : CGSize]

    init(fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>, itemPositions: [Int : CGSize]) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.itemPositions = itemPositions
    }
    
    var body: some View {
        ForEach(fbPlayerStatsStore.statsList.indices, id: \.self) { index in
            let stats = fbPlayerStatsStore.statsList[index]
            
            FBPlayerStatsListItem(
                fbPlayerStatsStore: fbPlayerStatsStore,
                stats: stats,
                itemPositions: itemPositions,
                index: index
            )
        }
    }
}

struct FBPlayerStatsListItem: View {
    @ComposableArchitecture.Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let stats: FBPlayerStats
    let itemPositions: [Int : CGSize]
    let index: Int

    init(fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>, stats: FBPlayerStats, itemPositions: [Int : CGSize], index: Int) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.stats = stats
        self.itemPositions = itemPositions
        self.index = index
    }
    
    var body: some View {
        FBPlayerStatsItem(
            fbPlayerStatsStore: fbPlayerStatsStore,
            stats: stats
        )
        .background(
            GeometryReader { geometry in
                if itemPositions[index + 1] == nil {
                    Color.clear.preference(
                        key: ItemPositionsPreferenceKey.self,
                        value: [index + 1: CGSize(
                            width: geometry.frame(in: .named("FBPlayerStatsView")).minX,
                            height: geometry.frame(in: .named("FBPlayerStatsView")).minY)]
                    )
                }
            }
        )
    }
}

struct FBPlayerStatsAniList: View {
    @ComposableArchitecture.Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let itemPositions: [Int : CGSize]
    let animatePositions: Bool
    let showContents: Bool

    init(fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>, itemPositions: [Int : CGSize], animatePositions: Bool, showContents: Bool) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.itemPositions = itemPositions
        self.animatePositions = animatePositions
        self.showContents = showContents
    }
    
    var body: some View {
        ForEach(fbPlayerStatsStore.statsList.indices, id: \.self) { index in
            let stats = fbPlayerStatsStore.statsList[index]
            
            FBPlayerStatsAniListItem(
                fbPlayerStatsStore: fbPlayerStatsStore,
                stats: stats,
                index: index,
                itemPositions: itemPositions,
                animatePositions: animatePositions,
                showContents: showContents
            )
        }
    }
}

struct FBPlayerStatsAniListItem: View {
    @ComposableArchitecture.Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let stats: FBPlayerStats
    
    let index: Int
    let itemPositions: [Int : CGSize]
    let animatePositions: Bool
    let showContents: Bool
    
    private var parentCenterPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)

    init(fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>, stats: FBPlayerStats, index: Int, itemPositions: [Int : CGSize], animatePositions: Bool, showContents: Bool) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.stats = stats
        self.index = index
        self.itemPositions = itemPositions
        self.animatePositions = animatePositions
        self.showContents = showContents
    }
    
    var body: some View {
        FBPlayerStatsItem(
            fbPlayerStatsStore: fbPlayerStatsStore,
            stats: stats,
            showContents: showContents
        )
        .offset(animatePositions ? itemPositions[index + 1] ?? parentCenterPosition : parentCenterPosition)
    }
}

struct FBPlayerStatsItem: View {
    @ComposableArchitecture.Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let stats: FBPlayerStats
    let showContents: Bool
    
    @State var teamName = ""

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
                
                Text(EnNameTranslationUtility.translateByDic(type: .team, input: teamName))
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
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
        .onAppear {
            translate()
        }
    }
    
    private func translate() {
        Task {
            let teamName = await EnNameTranslationUtility.translateByAWS(input: stats.team.name)
            self.teamName = teamName
        }
    }
}

//#Preview {
//    FBPlayerStatsView()
//}
