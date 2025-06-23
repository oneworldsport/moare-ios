//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBAPlayerInfoDisplayModel
    
    /* ---------------------
       animation
       --------------------- */
    let coordinateSpaceName = "NBAPlayerInfoView"
    
    @State private var firstItemPosition: CGPoint = .zero
    @State private var secondItemPosition: CGPoint = .zero
    @State private var thirdItemPosition: CGPoint = .zero
    @State private var fourthItemPosition: CGPoint = .zero
    @State private var fifthItemPosition: CGPoint = .zero
    @State private var sixthItemPosition: CGPoint = .zero
    @State private var seventhItemPosition: CGPoint = .zero
    @State private var eighthItemPosition: CGPoint = .zero
    @State private var ninthItemPosition: CGPoint = .zero
    
    @State private var containerSize: CGSize = .zero
    @State private var firstItemSize: CGSize = .zero
    @State private var secondItemSize: CGSize = .zero
    @State private var thirdItemSize: CGSize = .zero
    @State private var fourthItemSize: CGSize = .zero
    @State private var fifthItemSize: CGSize = .zero
    @State private var sixthItemSize: CGSize = .zero
    @State private var seventhItemSize: CGSize = .zero
    @State private var eighthItemSize: CGSize = .zero
    @State private var ninthItemSize: CGSize = .zero
    
    @State private var animatePositions = false
    @State private var showContents = false
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ZStack(alignment: .topLeading) {
                Spacer() // empty space for smooth animation effect
                    .frame(maxWidth: .infinity, maxHeight: 0)
                
                if let nbaPlayerInfoStore {
                    /* ---------------------
                       invisible ui
                       - for position
                       --------------------- */
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            NBAPlayerInfoFirstItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            firstItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            firstItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            Spacer()
                            
                            NBAPlayerInfoSecondItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            secondItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            secondItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            Spacer()
                            
                            NBAPlayerInfoThirdItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            thirdItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            thirdItemSize = proxy.size
                                        }
                                    }
                                )
                        }
                        
                        HStack(alignment: .top) {
                            NBAPlayerInfoFourthItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            fourthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            fourthItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            NBAPlayerInfoFifthItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            fifthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            fifthItemSize = proxy.size
                                        }
                                    }
                                )
                            
                            NBAPlayerInfoSixthItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                            sixthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                            sixthItemSize = proxy.size
                                        }
                                    }
                                )
                        }
                        
                        NBAPlayerInfoSeventhItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                        seventhItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        seventhItemSize = proxy.size
                                    }
                                }
                            )
                        
                        NBAPlayerInfoEighthItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                        eighthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        eighthItemSize = proxy.size
                                    }
                                }
                            )
                        
                        NBAPlayerInfoNinthItem(nbaPlayerInfoStore: nbaPlayerInfoStore)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.frame(in: .named(coordinateSpaceName)).origin) {
                                        ninthItemPosition = proxy.frame(in: .named(coordinateSpaceName)).origin
                                        ninthItemSize = proxy.size
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
                    NBAPlayerInfoFirstItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? firstItemPosition.x : containerSize.width / 2 - firstItemSize.width / 2,
                            y: animatePositions ? firstItemPosition.y : containerSize.height / 2
                        )
                    
                    // logo, team, name
                    NBAPlayerInfoSecondItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? secondItemPosition.x : containerSize.width / 2 - secondItemSize.width / 2,
                            y: animatePositions ? secondItemPosition.y : containerSize.height / 2
                        )
                    
                    // jersey, position
                    NBAPlayerInfoThirdItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? thirdItemPosition.x : containerSize.width / 2 - thirdItemSize.width / 2,
                            y: animatePositions ? thirdItemPosition.y : containerSize.height / 2
                        )
                    
                    // from school/team, draft info, career info
                    NBAPlayerInfoFourthItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? fourthItemPosition.x : containerSize.width / 2 - fourthItemSize.width / 2,
                            y: animatePositions ? fourthItemPosition.y : containerSize.height / 2
                        )
                    
                    // country, birth, age
                    NBAPlayerInfoFifthItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? fifthItemPosition.x : containerSize.width / 2 - fifthItemSize.width / 2,
                            y: animatePositions ? fifthItemPosition.y : containerSize.height / 2
                        )
                    
                    // weight(kg/pound), height(cm/feet)
                    NBAPlayerInfoSixthItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? sixthItemPosition.x : containerSize.width / 2 - sixthItemSize.width / 2,
                            y: animatePositions ? sixthItemPosition.y : containerSize.height / 2
                        )
                    
                    // league stats
                    NBAPlayerInfoSeventhItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? seventhItemPosition.x : containerSize.width / 2 - seventhItemSize.width / 2,
                            y: animatePositions ? seventhItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            if let player = nbaPlayerInfoStore.baseInfo.displayModel?.info {
                                searchStore.send(.showPlayerStats(playerId: player.personId))
                            }
                        }
                    
                    // last game
                    NBAPlayerInfoEighthItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? eighthItemPosition.x : containerSize.width / 2 - eighthItemSize.width / 2,
                            y: animatePositions ? eighthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "previous"))
                        }
                    
                    // next game
                    NBAPlayerInfoNinthItem(nbaPlayerInfoStore: nbaPlayerInfoStore, showContents: showContents)
                        .offset(
                            x: animatePositions ? ninthItemPosition.x : containerSize.width / 2 - ninthItemSize.width / 2,
                            y: animatePositions ? ninthItemPosition.y : containerSize.height / 2
                        )
                        .onTapGesture {
                            searchStore.send(.showGameStats(gameType: "next"))
                        }
                } // if let nbaPlayerInfoStore
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
                // init NBAPlayerInfoStore
                let nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore> = storeManager.getStore(forKey: StoreKeys.nbaPlayerInfoStore) ?? {
                    let newStore = Store(initialState: NBAPlayerInfoStore.State()) { NBAPlayerInfoStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaPlayerInfoStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    self.nbaPlayerInfoStore = nbaPlayerInfoStore
                }
                
                if searchStore.poppedView == nil {
                    nbaPlayerInfoStore.send(.baseInfo(.initData(displayModel: displayModel)))
                }
                
                triggerAnimation()
            }
            .onChange(of: displayModel) {
                if case .nbaPlayerInfo = searchStore.poppedView {
                    nbaPlayerInfoStore?.send(.baseInfo(.initData(displayModel: displayModel)))
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

struct NBAPlayerInfoFirstItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        
        if let player = displayModel?.info {
            VStack {
                HCapsuleBar()
                
                URLImage(url: NBAUtil.playerPhotoURL(id: player.personId))
                    .opacity(showContents ? 1 : 0)
                
                Text(nbaPlayerInfoStore.baseInfo.playerNameDictionary["\(player.personId)"] ?? player.displayFirstLast)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
                
                Text(player.displayFirstLast)
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .lineLimit(2)
                    .opacity(showContents ? 1 : 0)
            }
            .frame(maxWidth: 130)
        }
    }
}

struct NBAPlayerInfoSecondItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        
        if let player = displayModel?.info {
            VStack {
                HCapsuleBar()
                
                URLImage(url: NBAUtil.teamLogoURL(id: player.teamId), isSvg: true)
                    .opacity(showContents ? 1 : 0)
                
                Text(nbaPlayerInfoStore.baseInfo.teamNameDictionary["full_\(player.teamId)"] ?? "\(player.teamCity) \(player.teamName)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .opacity(showContents ? 1 : 0)
            }
            .frame(maxWidth: 130)
        }
    }
}

struct NBAPlayerInfoThirdItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        
        if let player = displayModel?.info {
            VStack(alignment:.leading) {
                // added HStack to position Capsule at center
                HStack {
                    HCapsuleBar()
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    Text("등번호: ")
                        .font(.system(size: 15))
                    
                    Text(player.jersey)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("포지션: ")
                        .font(.system(size: 15))
                    
                    Text(player.position)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.top, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
            }
            .frame(maxWidth: 130)
        }
    }
}

struct NBAPlayerInfoFourthItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        
        if let player = displayModel?.info {
            VStack(alignment:.leading) {
                // added HStack to position Capsule at center
                HStack {
                    HCapsuleBar()
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("출신(학교 또는 팀): ")
                        .font(.system(size: 15))
                    
                    Text(player.school)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("드래프트 순위/년도: ")
                        .font(.system(size: 15))
                    
                    Text("\(player.draftNumber) / \(player.draftYear)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.vertical, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("경력: ")
                        .font(.system(size: 15))
                    
                    Text("\(player.fromYear)~현재 (\(player.seasonExp + 1))년차")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
            .frame(maxWidth: 130)
        }
    }
}

struct NBAPlayerInfoFifthItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        
        if let player = displayModel?.info {
            VStack(alignment:.leading) {
                // added HStack to position Capsule at center
                HStack {
                    HCapsuleBar()
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    Text("국적: ")
                        .font(.system(size: 15))
                    
                    Text(player.country)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("출생: ")
                        .font(.system(size: 15))
                    
                    Text(player.birthdate.split(separator: "T").first ?? "")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.top, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
                
                HStack(spacing: 0) {
                    Text("나이: ")
                        .font(.system(size: 15))
                    
                    Text("\(CalendarUtil.calculateAge(from: player.birthdate))")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
            }
            .frame(maxWidth: 130)
        }
    }
}

struct NBAPlayerInfoSixthItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        
        if let displayModel {
            let player = displayModel.info
            let components = player.height.split(separator: "-")
            let playerCmHeight = Int(NBAUtil.toCm(feet: Int(components.first ?? "0")!, inches: Int(components.last ?? "0")!))
            let playerKgWeight = Int((Double(player.weight) ?? 0).toKg())
            
            VStack(alignment:.leading) {
                // added HStack to position Capsule at center
                HStack {
                    HCapsuleBar()
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("키(cm/ft): ")
                        .font(.system(size: 15))
                    
                    Text("\(playerCmHeight) / \(player.height)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .opacity(showContents ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("몸무게(kg/lb): ")
                        .font(.system(size: 15))
                    
                    Text("\(playerKgWeight) / \(player.weight)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .padding(.top, UIConstants.Padding.defalutVPadding)
                .opacity(showContents ? 1 : 0)
            }
            .frame(maxWidth: 130)
        }
    }
}

struct NBAPlayerInfoSeventhItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        
        if let stats = displayModel?.stats {
            VStack {
                HCapsuleBar()
                
                NBATitle(
                    leagueName: "NBA 정규시즌",
                    leagueSeason: Int(stats.groupValue.split(separator: "-").first ?? "2024")!
                )
                .opacity(showContents ? 1 : 0)
                
                HStack {
                    FBStatDataItem(
                        category: "경기수",
                        data: "\(stats.gp)",
                        customCategoryFontSize: 11
                    )
                    FBStatDataItem(
                        category: "경기당 득점",
                        data: "\(stats.ptsPG)",
                        customCategoryFontSize: 11
                    )
                    FBStatDataItem(
                        category: "경기당 리바운드",
                        data: "\(stats.rebPG)",
                        customCategoryFontSize: 11
                    )
                    FBStatDataItem(
                        category: "경기당 어시스트",
                        data: "\(stats.astPG)",
                        customCategoryFontSize: 11
                    )
                    FBStatDataItem(
                        category: "출전 경기 승률",
                        data: "\(stats.winsPct)",
                        customCategoryFontSize: 11
                    )
                }
                .opacity(showContents ? 1 : 0)
            }
            .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        }
    }
}

struct NBAPlayerInfoEighthItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        let teamNameDic = nbaPlayerInfoStore.baseInfo.teamNameDictionary
        
        if let displayModel {
            let lastGame = displayModel.lastGame
            let lastGamePlayerStats = displayModel.lastGamePlayerStats
            
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
                        VStack {
                            HStack {
                                Text(homeTeam == nil ? "" : teamNameDic["short_\(homeTeam!.teamId)"] ?? homeTeam!.teamCity)
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
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
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .lineLimit(1)
                            }
                            .frame(height: 25)
                            
                            Text(CalendarUtil.formatDate(date: lastGame.gameSummary?.date))
                                .font(.system(size: 15))
                                .frame(maxHeight: nbaPlayerInfoStore.itemHeight)
                        }
                        .padding(.trailing, 4)
                        
                        FBStatDataItem(
                            category: "출전시간",
                            data: lastGamePlayerStats == nil ? "" : lastGamePlayerStats!.position.isEmpty ? "후보" : "선발"
                            ,
                            customCategoryFontSize: 12,
                            customDataFontSize: 15,
                            customWidth: 80
                        )
                        
                        FBStatDataItem(
                            category: "골",
                            data: "\(lastGamePlayerStats?.statistics.points ?? 0)",
                            customCategoryFontSize: 12
                        )
                        FBStatDataItem(
                            category: "리바운드",
                            data: "\(lastGamePlayerStats?.statistics.reboundsTotal ?? 0)",
                            customCategoryFontSize: 12
                        )
                        FBStatDataItem(
                            category: "어시스트",
                            data: "\(lastGamePlayerStats?.statistics.assists ?? 0)",
                            customCategoryFontSize: 12
                        )
                    }
                    .opacity(showContents ? 1 : 0)
                } // let lastGame
            } // VStack
            .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        }
    }
}

struct NBAPlayerInfoNinthItem: View {
    @Bindable var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>
    
    let showContents: Bool
    
    init(nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>, showContents: Bool = true) {
        self.nbaPlayerInfoStore = nbaPlayerInfoStore
        self.showContents = showContents
    }
    
    var body: some View {
        let displayModel = nbaPlayerInfoStore.baseInfo.displayModel
        let nextGame = displayModel?.nextGame
        let teamNameDic = nbaPlayerInfoStore.baseInfo.teamNameDictionary
        
        VStack {
            HCapsuleBar()
            
            Text("다음경기")
                .fontWeight(.medium)
                .opacity(showContents ? 1 : 0)
            
            if let nextGame {
                let lastMeeting = nextGame.lastMeeting
                
                HStack {
                    Text(lastMeeting?.lastGameHomeTeamId == nil ? "" : teamNameDic["short_\(lastMeeting!.lastGameHomeTeamId)"] ?? lastMeeting!.lastGameHomeTeamCity)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(" vs ")
                        .fontWeight(.semibold)
                    
                    Text(lastMeeting?.lastGameVisitorTeamId == nil ? "" : teamNameDic["short_\(lastMeeting!.lastGameVisitorTeamId)"] ?? lastMeeting!.lastGameVisitorTeamCity)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
                .opacity(showContents ? 1 : 0)
                
                Text(CalendarUtil.formatDate(date: nextGame.gameSummary?.date))
                    .font(.system(size: 15))
                    .opacity(showContents ? 1 : 0)
            } // let nextGame
        } // VStack
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}
