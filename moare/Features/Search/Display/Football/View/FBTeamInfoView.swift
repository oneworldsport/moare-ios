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
                
                if let fbTeamInfoStore {
                    /* ---------------------
                       invisible ui
                       - for position
                       --------------------- */
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            // logo, name
                            FBTeamInfoFirstItem(fbTeamInfoStore: fbTeamInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            firstItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            firstItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            // founded, city, country
                            FBTeamInfoSecondItem(fbTeamInfoStore: fbTeamInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            secondItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            secondItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            // venue
                            FBTeamInfoThirdItem(fbTeamInfoStore: fbTeamInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            thirdItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            thirdItemSize = proxy.size
                                        }
                                    }
                                )
                        }
                        
                        // league stats
                        FBTeamInfoFourthItem(fbTeamInfoStore: fbTeamInfoStore)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                        fourthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        fourthItemSize = proxy.size
                                    }
                                }
                            )
                        
                        HStack {
                            // last game stats
                            FBTeamInfoFifthItem(fbTeamInfoStore: fbTeamInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            fifthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            fifthItemSize = proxy.size
                                        }
                                    }
                                )

                            // next game stats
                            FBTeamInfoSixthItem(fbTeamInfoStore: fbTeamInfoStore)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                        sixthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        sixthItemSize = proxy.size
                                    }
                                }
                            )
                        }
                    } // VStack
                    .opacity(0)
                    
                    /* ---------------------
                       visible ui
                       - with animation effect
                       --------------------- */
                    // logo, name
                    FBTeamInfoFirstItem(fbTeamInfoStore: fbTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? firstItemPosition.x : containerSize.width / 2 - firstItemSize.width / 2,
                            y: animatePositions ? firstItemPosition.y : containerSize.height / 2
                        )
                    
                    // founded, city, country
                    FBTeamInfoSecondItem(fbTeamInfoStore: fbTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? secondItemPosition.x : containerSize.width / 2 - secondItemSize.width / 2,
                            y: animatePositions ? secondItemPosition.y : containerSize.height / 2
                        )
                    
                    // venue
                    FBTeamInfoThirdItem(fbTeamInfoStore: fbTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? thirdItemPosition.x : containerSize.width / 2 - thirdItemSize.width / 2,
                            y: animatePositions ? thirdItemPosition.y : containerSize.height / 2
                        )
                    
                    // league stats
                    FBTeamInfoFourthItem(fbTeamInfoStore: fbTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? fourthItemPosition.x : containerSize.width / 2 - fourthItemSize.width / 2,
                            y: animatePositions ? fourthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            if let team = fbTeamInfoStore.team {
                                searchStore.send(.showTeamStats(teamId: team.id))
                            }
                        }
                    
                    // last game stats
                    FBTeamInfoFifthItem(fbTeamInfoStore: fbTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? fifthItemPosition.x : containerSize.width / 2 - fifthItemSize.width / 2,
                            y: animatePositions ? fifthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "previous"))
                        }
                    
                    // next game stats
                    FBTeamInfoSixthItem(fbTeamInfoStore: fbTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? sixthItemPosition.x : containerSize.width / 2 - sixthItemSize.width / 2,
                            y: animatePositions ? sixthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "next"))
                        }
                } // if let fbTeamInfoStore
            } // ZStack
            .padding(.top, 6)
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
                    fbTeamInfoStore.send(.initData(displayModel: displayModel))
                }
                
                triggerAnimation()
            }
            .onChange(of: displayModel) {
                if case .fbTeamInfo = searchStore.poppedView {
                    fbTeamInfoStore?.send(.initData(displayModel: displayModel))
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
                Text("창단연도: ")
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
