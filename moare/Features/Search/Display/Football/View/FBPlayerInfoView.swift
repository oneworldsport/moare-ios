//
//  PlayerInfoView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/13/24.
//

import SwiftUI
import ComposableArchitecture

struct FBPlayerInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBPlayerInfoDisplayModel
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "FBPlayerInfoView"
    
    @State private var parentCenterPosition = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)
    @State private var itemPositions: [Int: CGSize] = [:]
    @State private var itemCenterPositions: [Int: CGSize] = [:]
    @State private var animatePositions = false
    @State private var showContents = false
    
    @State private var itemPositionsSet = false
    @State private var itemCenterPositnosSet = false
    @State private var parentCenterPositionSet = false
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ZStack(alignment: .topLeading) {
                if let fbPlayerInfoStore = fbPlayerInfoStore {
                    /* ---------------------
                       invisible ui
                       - for position
                       --------------------- */
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            FBPlayerInfoFirstItem(fbPlayerInfoStore: fbPlayerInfoStore)
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
                            
                            Spacer()
                            
                            FBPlayerInfoSecondItem(fbPlayerInfoStore: fbPlayerInfoStore)
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
                            
                            Spacer()
                            
                            FBPlayerInfoThirdItem(fbPlayerInfoStore: fbPlayerInfoStore)
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
                        
                        FBPlayerInfoFourthItem(fbPlayerInfoStore: fbPlayerInfoStore)
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
                        
                        FBPlayerInfoFifthItem(fbPlayerInfoStore: fbPlayerInfoStore)
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
                        
                        FBPlayerInfoSixthItem(fbPlayerInfoStore: fbPlayerInfoStore)
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
                    // photo, name
                    FBPlayerInfoFirstItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(animatePositions ? itemPositions[0] ?? .zero : itemCenterPositions[0] ?? .zero)
                    
                    // age, birth, nationality
                    FBPlayerInfoSecondItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(animatePositions ? itemPositions[1] ?? .zero : itemCenterPositions[1] ?? .zero)
                    
                    // weight, height
                    FBPlayerInfoThirdItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(animatePositions ? itemPositions[2] ?? .zero : itemCenterPositions[2] ?? .zero)
                    
                    // league stats
                    FBPlayerInfoFourthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(animatePositions ? itemPositions[3] ?? .zero : itemCenterPositions[3] ?? .zero)
                        .onTapGesture {
                            searchStore.send(.showPlayerStats(0))
                        }
                    
                    // last game stats
                    FBPlayerInfoFifthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(animatePositions ? itemPositions[4] ?? .zero : itemCenterPositions[4] ?? .zero)
                        .onTapGesture {
                            searchStore.send(.showGameStats(true))
                        }
                    
                    // next game
                    FBPlayerInfoSixthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(animatePositions ? itemPositions[5] ?? .zero : itemCenterPositions[5] ?? .zero)
                        .onTapGesture {
                            searchStore.send(.showGameStats(false))
                        }
                } // if let fbPlayerInfoStore
            } // ZStack
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(ItemPositionsPreferenceKey.self) { positions in
                self.itemPositions = positions
                
                if positions.count == 6 {
                    itemPositionsSet = true
                    
                    if itemPositionsSet && itemCenterPositnosSet && parentCenterPositionSet && !animatePositions {
                        triggerAnimation()
                    }
                }
            }
            .onPreferenceChange(ItemCenterPositionsPreferenceKey.self) { positions in
                self.itemCenterPositions = positions
                
                if positions.count == 6 {
                    itemCenterPositnosSet = true
                    
                    if itemPositionsSet && itemCenterPositnosSet && parentCenterPositionSet && !animatePositions {
                        triggerAnimation()
                    }
                }
            }
            .onChange(of: parentCenterPosition) { newValue in
                // TODO: Cannot ensure if parentCenterPosition is set after all the positions are set.
                if itemPositions.count == 6 {
                    parentCenterPositionSet = true
                    
                    if itemPositionsSet && itemCenterPositnosSet && parentCenterPositionSet && !animatePositions {
                        triggerAnimation()
                    }
                }
            }
            .onAppear {
                // init FBPlayerInfoStore
                let fbPlayerInfoStore: StoreOf<FBPlayerInfoStore> = storeManager.getStore(forKey: StoreKeys.fbPlayerInfoStore) ?? {
                    let newStore = Store(initialState: FBPlayerInfoStore.State()) { FBPlayerInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbPlayerInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbPlayerInfoStore = fbPlayerInfoStore
                }
                
                fbPlayerInfoStore.send(.initData(displayModel: displayModel))
            }
        } // if let searchStore
    }
    
    private func triggerAnimation() {
        self.itemCenterPositions = self.itemCenterPositions.mapValues { currentVaule in
            CGSize(
                width: parentCenterPosition.width - currentVaule.width,
                height: parentCenterPosition.height
            )
        }
        
//        withAnimation(.spring(response: 1)) {
        withAnimation(.easeInOut(duration: 1)) {
            animatePositions = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showContents = true
            }
        }
    }
}

struct ItemPositionsPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGSize] = [:]
    
    static func reduce(value: inout [Int: CGSize], nextValue: () -> [Int: CGSize]) {
        nextValue().forEach { key, position in
            value[key] = position
        }
    }
}

struct ItemCenterPositionsPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGSize] = [:]
    
    static func reduce(value: inout [Int: CGSize], nextValue: () -> [Int: CGSize]) {
        nextValue().forEach { key, position in
            value[key] = position
        }
    }
}

struct FBPlayerInfoFirstItem: View {
    @ComposableArchitecture.Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            URLImage(url: fbPlayerInfoStore.player?.photo)
                .opacity(showContents ? 1 : 0)
            
            Text(fbPlayerInfoStore.player?.krname ?? "")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            Text(fbPlayerInfoStore.player?.name ?? "")
                .font(.system(size: 12))
                .fontWeight(.light)
                .lineLimit(2)
                .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: 130)
    }
}

struct FBPlayerInfoSecondItem: View {
    @ComposableArchitecture.Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
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
                Text("국적: ")
                    .font(.system(size: 15))
                    
                Text(fbPlayerInfoStore.nationalityKrName)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("출생: ")
                    .font(.system(size: 15))
                
                Text(fbPlayerInfoStore.player?.birth.date ?? "")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .padding(.vertical, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("나이: ")
                    .font(.system(size: 15))
                
                Text("\(fbPlayerInfoStore.player?.age ?? 0)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: 130)
    }
}

struct FBPlayerInfoThirdItem: View {
    @ComposableArchitecture.Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
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
                Text("키: ")
                    .font(.system(size: 15))
                
                Text(fbPlayerInfoStore.player?.height ?? "")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("몸무게: ")
                    .font(.system(size: 15))
                
                Text(fbPlayerInfoStore.player?.weight ?? "")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
//            .padding(.top, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: 130)
    }
}

struct FBPlayerInfoFourthItem: View {
    @ComposableArchitecture.Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    @State var teamKrName = ""
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            if let league = fbPlayerInfoStore.league {
                LeagueTitle(
                    url: league.logo,
                    leagueName: league.name,
                    leagueSeason: league.season
                )
                .opacity(showContents ? 1 : 0)
            }
            
            HStack {
                VStack {
                    Text("소속팀")
                        .font(.system(size: 15))
                    
                    if let team = fbPlayerInfoStore.team {
                        HStack {
                            URLImage(url: team.logo, size: .small)
                            
                            Text(EnNameTranslationUtility.translateByDic(type: .team, input: teamKrName))
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        .frame(maxHeight: fbPlayerInfoStore.itemHeight)
                    }
                }
                
                if let stats = fbPlayerInfoStore.stats {
                    FBStatDataItem(category: "경기수", data: "\(stats.games.appearences)")
                    FBStatDataItem(category: "골", data: "\(stats.goals.total)")
                    FBStatDataItem(category: "도움", data: "\(stats.goals.assists)")
                }
            }
            .opacity(showContents ? 1 : 0)
        }
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .onAppear {
            translate()
        }
    }
    
    private func translate() {
        guard let team = fbPlayerInfoStore.team else { return }
        
        Task {
            let teamKrName = await EnNameTranslationUtility.translateByAWS(input: team.name)
            self.teamKrName = teamKrName
        }
    }
}

struct FBPlayerInfoFifthItem: View {
    @ComposableArchitecture.Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    @State var homeTeamKrName = ""
    @State var awayTeamKrName = ""
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            HStack {
                if let lastGame = fbPlayerInfoStore.lastGame {
                    VStack {
                        HStack {
                            Text(EnNameTranslationUtility.translateByDic(type: .team, input: homeTeamKrName))
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .lineLimit(1)
                            
                            Text("\(lastGame.goals.home)")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .foregroundStyle((lastGame.goals.home >= lastGame.goals.away) ? .moare : .primary)
                            
                            Text(" vs ")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                            
                            Text("\(lastGame.goals.away)")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .foregroundStyle((lastGame.goals.away >= lastGame.goals.home) ? .moare : .primary)
                            
                            Text(EnNameTranslationUtility.translateByDic(type: .team, input: awayTeamKrName))
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .lineLimit(1)
                        }
                        
                        Text(CalendarUtil.formatDate(date: lastGame.fixture.date))
                            .font(.system(size: 15))
                            .frame(maxHeight: fbPlayerInfoStore.itemHeight)
                    }
                    .padding(.top, 4)
                }
                
                if let lastGamePlayerStats = fbPlayerInfoStore.lastGamePlayerStats {
                    FBStatDataItem(
                        category: "출전시간",
                        data: (lastGamePlayerStats.games.substitute ? "후보" : "선발") + " / \(lastGamePlayerStats.games.minutes)분",
                        customWidth: 80
                    )
                    
                    FBStatDataItem(category: "골", data: "\(lastGamePlayerStats.goals.total)")
                    FBStatDataItem(category: "도움", data: "\(lastGamePlayerStats.goals.assists)")
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
        guard let lastGame = fbPlayerInfoStore.lastGame else { return }
        
        Task {
            let homeTeamKrName = await EnNameTranslationUtility.translateByAWS(input: lastGame.teams.home.name)
            self.homeTeamKrName = homeTeamKrName
        }
        
        Task {
            let awayTeamKrName = await EnNameTranslationUtility.translateByAWS(input: lastGame.teams.away.name)
            self.awayTeamKrName = awayTeamKrName
        }
    }
}

struct FBPlayerInfoSixthItem: View {
    @ComposableArchitecture.Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    @State var homeTeamKrName = ""
    @State var awayTeamKrName = ""
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        VStack {
            HCapsuleBar()
            
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame = fbPlayerInfoStore.nextGame {
                HStack {
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: homeTeamKrName))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: awayTeamKrName))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.fixture.date))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        } // VStack
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .onAppear {
            translate()
        }
    }
    
    private func translate() {
        guard let nextGame = fbPlayerInfoStore.nextGame else { return }
        
        Task {
            let homeTeamKrName = await EnNameTranslationUtility.translateByAWS(input: nextGame.teams.home.name)
            self.homeTeamKrName = homeTeamKrName
        }
        
        Task {
            let awayTeamKrName = await EnNameTranslationUtility.translateByAWS(input: nextGame.teams.away.name)
            self.awayTeamKrName = awayTeamKrName
        }
    }
}
