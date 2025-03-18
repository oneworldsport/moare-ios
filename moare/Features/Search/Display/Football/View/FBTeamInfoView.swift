//
//  FBTeamInfoView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import SwiftUI
import ComposableArchitecture

struct FBTeamInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbTeamInfoStore: StoreOf<FBTeamInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBTeamInfoDisplayModel
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "FBTeamInfoView"
    
    @State private var parentCenterPosition = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)
    @State private var itemPositions: [Int: CGSize] = [:]
    @State private var itemCenterPositions: [Int: CGSize] = [:]
    @State private var animatePositions = false
    @State private var showContents = false
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ZStack(alignment: .topLeading) {
                if let fbTeamInfoStore = fbTeamInfoStore {
                    /* ---------------------
                       invisible ui
                       - for position
                       --------------------- */
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            // logo, name
                            FBTeamInfoFirstItem(
                                fbTeamInfoStore: fbTeamInfoStore
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.preference(
                                        key: ItemPositionsPreferenceKey.self,
                                        value: [0: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: geometry.frame(in: .named(coordinateSpaceName)).minY)]
                                    )
                                    Color.clear.preference(
                                        key: ItemCenterPositionsPreferenceKey.self,
                                        value: [0: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).midX - geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: 0)]
                                    )
                                }
                            )
                            
                            // founded, city, country
                            FBTeamInfoSecondItem(
                                fbTeamInfoStore: fbTeamInfoStore
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.preference(
                                        key: ItemPositionsPreferenceKey.self,
                                        value: [1: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: geometry.frame(in: .named(coordinateSpaceName)).minY)]
                                    )
                                    Color.clear.preference(
                                        key: ItemCenterPositionsPreferenceKey.self,
                                        value: [1: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).midX - geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: 0)]
                                    )
                                }
                            )
                            
                            // venue
                            FBTeamInfoThirdItem(
                                fbTeamInfoStore: fbTeamInfoStore
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.preference(
                                        key: ItemPositionsPreferenceKey.self,
                                        value: [2: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: geometry.frame(in: .named(coordinateSpaceName)).minY)]
                                    )
                                    Color.clear.preference(
                                        key: ItemCenterPositionsPreferenceKey.self,
                                        value: [2: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).midX - geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: 0)]
                                    )
                                }
                            )
                        }
                        
                        // league stats
                        FBTeamInfoFourthItem(
                            fbTeamInfoStore: fbTeamInfoStore
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ItemPositionsPreferenceKey.self,
                                    value: [3: CGSize(
                                        width: geometry.frame(in: .named(coordinateSpaceName)).minX,
                                        height: geometry.frame(in: .named(coordinateSpaceName)).minY)]
                                )
                                Color.clear.preference(
                                    key: ItemCenterPositionsPreferenceKey.self,
                                    value: [3: CGSize(
                                        width: geometry.frame(in: .named(coordinateSpaceName)).midX - geometry.frame(in: .named(coordinateSpaceName)).minX,
                                        height: 0)]
                                )
                            }
                        )
                        
                        HStack {
                            // last game stats
                            FBTeamInfoFifthItem(
                                fbTeamInfoStore: fbTeamInfoStore
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.preference(
                                        key: ItemPositionsPreferenceKey.self,
                                        value: [4: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: geometry.frame(in: .named(coordinateSpaceName)).minY)]
                                    )
                                    Color.clear.preference(
                                        key: ItemCenterPositionsPreferenceKey.self,
                                        value: [4: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).midX - geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: 0)]
                                    )
                                }
                            )

                            // next game stats
                            FBTeamInfoSixthItem(
                                fbTeamInfoStore: fbTeamInfoStore
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.preference(
                                        key: ItemPositionsPreferenceKey.self,
                                        value: [5: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: geometry.frame(in: .named(coordinateSpaceName)).minY)]
                                    )
                                    Color.clear.preference(
                                        key: ItemCenterPositionsPreferenceKey.self,
                                        value: [5: CGSize(
                                            width: geometry.frame(in: .named(coordinateSpaceName)).midX - geometry.frame(in: .named(coordinateSpaceName)).minX,
                                            height: 0)]
                                    )
                                }
                            )
                        }
                    } // VStack
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                parentCenterPosition = CGSize(
                                    width: geometry.size.width / 2, height: geometry.size.height / 2
                                )
                            }
                        }
                    )
                    .opacity(0)
                    
                    /* ---------------------
                       visible ui
                       - with animation effect
                       --------------------- */
                    // logo, name
                    FBTeamInfoFirstItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        showContents: showContents
                    )
                    .offset(animatePositions ? itemPositions[0] ?? .zero : itemCenterPositions[0] ?? .zero)
                    
                    // founded, city, country
                    FBTeamInfoSecondItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        showContents: showContents
                    )
                    .offset(animatePositions ? itemPositions[1] ?? .zero : itemCenterPositions[1] ?? .zero)
                    
                    // venue
                    FBTeamInfoThirdItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        showContents: showContents
                    )
                    .offset(animatePositions ? itemPositions[2] ?? .zero : itemCenterPositions[2] ?? .zero)
                    
                    // league stats
                    FBTeamInfoFourthItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        showContents: showContents
                    )
                    .offset(animatePositions ? itemPositions[3] ?? .zero : itemCenterPositions[3] ?? .zero)
                    .onTapGesture {
                        if let team = fbTeamInfoStore.team {
                            searchStore.send(.showTeamStats(teamId: team.id))
                        }
                    }
                    
                    // last game stats
                    FBTeamInfoFifthItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        showContents: showContents
                    )
                    .offset(animatePositions ? itemPositions[4] ?? .zero : itemCenterPositions[4] ?? .zero)
                    .onTapGesture {
                        searchStore.send(.showGameStats(gameType: "previous"))
                    }
                    
                    // next game stats
                    FBTeamInfoSixthItem(
                        fbTeamInfoStore: fbTeamInfoStore,
                        showContents: showContents
                    )
                    .offset(animatePositions ? itemPositions[5] ?? .zero : itemCenterPositions[5] ?? .zero)
                    .onTapGesture {
                        searchStore.send(.showGameStats(gameType: "next"))
                    }
                    
                }
            }
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(ItemPositionsPreferenceKey.self) { positions in
                self.itemPositions = positions
                
                if positions.count == 6 {
                }
            }
            .onPreferenceChange(ItemCenterPositionsPreferenceKey.self) { positions in
                self.itemCenterPositions = positions
            }
            .onChange(of: parentCenterPosition) { newValue in
                // TODO: Cannot ensure if parentCenterPosition is set after all the positions are set.
                if itemPositions.count == 6 {
                    self.itemCenterPositions = self.itemCenterPositions.mapValues { currentVaule in
                        CGSize(
                            width: parentCenterPosition.width - currentVaule.width,
                            height: parentCenterPosition.height
                        )
                    }
                    
                    withAnimation(.spring(response: 1)) {
                        animatePositions = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showContents = true
                        }
                    }
                }
            }
            .onAppear {
                // init FBTeamInfoStore
                let fbTeamInfoStore: StoreOf<FBTeamInfoStore> = storeManager.getStore(forKey: StoreKeys.fbTeamInfoStore) ?? {
                    let newStore = Store(initialState: FBTeamInfoStore.State()) { FBTeamInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTeamInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbTeamInfoStore = fbTeamInfoStore
                }
                
                if searchStore.poppedView == nil {
                    fbTeamInfoStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .fbTeamInfo = searchStore.poppedView {
                    fbTeamInfoStore?.send(.initData(displayModel: displayModel))
                }
            }
        }
    }
}

struct FBTeamInfoFirstItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    let showContents: Bool
    
    init(fbTeamInfoStore: StoreOf<FBTeamInfoStore>, showContents: Bool = true) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        if let team = fbTeamInfoStore.team {
            VStack {
                HCapsuleBar()
                
                URLImage(url: team.logo)
                    .opacity(showContents ? 1 : 0)
                
                Text(EnNameTranslationUtility.translateByDic(type: .team, isShort: false, input: team.name))
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
                
                Text(team.name)
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .lineLimit(2)
                    .opacity(showContents ? 1 : 0)
            }
            .frame(maxWidth: 130)
        }
    }
}

struct FBTeamInfoSecondItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    let showContents: Bool
    
    @State var city = ""
    
    init(fbTeamInfoStore: StoreOf<FBTeamInfoStore>, showContents: Bool = true) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            // added HStack to position Capsule at center
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 0) {
                Text("창립년도: ")
                    .font(.system(size: 15))
                    
                Text("\(fbTeamInfoStore.team?.founded ?? 0)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("연고지: ")
                    .font(.system(size: 15))
                    
                Text(city)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .padding(.vertical, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("소속나라: ")
                    .font(.system(size: 15))
                    
                Text(EnNameTranslationUtility.translateByDic(type: .country, input: fbTeamInfoStore.team?.country ?? ""))
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .frame(maxWidth: 130)
        .onAppear {
            translate()
        }
    }
    
    private func translate() {
        Task {
            let city = await EnNameTranslationUtility.translateByAWS(input: fbTeamInfoStore.venue?.city)
            self.city = city
        }
    }
}

struct FBTeamInfoThirdItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    let showContents: Bool
    
    @State var venueName = ""
    
    init(fbTeamInfoStore: StoreOf<FBTeamInfoStore>, showContents: Bool = true) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            // added HStack to position Capsule at center
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 0) {
                Text("홈구장: ")
                    .font(.system(size: 15))
                
                Text(venueName)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("좌석수: ")
                    .font(.system(size: 15))
                
                Text("\(fbTeamInfoStore.venue?.capacity ?? 0)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .padding(.top, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
        } // VStack
        .frame(maxWidth: 130)
        .onAppear {
            translate()
        }
    }
    
    // TODO: can move this to store
    private func translate() {
        Task {
            let venueName = await EnNameTranslationUtility.translateByAWS(input: fbTeamInfoStore.venue?.name)
            self.venueName = venueName
        }
    }
}

struct FBTeamInfoFourthItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    let showContents: Bool
    
    init(fbTeamInfoStore: StoreOf<FBTeamInfoStore>, showContents: Bool = true) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            if let league = fbTeamInfoStore.league {
                LeagueTitle(
                    url: league.logo,
                    leagueName: league.name,
                    leagueSeason: league.season
                )
                .opacity(showContents ? 1 : 0)
            }
            
            if let stats = fbTeamInfoStore.stats {
                HStack {
                    FBStatDataItem(category: "승", data: "\(stats.fixtures.wins.total)")
                    FBStatDataItem(category: "무", data: "\(stats.fixtures.draws.total)")
                    FBStatDataItem(category: "패", data: "\(stats.fixtures.loses.total)")
                    FBStatDataItem(category: "득점", data: "\(stats.goals.teamGoalsFor.total.total)")
                    FBStatDataItem(category: "실점", data: "\(stats.goals.teamGoalsAgainst.total.total)")
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBTeamInfoFifthItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    let showContents: Bool
    
    init(fbTeamInfoStore: StoreOf<FBTeamInfoStore>, showContents: Bool = true) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let lastGame = fbTeamInfoStore.lastGame {
                HStack {
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: lastGame.teams.home.name))
                        .font(.system(size: 15))
                        .lineLimit(1)
                    
                    Text("\(lastGame.goals.home)")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundStyle((lastGame.goals.home > lastGame.goals.away) ? .moare : .primary)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text("\(lastGame.goals.away)")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundStyle((lastGame.goals.away > lastGame.goals.home) ? .moare : .primary)
                    
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: lastGame.teams.away.name))
                        .font(.system(size: 15))
                        .lineLimit(1)
                }
                .padding(.vertical, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: lastGame.fixture.date))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        } // VStack
        .frame(maxWidth: UIConstants.Width.screenWidth / 2)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBTeamInfoSixthItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    private let showContents: Bool
    
    init(fbTeamInfoStore: StoreOf<FBTeamInfoStore>, showContents: Bool = true) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame = fbTeamInfoStore.nextGame {
                HStack {
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: nextGame.teams.home.name))
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: nextGame.teams.away.name))
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                .padding(.vertical, 4)
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.fixture.date))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        } // VStack
        .frame(maxWidth: UIConstants.Width.screenWidth / 2)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}
