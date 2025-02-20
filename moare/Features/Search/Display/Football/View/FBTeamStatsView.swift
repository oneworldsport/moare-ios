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
    let statsList: [FBTeamStats]
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "FBTeamStatsView"
    
    private var parentCenterPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    @State private var itemPositions: [Int: CGSize] = [:]
    @State private var animatePositions = false
    @State private var showContents = false
    
    @State private var mainUIVisibleState = false
    
    init(displayModel: FBTeamStatsDisplayModel) {
        self.displayModel = displayModel
        self.statsList = displayModel.stats
    }
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView {
                if let fbTeamStatsStore = fbTeamStatsStore {
                    ZStack(alignment: .topLeading) {
                        /* ---------------------
                         ui
                         - invisible first
                         - set ani ui's position
                         - visible after ani ui
                         --------------------- */
                        VStack {
                            FBTeamStatsTeamInfoItem(
                                fbTeamStatsStore: fbTeamStatsStore
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
                            
                            FBTeamStatsList(
                                fbTeamStatsStore: fbTeamStatsStore,
                                itemPositions: itemPositions
                            )
                        }
                        .opacity(mainUIVisibleState ? 1 : 0)
                        
                        /* ---------------------
                         aimation ui
                         - invisible after ani
                         --------------------- */
                        if !mainUIVisibleState {
                            FBTeamStatsTeamInfoItem(
                                fbTeamStatsStore: fbTeamStatsStore,
                                showContents: showContents
                            )
                            .offset(animatePositions ? itemPositions[0] ?? parentCenterPosition : parentCenterPosition)
                            
                            FBTeamStatsAniList(
                                fbTeamStatsStore: fbTeamStatsStore,
                                itemPositions: itemPositions,
                                animatePositions: animatePositions,
                                showContents: showContents
                            )
                        }
                    } // ZStack
                } // if let fbTeamStatsStore
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
                // init FBTeamStatsStore
                let fbTeamStatsStore: StoreOf<FBTeamStatsStore> = storeManager.getStore(forKey: StoreKeys.fbTeamStatsStore) ?? {
                    let newStore = Store(initialState: FBTeamStatsStore.State(
                        displayModel: displayModel,
                        statsList: statsList,
                        team: displayModel.team,
                        venue: displayModel.venue
                    )) { FBTeamStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTeamStatsStore)
                    
                    newStore.send(.initData)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbTeamStatsStore = fbTeamStatsStore
                }
            }
        }
    }
}

struct FBTeamStatsTeamInfoItem: View {
    @ComposableArchitecture.Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let showContents: Bool
    
    init(fbTeamStatsStore: StoreOf<FBTeamStatsStore>, showContents: Bool = true) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.showContents = showContents
    }
    
    var body: some View {
        let team = fbTeamStatsStore.team
        let venue = fbTeamStatsStore.venue
        
        VStack {
            HCapsuleBar()
            
            HStack(spacing: 8) {
                URLImage(url: team.logo)
                
                VStack(alignment: .leading) {
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: team.krname))
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
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBTeamStatsList: View {
    @ComposableArchitecture.Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let itemPositions: [Int: CGSize]
    
    init(fbTeamStatsStore: StoreOf<FBTeamStatsStore>, itemPositions: [Int : CGSize]) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.itemPositions = itemPositions
    }
    
    var body: some View {
        ForEach(fbTeamStatsStore.statsList.indices, id: \.self) { index in
            let stats = fbTeamStatsStore.statsList[index]
            
            FBTeamStatsListItem(
                fbTeamStatsStore: fbTeamStatsStore,
                stats: stats,
                itemPositions: itemPositions,
                index: index
            )
        }
    }
}

struct FBTeamStatsListItem: View {
    @ComposableArchitecture.Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let stats: FBTeamStats
    let itemPositions: [Int : CGSize]
    let index: Int
    
    init(fbTeamStatsStore: StoreOf<FBTeamStatsStore>, stats: FBTeamStats, itemPositions: [Int : CGSize], index: Int) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.stats = stats
        self.itemPositions = itemPositions
        self.index = index
    }
    
    var body: some View {
        FBTeamStatsItem(stats: stats)
            .background(
                GeometryReader { geometry in
                    if itemPositions[index + 1] == nil {
                        Color.clear.preference(
                            key: ItemPositionsPreferenceKey.self,
                            value: [index + 1: CGSize(
                                width: geometry.frame(in: .named("FBTeamStatsView")).minX,
                                height: geometry.frame(in: .named("FBTeamStatsView")).minY)]
                        )
                    }
                }
            )
    }
}

struct FBTeamStatsAniList: View {
    @ComposableArchitecture.Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let itemPositions: [Int: CGSize]
    let animatePositions: Bool
    let showContents: Bool
    
    init(fbTeamStatsStore: StoreOf<FBTeamStatsStore>, itemPositions: [Int : CGSize], animatePositions: Bool, showContents: Bool) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.itemPositions = itemPositions
        self.animatePositions = animatePositions
        self.showContents = showContents
    }
    
    var body: some View {
        ForEach(fbTeamStatsStore.statsList.indices, id: \.self) { index in
            let stats = fbTeamStatsStore.statsList[index]
            
            FBTeamStatsAniListItem(
                fbTeamStatsStore: fbTeamStatsStore,
                stats: stats,
                index: index,
                itemPositions: itemPositions,
                animatePositions: animatePositions,
                showContents: showContents
            )
        }
    }
}

struct FBTeamStatsAniListItem: View {
    @ComposableArchitecture.Bindable var fbTeamStatsStore: StoreOf<FBTeamStatsStore>
    
    let stats: FBTeamStats
    let index: Int
    let itemPositions: [Int : CGSize]
    let animatePositions: Bool
    let showContents: Bool
    
    private var parentCenterPosition = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    init(fbTeamStatsStore: StoreOf<FBTeamStatsStore>, stats: FBTeamStats, index: Int, itemPositions: [Int : CGSize], animatePositions: Bool, showContents: Bool) {
        self.fbTeamStatsStore = fbTeamStatsStore
        self.stats = stats
        self.index = index
        self.itemPositions = itemPositions
        self.animatePositions = animatePositions
        self.showContents = showContents
    }
    
    var body: some View {
        FBTeamStatsItem(
            stats: stats,
            showContents: showContents
        )
        .offset(animatePositions ? itemPositions[index + 1] ?? parentCenterPosition : parentCenterPosition)
    }
}

struct FBTeamStatsItem: View {
    let stats: FBTeamStats
    let showContents: Bool
    
    @State var teamKrName = ""
    
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
                
                Text(" - ")
                    .fontWeight(.medium)
                
                URLImage(url: stats.team.logo, customSize: CGSize(width: 24, height: 24))
                
                Text(EnNameTranslationUtility.translateByDic(type: .team, input: teamKrName))
                    .font(.system(size: 16))
                    .fontWeight(.medium)
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
                    customFontSize: 11,
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
                    customFontSize: 11,
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
                    data: "\(stats.cleanSheet.total)",
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
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
        .onAppear {
            translate()
        }
    }
    
    private func translate() {
        Task {
            let teamKrName = await EnNameTranslationUtility.translateByAWS(input: stats.team.name)
            self.teamKrName = teamKrName
        }
    }
}

//#Preview {
//    FBTeamStatsView()
//}
