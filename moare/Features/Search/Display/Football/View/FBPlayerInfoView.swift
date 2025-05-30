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
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            InfoViewContainer(itemCount: 6) { scope in
                if let fbPlayerInfoStore {
                    HStack(alignment: .top) {
                        FBPlayerInfoFirstItem(fbPlayerInfoStore: fbPlayerInfoStore)
                            .background(
                                GeometryReader { geometry in
                                    // NOTE: 처음 오픈 시 animation이 적용되기 때문에 onAppear가 아니라 onChange로 해야함
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 0, geometry: geometry)
                                    }
                                }
                            )
                        
                        Spacer()
                        
                        FBPlayerInfoSecondItem(fbPlayerInfoStore: fbPlayerInfoStore)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 1, geometry: geometry)
                                    }
                                }
                            )
                        
                        Spacer()
                        
                        FBPlayerInfoThirdItem(fbPlayerInfoStore: fbPlayerInfoStore)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 2, geometry: geometry)
                                    }
                                }
                            )
                    }
                    
                    FBPlayerInfoFourthItem(fbPlayerInfoStore: fbPlayerInfoStore)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 3, geometry: geometry)
                                }
                            }
                        )
                    
                    FBPlayerInfoFifthItem(fbPlayerInfoStore: fbPlayerInfoStore)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 4, geometry: geometry)
                                }
                            }
                        )
                    
                    FBPlayerInfoSixthItem(fbPlayerInfoStore: fbPlayerInfoStore)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                    scope.updateItemFrame(index: 5, geometry: geometry)
                                }
                            }
                        )
                } // if let fbPlayerInfoStore
            } displayContent: { scope in
                if let fbPlayerInfoStore {
                    // photo, name
                    FBPlayerInfoFirstItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 0))
                    
                    // age, birth, nationality
                    FBPlayerInfoSecondItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 1))
                    
                    // weight, height
                    FBPlayerInfoThirdItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 2))
                    
                    // league stats
                    FBPlayerInfoFourthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 3))
                        .onTapGesture {
                            if let player = fbPlayerInfoStore.baseInfo.displayModel?.info {
                                searchStore.send(.showPlayerStats(playerId: player.id))
                            }
                        }
                    
                    // last game stats
                    FBPlayerInfoFifthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 4))
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "previous"))
                        }
                    
                    // next game
                    FBPlayerInfoSixthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: scope.showContents)
                        .offset(scope.computedOffset(for: 5))
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "next"))
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
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.fbPlayerInfoStore = fbPlayerInfoStore
                }
                
                if searchStore.poppedView == nil {
                    fbPlayerInfoStore.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .fbPlayerInfo = searchStore.poppedView {
                    fbPlayerInfoStore?.send(.baseInfo(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

struct FBPlayerInfoFirstItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let playerNameDic = fbPlayerInfoStore.baseInfo.playerNameDictionary
        let player = fbPlayerInfoStore.baseInfo.displayModel?.info
        
        VStack {
            HCapsuleBar()
            
            URLImage(url: player?.photo)
                .opacity(showContents ? 1 : 0)
            
            Text(playerNameDic["\(player?.id ?? 0)"] ?? (player?.name ?? ""))
                .font(.system(size: 16))
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            Text(player?.name ?? "")
                .font(.system(size: 12))
                .fontWeight(.light)
                .lineLimit(2)
                .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: 130)
    }
}

struct FBPlayerInfoSecondItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
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
            
            if let player = fbPlayerInfoStore.baseInfo.displayModel?.info {
                HStack(spacing: 0) {
                    Text("국적: ")
                        .font(.system(size: 15))
                    
                    Text(player.nationality)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("출생: ")
                        .font(.system(size: 15))
                    
                    Text(player.birth.date)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.vertical, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("나이: ")
                        .font(.system(size: 15))
                    
                    Text("\(player.age)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: 130)
    }
}

struct FBPlayerInfoThirdItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
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
            
            if let player = fbPlayerInfoStore.baseInfo.displayModel?.info {
                HStack(spacing: 0) {
                    Text("키: ")
                        .font(.system(size: 15))
                    
                    Text(player.height)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("몸무게: ")
                        .font(.system(size: 15))
                    
                    Text(player.weight)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                //            .padding(.top, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
            }
        }
        .frame(maxWidth: 130)
    }
}

struct FBPlayerInfoFourthItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbPlayerInfoStore.baseInfo.teamNameDictionary
        let stats = fbPlayerInfoStore.baseInfo.displayModel?.stats
        let team = stats?.team
        
        VStack {
            HCapsuleBar()
            
            if let league = stats?.league {
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
                    
                    if let team {
                        HStack {
                            URLImage(url: team.logo, size: .small)
                            
                            Text(teamNameDic["full_\(team.id)"] ?? team.name)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        .frame(maxHeight: fbPlayerInfoStore.itemHeight)
                    }
                }
                
                if let stats {
                    FBStatDataItem(category: "경기수", data: "\(stats.games.appearences)")
                    FBStatDataItem(category: "골", data: "\(stats.goals.total)")
                    FBStatDataItem(category: "도움", data: "\(stats.goals.assists)")
                }
            }
            .opacity(showContents ? 1 : 0)
        }
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBPlayerInfoFifthItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbPlayerInfoStore.baseInfo.teamNameDictionary
        
        VStack {
            HCapsuleBar()
            
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            HStack {
                if let lastGame = fbPlayerInfoStore.baseInfo.displayModel?.lastGame {
                    VStack {
                        HStack {
                            Text(teamNameDic["short_\(lastGame.teams.home.id)"] ?? lastGame.teams.home.name)
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
                            
                            Text(teamNameDic["short_\(lastGame.teams.away.id)"] ?? lastGame.teams.away.name)
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
                
                if let lastGamePlayerStats = fbPlayerInfoStore.baseInfo.displayModel?.lastGamePlayerStats {
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
    }
}

struct FBPlayerInfoSixthItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
    init(fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>, showContents: Bool = true) {
        self.fbPlayerInfoStore = fbPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let teamNameDic = fbPlayerInfoStore.baseInfo.teamNameDictionary
        
        VStack {
            HCapsuleBar()
            
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame = fbPlayerInfoStore.baseInfo.displayModel?.nextGame {
                HStack {
                    Text(teamNameDic["short_\(nextGame.teams.home.id)"] ?? nextGame.teams.home.name)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(teamNameDic["short_\(nextGame.teams.away.id)"] ?? nextGame.teams.away.name)
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
    }
}
