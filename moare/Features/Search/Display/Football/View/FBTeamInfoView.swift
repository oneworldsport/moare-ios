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
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            InfoViewContainer(itemCount: 6) { scope in
                if let fbTeamInfoStore {
                    HStack(alignment: .top) {
                        // logo, name
                        FBTeamInfoFirstItem(fbTeamInfoStore: fbTeamInfoStore)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 0, geometry: geometry)
                                    }
                                }
                            )
                        
                        // founded, city, country
                        FBTeamInfoSecondItem(fbTeamInfoStore: fbTeamInfoStore)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 1, geometry: geometry)
                                    }
                                }
                            )
                        
                        // venue
                        FBTeamInfoThirdItem(fbTeamInfoStore: fbTeamInfoStore)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 2, geometry: geometry)
                                    }
                                }
                            )
                    }
                    
                    // league stats
                    FBTeamInfoFourthItem(fbTeamInfoStore: fbTeamInfoStore)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 3, geometry: geometry)
                                }
                            }
                        )
                    
                    HStack {
                        // last game stats
                        FBTeamInfoFifthItem(fbTeamInfoStore: fbTeamInfoStore)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 4, geometry: geometry)
                                    }
                                }
                            )
                        
                        // next game stats
                        FBTeamInfoSixthItem(fbTeamInfoStore: fbTeamInfoStore)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 5, geometry: geometry)
                                    }
                                }
                            )
                    }
                }
            } displayContent: { scope in
                if let fbTeamInfoStore {
                    // logo, name
                    FBTeamInfoFirstItem(fbTeamInfoStore: fbTeamInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 0))
                    
                    // founded, city, country
                    FBTeamInfoSecondItem(fbTeamInfoStore: fbTeamInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 1))
                    
                    // venue
                    FBTeamInfoThirdItem(fbTeamInfoStore: fbTeamInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 2))
                    
                    // league stats
                    FBTeamInfoFourthItem(fbTeamInfoStore: fbTeamInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 3))
                        .onTapGesture {
                            if let team = fbTeamInfoStore.baseInfo.displayModel?.team {
                                searchStore.send(.showTeamStats(teamId: team.id))
                            }
                        }
                    
                    // last game stats
                    FBTeamInfoFifthItem(fbTeamInfoStore: fbTeamInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 4))
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "previous"))
                        }
                    
                    // next game stats
                    FBTeamInfoSixthItem(fbTeamInfoStore: fbTeamInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 5))
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "next"))
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
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.fbTeamInfoStore = fbTeamInfoStore
                }
                
                if searchStore.poppedView == nil {
                    fbTeamInfoStore.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .fbTeamInfo = searchStore.poppedView {
                    fbTeamInfoStore?.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
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
        let teamNameDic = fbTeamInfoStore.baseInfo.teamNameDictionary
        
        if let team = fbTeamInfoStore.baseInfo.displayModel?.team {
            VStack {
                HCapsuleBar()
                
                URLImage(url: team.logo)
                    .opacity(showContents ? 1 : 0)
                
                Text(teamNameDic["full_\(team.id)"] ?? team.name)
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
    
//    @State var city = ""
    
    init(fbTeamInfoStore: StoreOf<FBTeamInfoStore>, showContents: Bool = true) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = fbTeamInfoStore.baseInfo.displayModel
        let team = displayModel?.team
        
        VStack(alignment:.leading) {
            // added HStack to position Capsule at center
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 0) {
                Text("창단연도: ")
                    .font(.system(size: 15))
                    
                Text("\(team?.founded ?? 0)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("연고지: ")
                    .font(.system(size: 15))
                    
                Text(displayModel?.venue.city ?? "")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .padding(.vertical, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("소속나라: ")
                    .font(.system(size: 15))
                    
                Text(EnNameTranslationUtility.translateByDic(type: .country, input: team?.country ?? ""))
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
        } // VStack
        .frame(maxWidth: 130)
//        .onAppear {
//            translate()
//        }
    }
    
//    private func translate() {
//        Task {
//            let city = await EnNameTranslationUtility.translateByAWS(input: fbTeamInfoStore.venue?.city)
//            self.city = city
//        }
//    }
}

struct FBTeamInfoThirdItem: View {
    @Bindable var fbTeamInfoStore: StoreOf<FBTeamInfoStore>
    let showContents: Bool
    
    init(fbTeamInfoStore: StoreOf<FBTeamInfoStore>, showContents: Bool = true) {
        self.fbTeamInfoStore = fbTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbTeamInfoStore.baseInfo.teamNameDictionary
        let team = fbTeamInfoStore.baseInfo.displayModel?.team
        let venue = fbTeamInfoStore.baseInfo.displayModel?.venue
        
        VStack(alignment:.leading) {
            // added HStack to position Capsule at center
            HStack {
                HCapsuleBar()
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 0) {
                Text("홈구장: ")
                    .font(.system(size: 15))
                
                Text(teamNameDic["venue_\(team?.id ?? 0)"] ?? (venue?.name ?? ""))
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .opacity(showContents ? 1 : 0)
            
            HStack(spacing: 0) {
                Text("좌석수: ")
                    .font(.system(size: 15))
                
                Text("\(venue?.capacity ?? 0)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
            }
            .padding(.top, UIConstants.Padding.defalutVPadding)
            .opacity(showContents ? 1 : 0)
        } // VStack
        .frame(maxWidth: 130)
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
        let displayModel = fbTeamInfoStore.baseInfo.displayModel
        
        VStack {
            HCapsuleBar()
            
            if let league = displayModel?.stats?.league {
                LeagueTitle(
                    url: league.logo,
                    leagueName: league.name,
                    leagueSeason: league.season
                )
                .opacity(showContents ? 1 : 0)
            }
            
            if let stats = displayModel?.stats {
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
        let teamNameDic = fbTeamInfoStore.baseInfo.teamNameDictionary
        
        VStack {
            HCapsuleBar()
            
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let lastGame = fbTeamInfoStore.baseInfo.displayModel?.lastGame {
                HStack {
                    Text(teamNameDic["short_\(lastGame.teams.home.id)"] ?? lastGame.teams.home.name)
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
                    
                    Text(teamNameDic["short_\(lastGame.teams.away.id)"] ?? lastGame.teams.away.name)
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
        let teamNameDic = fbTeamInfoStore.baseInfo.teamNameDictionary
        
        VStack {
            HCapsuleBar()
            
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame = fbTeamInfoStore.baseInfo.displayModel?.nextGame {
                HStack {
                    Text(teamNameDic["short_\(nextGame.teams.home.id)"] ?? nextGame.teams.home.name)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text(teamNameDic["short_\(nextGame.teams.away.id)"] ?? nextGame.teams.away.name)
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
