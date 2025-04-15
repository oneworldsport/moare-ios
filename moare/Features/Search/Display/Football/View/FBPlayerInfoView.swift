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
    
    @State private var firstItemPosition: CGPoint = .zero
    @State private var secondItemPosition: CGPoint = .zero
    @State private var thirdItemPosition: CGPoint = .zero
    @State private var fourthItemPosition: CGPoint = .zero
    @State private var fifthItemPosition: CGPoint = .zero
    @State private var sixthItemPosition: CGPoint = .zero
    
    @State private var containerSize: CGSize = .zero
    @State private var firstItemSize: CGSize = .zero
    @State private var secondItemSize: CGSize = .zero
    @State private var thirdItemSize: CGSize = .zero
    @State private var fourthItemSize: CGSize = .zero
    @State private var fifthItemSize: CGSize = .zero
    @State private var sixthItemSize: CGSize = .zero
    
    @State private var animatePositions = false
    @State private var showContents = false
    
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ZStack(alignment: .topLeading) {
                Spacer() // empty space for smooth animation effect
                    .frame(maxWidth: .infinity, maxHeight: 0)
            
                if let fbPlayerInfoStore {
                /* ---------------------
                   invisible ui
                   - for position
                   --------------------- */
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            FBPlayerInfoFirstItem(fbPlayerInfoStore: fbPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            firstItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            firstItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            Spacer()
                            
                            FBPlayerInfoSecondItem(fbPlayerInfoStore: fbPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            secondItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            secondItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            Spacer()
                            
                            FBPlayerInfoThirdItem(fbPlayerInfoStore: fbPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            thirdItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            thirdItemSize = proxy.size
                                        }
                                    }
                                )
                        }
                        
                        FBPlayerInfoFourthItem(fbPlayerInfoStore: fbPlayerInfoStore)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                        fourthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        fourthItemSize = proxy.size
                                    }
                                }
                            )
                        
                        FBPlayerInfoFifthItem(fbPlayerInfoStore: fbPlayerInfoStore)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                        fifthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        fifthItemSize = proxy.size
                                    }
                                }
                            )
                        
                        FBPlayerInfoSixthItem(fbPlayerInfoStore: fbPlayerInfoStore)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                        sixthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        sixthItemSize = proxy.size
                                    }
                                }
                            )
                    } // VStack
                    .opacity(0)
                    
                    /* ---------------------
                       visible ui
                       - with animation effect
                       --------------------- */
                    // photo, name
                    FBPlayerInfoFirstItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? firstItemPosition.x : containerSize.width / 2 - firstItemSize.width / 2,
                            y: animatePositions ? firstItemPosition.y : containerSize.height / 2
                        )
                    
                    // age, birth, nationality
                    FBPlayerInfoSecondItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? secondItemPosition.x : containerSize.width / 2 - secondItemSize.width / 2,
                            y: animatePositions ? secondItemPosition.y : containerSize.height / 2
                        )
                    
                    // weight, height
                    FBPlayerInfoThirdItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? thirdItemPosition.x : containerSize.width / 2 - thirdItemSize.width / 2,
                            y: animatePositions ? thirdItemPosition.y : containerSize.height / 2
                        )
                    
                    // league stats
                    FBPlayerInfoFourthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? fourthItemPosition.x : containerSize.width / 2 - fourthItemSize.width / 2,
                            y: animatePositions ? fourthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            if let player = fbPlayerInfoStore.player {
                                searchStore.send(.showPlayerStats(playerId: player.id))
                            }
                        }
                    
                    // last game stats
                    FBPlayerInfoFifthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? fifthItemPosition.x : containerSize.width / 2 - fifthItemSize.width / 2,
                            y: animatePositions ? fifthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "previous"))
                        }
                    
                    // next game
                    FBPlayerInfoSixthItem(fbPlayerInfoStore: fbPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? sixthItemPosition.x : containerSize.width / 2 - sixthItemSize.width / 2,
                            y: animatePositions ? sixthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "next"))
                        }
                } // if let fbPlayerInfoStore
            } // ZStack
            .coordinateSpace(name: coordinateSpaceName)
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        DispatchQueue.main.async {
                            containerSize = proxy.size
                        }
                    }
                }
            )
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
                    fbPlayerInfoStore.send(.initData(displayModel: displayModel))
                }
                
                triggerAnimation()
            }
            .onChange(of: displayModel) {
                if case .fbPlayerInfo = searchStore.poppedView {
                    fbPlayerInfoStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
    
    private func triggerAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.Duration.short) {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
//            withAnimation(.spring(response: AnimationConstants.Duration.medium)) {
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

struct FBPlayerInfoFirstItem: View {
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
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
    @Bindable var fbPlayerInfoStore: StoreOf<FBPlayerInfoStore>
    
    let showContents: Bool
    
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
                            
                            Text(EnNameTranslationUtility.translateByDic(type: .team, input: team.name))
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
        VStack {
            HCapsuleBar()
            
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            HStack {
                if let lastGame = fbPlayerInfoStore.lastGame {
                    VStack {
                        HStack {
                            Text(EnNameTranslationUtility.translateByDic(type: .team, input: lastGame.teams.home.name))
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
                            
                            Text(EnNameTranslationUtility.translateByDic(type: .team, input: lastGame.teams.away.name))
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
        VStack {
            HCapsuleBar()
            
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame = fbPlayerInfoStore.nextGame {
                HStack {
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: nextGame.teams.home.name))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: nextGame.teams.away.name))
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
