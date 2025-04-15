//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATeamInfoDisplayModel
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "NBATeamInfoView"
    
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
                
                if let nbaTeamInfoStore {
                    /* ---------------------
                       invisible ui
                       - for position
                       --------------------- */
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            // logo, team, name
                            NBATeamInfoFirstItem(nbaTeamInfoStore: nbaTeamInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            firstItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            firstItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            // founded, state and city, conference and division
                            NBATeamInfoSecondItem(nbaTeamInfoStore: nbaTeamInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            secondItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            secondItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            // venue
                            NBATeamInfoThirdItem(nbaTeamInfoStore: nbaTeamInfoStore)
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
                        NBATeamInfoFourthItem(nbaTeamInfoStore: nbaTeamInfoStore)
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
                            NBATeamInfoFifthItem(nbaTeamInfoStore: nbaTeamInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            fifthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            fifthItemSize = proxy.size
                                        }
                                    }
                                )

                            // next game stats
                            NBATeamInfoSixthItem(nbaTeamInfoStore: nbaTeamInfoStore)
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
                    // logo, team, name
                    NBATeamInfoFirstItem(nbaTeamInfoStore: nbaTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? firstItemPosition.x : containerSize.width / 2 - firstItemSize.width / 2,
                            y: animatePositions ? firstItemPosition.y : containerSize.height / 2
                        )
                    
                    // founded, state and city, conference and division
                    NBATeamInfoSecondItem(nbaTeamInfoStore: nbaTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? secondItemPosition.x : containerSize.width / 2 - secondItemSize.width / 2,
                            y: animatePositions ? secondItemPosition.y : containerSize.height / 2
                        )
                    
                    // venue
                    NBATeamInfoThirdItem(nbaTeamInfoStore: nbaTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? thirdItemPosition.x : containerSize.width / 2 - thirdItemSize.width / 2,
                            y: animatePositions ? thirdItemPosition.y : containerSize.height / 2
                        )
                    
                    // league stats
                    NBATeamInfoFourthItem(nbaTeamInfoStore: nbaTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? fourthItemPosition.x : containerSize.width / 2 - fourthItemSize.width / 2,
                            y: animatePositions ? fourthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            if let team = nbaTeamInfoStore.displayModel?.team {
                                searchStore.send(.showTeamStats(teamId: team.id))
                            }
                        }
                    
                    // last game stats
                    NBATeamInfoFifthItem(nbaTeamInfoStore: nbaTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? fifthItemPosition.x : containerSize.width / 2 - fifthItemSize.width / 2,
                            y: animatePositions ? fifthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "previous"))
                        }
                    
                    // next game stats
                    NBATeamInfoSixthItem(nbaTeamInfoStore: nbaTeamInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? sixthItemPosition.x : containerSize.width / 2 - sixthItemSize.width / 2,
                            y: animatePositions ? sixthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "next"))
                        }
                } // if let nbaTeamInfoStore
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
                // init NBATeamInfoStore
                let nbaTeamInfoStore: StoreOf<NBATeamInfoStore> = storeManager.getStore(forKey: StoreKeys.nbaTeamInfoStore) ?? {
                    let newStore = Store(initialState: NBATeamInfoStore.State()) { NBATeamInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaTeamInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.nbaTeamInfoStore = nbaTeamInfoStore
                }
                
                if searchStore.poppedView == nil {
                    nbaTeamInfoStore.send(.initData(displayModel: displayModel))
                }
                
                triggerAnimation()
            }
            .onChange(of: displayModel) {
                if case .nbaTeamInfo = searchStore.poppedView {
                    nbaTeamInfoStore?.send(.initData(displayModel: displayModel))
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

struct NBATeamInfoFirstItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    let showContents: Bool
    
    init(nbaTeamInfoStore: StoreOf<NBATeamInfoStore>, showContents: Bool = true) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaTeamInfoStore.displayModel
        let team = displayModel?.team
        
        if let team {
            VStack {
                HCapsuleBar()
                
                URLImage(url: NBAUtil.teamLogoURL(id: team.id), isSvg: true)
                    .opacity(showContents ? 1 : 0)
                
                Text(nbaTeamInfoStore.teamNameDictionary["full_\(team.id)"] ?? team.fullName)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
                
                Text(team.fullName)
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .lineLimit(2)
                    .opacity(showContents ? 1 : 0)
            }
            .frame(maxWidth: 130)
        } // if let team
    }
}

struct NBATeamInfoSecondItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    let showContents: Bool
    
    init(nbaTeamInfoStore: StoreOf<NBATeamInfoStore>, showContents: Bool = true) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaTeamInfoStore.displayModel
        let team = displayModel?.team
        
        if let team {
            VStack(alignment:.leading) {
                // added HStack to position Capsule at center
                HStack {
                    HCapsuleBar()
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    Text("창단연도: ")
                        .font(.system(size: 15))
                    
                    Text("\(team.yearFounded)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("연고지: ")
                        .font(.system(size: 15))
                    
                    Text(team.state)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.vertical, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("컨퍼런스/디비전: ")
                        .font(.system(size: 15))
                    
                    Text("\(team.teamConference) / \(team.teamDivision)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            } // VStack
            .frame(maxWidth: 130)
        } // if let team
    }
}

struct NBATeamInfoThirdItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    let showContents: Bool
    
    init(nbaTeamInfoStore: StoreOf<NBATeamInfoStore>, showContents: Bool = true) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaTeamInfoStore.displayModel
        let team = displayModel?.team
        let venue = displayModel?.venue
        
        if let venue, let team {
            VStack(alignment:.leading) {
                // added HStack to position Capsule at center
                HStack {
                    HCapsuleBar()
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    Text("홈구장: ")
                        .font(.system(size: 15))
                    
                    Text(nbaTeamInfoStore.teamNameDictionary["venue_\(team.id)"] ?? venue.name)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("좌석수: ")
                        .font(.system(size: 15))
                    
                    Text("\(venue.capacity)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.vertical, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("개장: ")
                        .font(.system(size: 15))
                    
                    Text("\(venue.opened)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            } // VStack
            .frame(maxWidth: 130)
        } // if let venue
    }
}

struct NBATeamInfoFourthItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    let showContents: Bool
    
    init(nbaTeamInfoStore: StoreOf<NBATeamInfoStore>, showContents: Bool = true) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaTeamInfoStore.displayModel
        let team = displayModel?.team
        let stats = displayModel?.stats
        
        if let team {
            VStack {
                HCapsuleBar()
                
                NBATitle(
                    leagueName: "NBA 정규시즌",
                    leagueSeason: Int(stats?.groupValue.split(separator: "-").first ?? "2024")!
                )
                .opacity(showContents ? 1 : 0)
                
                if let stats {
                    HStack {
                        FBStatDataItem(
                            category: "서부 컨퍼런스 순위",
                            data: "\(team.confRank)",
                            customCategoryFontSize: 13
                        )
                        FBStatDataItem(
                            category: "승",
                            data: "\(stats.wins)"
                        )
                        FBStatDataItem(
                            category: "패",
                            data: "\(stats.losses)"
                        )
                        FBStatDataItem(
                            category: "경기당 득점",
                            data: "\(stats.ptsPG)"
                        )
                    }
                    .opacity(showContents ? 1 : 0)
                }
            }
            .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        } // if let team
    }
}

struct NBATeamInfoFifthItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    let showContents: Bool
    
    init(nbaTeamInfoStore: StoreOf<NBATeamInfoStore>, showContents: Bool = true) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaTeamInfoStore.displayModel
        let lastGame = displayModel?.lastGame
        let teamNameDic = nbaTeamInfoStore.teamNameDictionary
        
        VStack {
            HCapsuleBar()
            
            Text("최근경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let lastGame {
                let homeTeam = lastGame.boxScoreTraditional?.homeTeam
                let awayTeam = lastGame.boxScoreTraditional?.awayTeam
                let homeTeamScore = lastGame.lineScore.first { $0.teamId == homeTeam?.teamId }?.pts ?? 0
                let awayTeamScore = lastGame.lineScore.first { $0.teamId == awayTeam?.teamId }?.pts ?? 0
                
                HStack {
                    Text(homeTeam == nil ? "" : teamNameDic["short_\(homeTeam!.teamId)"] ?? homeTeam!.teamCity)
                        .font(.system(size: 15))
                        .lineLimit(1)
                    
                    Text("\(homeTeamScore)")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundStyle((homeTeamScore >= awayTeamScore) ? .moare : .primary)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text("\(awayTeamScore)")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundStyle((awayTeamScore >= homeTeamScore) ? .moare : .primary)
                    
                    Text(awayTeam == nil ? "" : teamNameDic["short_\(awayTeam!.teamId)"] ?? awayTeam!.teamCity)
                        .font(.system(size: 15))
                        .lineLimit(1)
                }
                .padding(.vertical, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: lastGame.gameSummary?.date))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        } // VStack
        .frame(maxWidth: UIConstants.Width.screenWidth / 2)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct NBATeamInfoSixthItem: View {
    @Bindable var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>
    private let showContents: Bool
    
    init(nbaTeamInfoStore: StoreOf<NBATeamInfoStore>, showContents: Bool = true) {
        self.nbaTeamInfoStore = nbaTeamInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaTeamInfoStore.displayModel
        let nextGame = displayModel?.nextGame
        let teamNameDic = nbaTeamInfoStore.teamNameDictionary
        
        VStack {
            HCapsuleBar()
            
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame {
                let lastMeeting = nextGame.lastMeeting
                
                HStack {
                    Text(lastMeeting?.lastGameHomeTeamId == nil ? "" : teamNameDic["short_\(lastMeeting!.lastGameHomeTeamId)"] ?? lastMeeting!.lastGameHomeTeamCity)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                    
                    Text(" vs ")
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                    
                    Text(lastMeeting?.lastGameVisitorTeamId == nil ? "" : teamNameDic["short_\(lastMeeting!.lastGameVisitorTeamId)"] ?? lastMeeting!.lastGameVisitorTeamCity)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                .padding(.vertical, 4)
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.gameSummary?.date))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            }
        } // VStack
        .frame(maxWidth: UIConstants.Width.screenWidth / 2)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}
