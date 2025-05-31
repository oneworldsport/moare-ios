//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAGameStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaGameStatsStore: StoreOf<NBAGameStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBAGameStatsDisplayModel
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var totalScrollDistance: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    
    let coordinateSpaceName = "PlayerStats"
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 10) {
                if let nbaGameStatsStore {
                    /* ---------------------
                       game title, info
                       --------------------- */
                    HStack(spacing: 0) {
                        NBATitle(
                            leagueName: "NBA",
                            leagueSeason: Int(nbaGameStatsStore.displayModel?.game.gameSummary?.season.split(separator: "-").first ?? "2024")!
                        )
                        
                        Text(" | \(NBAUtil.gameType(gameSummary: displayModel.game.gameSummary))")
                            .font(.system(size: 14))
                        
                        Spacer()
                    }
                    .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    
                    /* ---------------------
                       playoffs series text
                       --------------------- */
                    if displayModel.game.gameSummary?.seriesGameNumber != "" {
                        NBAGameStatsPlayoffsSeriesTextContainer(nbaGameStatsStore: nbaGameStatsStore)
                    }
                    
                    NBAGameStatsScoreInfoItem(
                        nbaGameStatsStore: nbaGameStatsStore
                    )
                    
                    Capsule()
                        .fill(.moare)
                        .frame(height: 1)
                        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    
                    if nbaGameStatsStore.displayModel?.game.gameSummary?.gameStatusId != 1 {
                        /* ---------------------
                           team select button
                           --------------------- */
                        NBAGameStatsTeamButtonAdditionalInfoContainer(
                            searchStore: searchStore,
                            nbaGameStatsStore: nbaGameStatsStore
                        )
                        
                        /* ---------------------
                           player stats
                           --------------------- */
                        ScrollView {
                            HStack(spacing: 0) {
                                NBAGameStatsFirstDataList(
                                    nbaGameStatsStore: nbaGameStatsStore,
                                    categoryOffset: $totalScrollDistance
                                )
                                
                                
                                ScrollView(.horizontal) {
                                    NBAGameStatsDataList(
                                        nbaGameStatsStore: nbaGameStatsStore,
                                        categoryOffset: $totalScrollDistance
                                    )
                                }
                                .simultaneousGesture(DragGesture())
                            }
                            .background(
                                GeometryReader { geometry in
                                    let newOffset = geometry.frame(in: .named(coordinateSpaceName)).minY
                                    
                                    Color.clear
                                        .onAppear {
                                            oldOffset = newOffset
                                        }
                                        .onChange(of: newOffset) { newOffset in
                                            let delta = oldOffset - newOffset
                                            totalScrollDistance += delta
                                            oldOffset = newOffset
                                        }
                                }
                            )
                        } // ScrollView
                        .coordinateSpace(name: coordinateSpaceName)
                    } else {
                        Text("경기 시작 후 데이터가 업데이트됩니다.")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                } // if let nbaGameStatsStore
            } // VStack
            .onAppear {
                // init NBAGameStatsStore
                let nbaGameStatsStore: StoreOf<NBAGameStatsStore> = storeManager.getStore(forKey: StoreKeys.nbaGameStatsStore) ?? {
                    let newStore = Store(initialState: NBAGameStatsStore.State()) { NBAGameStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaGameStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaGameStatsStore = nbaGameStatsStore
                }
                
                if searchStore.poppedView == nil {
                    nbaGameStatsStore.send(.initData(displayModel: displayModel))
                }
                
                if displayModel.game.gameSummary?.gameStatusId == 2 {
                    searchStore.send(.refreshGame(category: "basketball"))
                }
            } // onAppear
            .onChange(of: displayModel) {
                if case .nbaGameStats = searchStore.poppedView {
                    nbaGameStatsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
}

struct NBAGameStatsScoreInfoItem: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    var body: some View {
        let displayModel = nbaGameStatsStore.displayModel
        let game = displayModel?.game
        let homeTeamId = nbaGameStatsStore.homeTeamId
        let awayTeamId = nbaGameStatsStore.awayTeamId
        let homeTeamLineScore = nbaGameStatsStore.homeTeamLineScore
        let teamNameDic = nbaGameStatsStore.teamNameDictionary
        
        let gameStatusText: String = {
            switch game?.gameSummary?.gameStatusId {
            case 1:
                return StringConstants.gameNotStartedStr
            case 2:
                if homeTeamLineScore?.ptsOt3 != nil {
                    return StringConstants.NBA.gameOt3
                } else if homeTeamLineScore?.ptsOt2 != nil {
                    return StringConstants.NBA.gameOt2
                } else if homeTeamLineScore?.ptsOt1 != nil {
                    return StringConstants.NBA.gameOt1
                } else if homeTeamLineScore?.ptsQtr4 != nil {
                    return StringConstants.NBA.gameQtr4
                } else if homeTeamLineScore?.ptsQtr3 != nil {
                    return StringConstants.NBA.gameQtr3
                } else if homeTeamLineScore?.ptsQtr2 != nil {
                    return StringConstants.NBA.gameQtr2
                } else if homeTeamLineScore?.ptsQtr1 != nil {
                    return StringConstants.NBA.gameQtr1
                } else {
                    return ""
                }
            case 3:
                return StringConstants.gameFinishedStr
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            if game?.gameSummary?.gameStatusId == 2 {
                return .moare
            } else {
                return .secondary
            }
        }()
        
        HStack {
            VStack {
                URLImage(
                    url: NBAUtil.teamLogoURL(id: homeTeamId),
                    size: .small,
                    isSvg: true
                )
                
                HStack {
                    RoundedBorderText(
                        text: "홈",
                        fontSize: 11,
                        textColor: .moare,
                        radius: 4,
                        strokeColor: .moare
                    )
                    
                    Text(teamNameDic["short_\(homeTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .padding(.leading, 4)
                }
                
                CapsuleButton(
                    text: gameStatusText,
                    color: gameStatusColor
                ) {
                }
                .disabled(true)
                .padding(.vertical, 4)
                
                HStack {
                    RoundedBorderText(
                        text: "원정",
                        fontSize: 11,
                        textColor: .secondary,
                        radius: 4,
                        strokeColor: .secondary
                    )
                    
                    Text(teamNameDic["short_\(awayTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .padding(.leading, 4)
                }
                
                URLImage(
                    url: NBAUtil.teamLogoURL(id: awayTeamId),
                    size: .small,
                    isSvg: true
                )
            } // VStack
            .padding(.top, 26)
            
            NBAGameStatsLineScoreContainer(nbaGameStatsStore: nbaGameStatsStore)
                .frame(height: 127)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct NBAGameStatsLineScoreContainer: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    var body: some View {
        if let homeTeamLineScore = nbaGameStatsStore.homeTeamLineScore,
           let awayTeamLineScore = nbaGameStatsStore.awayTeamLineScore {
            VStack(spacing: 0) {
                HStack {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 26)
                        
                        if let homeTeamPts = homeTeamLineScore.pts, let awayTeamPts = awayTeamLineScore.pts {
                            Text("\(homeTeamPts)")
                                .frame(width: 30, height: nbaGameStatsStore.lineScoreItemHeight)
                                .fontWeight(.medium)
                                .padding(.leading, 4)
                                .padding(.trailing, 8)
                                .foregroundStyle(homeTeamPts >= awayTeamPts ? .moare : .primary)
                        } else {
                            Text("-")
                                .frame(width: 30, height: nbaGameStatsStore.lineScoreItemHeight)
                                .fontWeight(.medium)
                                .padding(.leading, 4)
                                .padding(.trailing, 8)
                                .foregroundStyle(.primary)
                        }
                        
                    }
                    
                    VStack(spacing: 0) {
                        NBAGameStatsLineScoreTitle(lineScore: homeTeamLineScore)
                            .frame(height: 25)
                        
                        Capsule()
                            .fill(.secondary)
                            .frame(height: 1)
                            .opacity(0.5)
                        
                        NBAGameStatsLineScoreItem(
                            nbaGameStatsStore: nbaGameStatsStore,
                            lineScore: homeTeamLineScore
                        )
                        .frame(height: nbaGameStatsStore.lineScoreItemHeight)
                    }
                }
                
                Capsule()
                    .fill(.secondary)
                    .frame(height: 1)
                    .opacity(0.5)
                
                HStack {
                    if let homeTeamPts = homeTeamLineScore.pts, let awayTeamPts = awayTeamLineScore.pts {
                        Text("\(awayTeamPts)")
                            .frame(width: 30, height: nbaGameStatsStore.lineScoreItemHeight)
                            .fontWeight(.medium)
                            .padding(.leading, 4)
                            .padding(.trailing, 8)
                            .foregroundStyle(awayTeamPts >= homeTeamPts ? .moare : .primary)
                    } else {
                        Text("-")
                            .frame(width: 30, height: nbaGameStatsStore.lineScoreItemHeight)
                            .fontWeight(.medium)
                            .padding(.leading, 4)
                            .padding(.trailing, 8)
                            .foregroundStyle(.primary)
                    }
                    
                    NBAGameStatsLineScoreItem(
                        nbaGameStatsStore: nbaGameStatsStore,
                        lineScore: awayTeamLineScore
                    )
                    .frame(height: nbaGameStatsStore.lineScoreItemHeight)
                }
            }
        }
        
    }
}

struct NBAGameStatsLineScoreTitle: View {
    let lineScore: NBALineScore
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            Text("1쿼터")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity)
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            Text("2쿼터")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity)
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            Text("3쿼터")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity)
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            Text("4쿼터")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity)
            if let score = lineScore.ptsOt1, score != 0 {
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                Text("연장 1쿼터")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
            }
            if let score = lineScore.ptsOt2, score != 0 {
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                Text("연장 2쿼터")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
            }
            if let score = lineScore.ptsOt3, score != 0 {
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                Text("연장 3쿼터")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
            }
        }
//        .frame(maxWidth: .infinity, maxHeight: 25)
    }
}

struct NBAGameStatsLineScoreItem: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    let lineScore: NBALineScore
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            Text(lineScore.ptsQtr1.displayOrDash)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            Text(lineScore.ptsQtr2.displayOrDash)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            Text(lineScore.ptsQtr3.displayOrDash)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            Text(lineScore.ptsQtr1.displayOrDash)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
            if let score = lineScore.ptsOt1, score != 0 {
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                Text("\(score)")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
            }
            if let score = lineScore.ptsOt2, score != 0 {
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                Text("\(score)")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
            }
            if let score = lineScore.ptsOt3, score != 0 {
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                Text("\(score)")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
            }
        }
//        .frame(maxWidth: .infinity, maxHeight: nbaGameStatsStore.lineScoreItemHeight)
    }
}

struct NBAGameStatsTeamButtonAdditionalInfoContainer: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    @State var barOffset: CGSize
    
    init(searchStore: StoreOf<SearchStore>, nbaGameStatsStore: StoreOf<NBAGameStatsStore>) {
        self.searchStore = searchStore
        self.nbaGameStatsStore = nbaGameStatsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: nbaGameStatsStore.teamButtonWidth, barWidth: 50), height: 0))
    }
    
    var body: some View {
        let displayModel = nbaGameStatsStore.displayModel
        let teamNameDic = nbaGameStatsStore.teamNameDictionary
        
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    // home
                    NBAGameStatsTeamButton(
                        nbaGameStatsStore: nbaGameStatsStore,
                        team: teamNameDic["short_\(displayModel?.game.gameSummary?.homeTeamId ?? 0)"] ?? "",
                        index: 0
                    )
                    .frame(maxWidth: nbaGameStatsStore.teamButtonWidth)
                    
                    VCapsuleBar()
                        .opacity(0.5)
                    
                    // away
                    NBAGameStatsTeamButton(
                        nbaGameStatsStore: nbaGameStatsStore,
                        team: teamNameDic["short_\(displayModel?.game.gameSummary?.visitorTeamId ?? 0)"] ?? "",
                        index: 1
                    )
                    .frame(maxWidth: nbaGameStatsStore.teamButtonWidth)
                }
                .frame(height: 40)
                
                HCapsuleBar(size: .medium)
                    .offset(barOffset)
            } // VStack
            
            
            HStack(alignment: .top) {
                // refresh button
                if displayModel?.game.gameSummary?.gameStatusId == 2 {
                    Button(action: {
                        searchStore.send(.refreshGame(category: "basketball"))
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .tint(.secondary)
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary, lineWidth: 1)
                            }
                            .opacity(0.6)
                    }
                    .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("날짜: \(CalendarUtil.formatDate(date: displayModel?.game.gameSummary?.date).split(separator: " ").first ?? "")")
                        .font(.system(size: 12))
                    
                    Text("\(CalendarUtil.formatDate(date: displayModel?.game.gameSummary?.date, formatType: .ampm))")
                        .font(.system(size: 12))
                    
                    Text("장소: \(teamNameDic["venue_\(displayModel?.game.gameSummary?.homeTeamId ?? 0)"] ?? "")")
                        .font(.system(size: 12))
                    
                    Text("관중수: \(displayModel?.game.gameInfo?.attendance ?? 0)")
                        .font(.system(size: 12))
                    
                    Text("심판:")
                        .font(.system(size: 12))
                    
                    if let officials = displayModel?.game.officials {
                        ForEach(officials.indices, id: \.self) { index in
                            let item = officials[index]
                            
                            Text("• \(item.firstName + item.lastName)")
                                .font(.system(size: 12))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .onChange(of: nbaGameStatsStore.selectedTeamIndex) {
            moveBar(index: nbaGameStatsStore.selectedTeamIndex)
        }
    }
    
    func moveBar(index: Int) {
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = CGSize(width:getOffsetOfAniCapsuleBar(itemWidth: nbaGameStatsStore.teamButtonWidth, barWidth: 50), height:0)
            default:
                barOffset = CGSize(width: nbaGameStatsStore.barWidth + getOffsetOfAniCapsuleBar(itemWidth: nbaGameStatsStore.teamButtonWidth, barWidth: 50, index: index), height: 0)
            }
        }
    }
}

struct NBAGameStatsTeamButton: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    let team: String
    let index: Int
    
    init(nbaGameStatsStore: StoreOf<NBAGameStatsStore>, team: String, index: Int) {
        self.nbaGameStatsStore = nbaGameStatsStore
        self.team = team
        self.index = index
    }
    
    var body: some View {
        Button(action: {
            nbaGameStatsStore.send(.selectTeam(index: index))
        }) {
            Text(team)
                .lineLimit(2)
                .font(.system(size: 16))
        }
        .foregroundStyle(.primary)
    }
}

struct NBAGameStatsFirstDataList: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    @Binding var categoryOffset: CGFloat
    
    var body: some View {
        let playerStats = nbaGameStatsStore.playerStats
        
        ZStack(alignment: .top) {
            NBAGameStatsFirstCategoryItem()
                .frame(height: nbaGameStatsStore.firstCategoryItemHeight + nbaGameStatsStore.secondCategoryItemHeight)
                .background(.white)
                .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
                .zIndex(1)

            LazyVStack(spacing: 0) {
                ForEach(playerStats, id: \.personId) { value in
                    NBAGameStatsFirstDataListItem(
                        nbaGameStatsStore: nbaGameStatsStore,
                        data: value
                    )
                    .frame(height: nbaGameStatsStore.dataItemHeight)
                }
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    Text("합계(팀 기록)")
                        .font(.system(size: 12))
                    
                    Spacer()

                    Rectangle()
                        .frame(width: 2)
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                }
                .frame(height: nbaGameStatsStore.dataItemHeight)
            }
            .frame(width: 132)
            .padding(.top, nbaGameStatsStore.firstCategoryItemHeight + nbaGameStatsStore.secondCategoryItemHeight)
        }
    }
}

struct NBAGameStatsFirstCategoryItem: View {
    var body: some View {
        HStack(spacing: 0) {
            Text(StringConstants.gameStatsFirstCategory)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 130)
            
            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
    }
}

struct NBAGameStatsFirstDataListItem: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    let data: NBABoxScoreTeamPlayer
    
    var body: some View {
        let playerNameDic = nbaGameStatsStore.playerNameDictionary
        let playerKrName = playerNameDic[(data.firstName + " " + data.familyName).lowercased()] ?? (data.firstName + " " + data.familyName)
        
        HStack(spacing: 0) {
            URLImage(
                url: NBAUtil.playerPhotoURL(id: data.personId),
                customSize: CGSize(width: 25, height: 25)
            )
                .padding(.leading, 8)
                .padding(.trailing, 3)

            Text(playerKrName)
                .font(.system(size: 12))
                .lineLimit(2)
                .frame(maxWidth: 80, alignment: .leading)
            
            // TODO: goals, cards, number, captain
            VStack(spacing: 0) {
                Text(!data.position.isEmpty ? "선발" : "후보")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .opacity(!data.position.isEmpty ? 1 : 0.7)
                
                Text(data.position)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .opacity(0.7)
            }
            .frame(maxWidth: 20)
            .padding(.leading, 2)

            Spacer()

            Rectangle()
                .frame(width: 2)
                .foregroundStyle(.secondary)
                .opacity(0.5)
        }
    }
}

struct NBAGameStatsDataList: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    @Binding var categoryOffset: CGFloat
    
    var body: some View {
        let playerStats = nbaGameStatsStore.playerStats
        
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                NBAGameStatsFirstCategoryList(nbaGameStatsStore: nbaGameStatsStore)
                
                NBAGameStatsSecondCategoryList(nbaGameStatsStore: nbaGameStatsStore)
            }
            .background(.white)
            .zIndex(1)
            .offset(y: categoryOffset < 0 ? 0 : categoryOffset)
            
            LazyVStack(spacing: 0) {
                // TODO: 데이터 잘 바뀌는지 확인 필요
                ForEach(playerStats.indices, id: \.self) { index in
                    let stats = playerStats[index].statistics
                    
                    HStack(spacing: 0) {
                        ForEach(0..<StringConstants.NBA.gameStatsSecondCategories.count) { index in
                            NBAGameStatsDataListItem(
                                nbaGameStatsStore: nbaGameStatsStore,
                                data: stats,
                                index: index,
                                isTotalStats: false
                            )
                            .frame(height: nbaGameStatsStore.dataItemHeight)
                            
                            if index == StringConstants.NBA.gameStatsAttackCategories.count - 1 || index == StringConstants.NBA.gameStatsAttackCategories.count + StringConstants.NBA.gameStatsDefendCategories.count - 1 {
                                VCapsuleBar()
                                    .opacity(0)
                            }
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<StringConstants.NBA.gameStatsSecondCategories.count) { index in
                        if let playerTotalStats = nbaGameStatsStore.playersTotalStats {
                            NBAGameStatsDataListItem(
                                nbaGameStatsStore: nbaGameStatsStore,
                                data: playerTotalStats,
                                index: index,
                                isTotalStats: true
                            )
                            .frame(height: nbaGameStatsStore.dataItemHeight)
                        }
                        
                        if index == StringConstants.NBA.gameStatsAttackCategories.count - 1 || index == StringConstants.NBA.gameStatsAttackCategories.count + StringConstants.NBA.gameStatsDefendCategories.count - 1 {
                            VCapsuleBar()
                                .opacity(0)
                        }
                    }
                }
            }
            .padding(.top, nbaGameStatsStore.firstCategoryItemHeight + nbaGameStatsStore.secondCategoryItemHeight)
        }
    }
}

struct NBAGameStatsFirstCategoryList: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    @State var barOffset: CGSize
    
    init(nbaGameStatsStore: StoreOf<NBAGameStatsStore>) {
        self.nbaGameStatsStore = nbaGameStatsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: nbaGameStatsStore.itemWidth * CGFloat(StringConstants.NBA.gameStatsAttackCategories.count), barWidth: 80), height: 0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(StringConstants.statsFirstCategories.indices, id: \.self) { index in
                        let category = StringConstants.statsFirstCategories[index]
                        
                        NBAGameStatsFirstCategoryListItem(
                            nbaGameStatsStore: nbaGameStatsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                        
                        if index != StringConstants.statsFirstCategories.count - 1 {
                            VCapsuleBar()
                                .opacity(0.5)
                        }
                    }
                }
                .frame(height: nbaGameStatsStore.firstCategoryItemHeight - 2)
            
            HCapsuleBar(size: .large)
                .offset(barOffset)
        }
        .onChange(of: nbaGameStatsStore.firstSelectedIndex) {
            moveBar(index: nbaGameStatsStore.firstSelectedIndex)
        }
    }
    
    func moveBar(index: Int) {
        let itemWidth = nbaGameStatsStore.itemWidth
        let barWidth = nbaGameStatsStore.barWidth
        
        let attackCategoriesCount = CGFloat(StringConstants.NBA.gameStatsAttackCategories.count)
        let defendCategoriesCount = CGFloat(StringConstants.NBA.gameStatsDefendCategories.count)
        let etcCategoriesCount = CGFloat(StringConstants.NBA.gameStatsCommonCategories.count)
        
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: itemWidth * attackCategoriesCount, barWidth: 80), height: 0)
            case 1:
                barOffset = CGSize(width: (itemWidth * attackCategoriesCount) + barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * defendCategoriesCount, barWidth: 80), height: 0)
            default:
                barOffset = CGSize(width: (itemWidth * attackCategoriesCount) + (barWidth * 2) + (itemWidth * defendCategoriesCount) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth * etcCategoriesCount, barWidth: 80), height: 0)
            }
        }
    }
}

struct NBAGameStatsFirstCategoryListItem: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        
        Button(action: {
            nbaGameStatsStore.send(.selectFirstCategory(index: index))
        }) {
            Text(category)
                .font(.system(size: 15, weight: .medium))
                .frame(width: width)
        }
        .foregroundStyle(.primary)
    }
    
    private var width: CGFloat {
        switch index {
        case 0: nbaGameStatsStore.itemWidth * CGFloat(StringConstants.NBA.gameStatsAttackCategories.count)
        case 1: nbaGameStatsStore.itemWidth * CGFloat(StringConstants.NBA.gameStatsDefendCategories.count)
        default: nbaGameStatsStore.itemWidth * CGFloat(StringConstants.NBA.gameStatsCommonCategories.count)
        }
    }
}

struct NBAGameStatsSecondCategoryList: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    @State var barOffset: CGSize
    
    let attackCategoriesCount = StringConstants.NBA.gameStatsAttackCategories.count
    let defendCategoriesCount = StringConstants.NBA.gameStatsDefendCategories.count
    
    init(nbaGameStatsStore: StoreOf<NBAGameStatsStore>) {
        self.nbaGameStatsStore = nbaGameStatsStore
        
        self._barOffset = State(initialValue: CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: nbaGameStatsStore.itemWidth), height: 0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(StringConstants.NBA.gameStatsSecondCategories.indices, id: \.self) { index in
                        let category = StringConstants.NBA.gameStatsSecondCategories[index]
                        
                        NBAGameStatsSecondCategoryListItem(
                            nbaGameStatsStore: nbaGameStatsStore,
                            index: index,
                            category: category
                        )
                        .id(index)
                        
                        if index == attackCategoriesCount - 1 || index == attackCategoriesCount + defendCategoriesCount - 1 {
                            VCapsuleBar()
                                .opacity(0.5)
                        }
                    }
                }
                .frame(height: nbaGameStatsStore.secondCategoryItemHeight - 2)
                .onAppear {
                    // TODO: should decide animation type
                    // scroll and move bar to category that matches with the keyword
                    moveBar(index: nbaGameStatsStore.secondSelectedIndex)
                    
                    withAnimation {
                        proxy.scrollTo(nbaGameStatsStore.secondSelectedIndex, anchor: .leading)
                    }
                }
                .onChange(of: nbaGameStatsStore.firstSelectedIndex) { newValue in
                    if nbaGameStatsStore.shouldScrollCategory {
                        withAnimation {
                            proxy.scrollTo(nbaGameStatsStore.secondSelectedIndex, anchor: .leading)
                        }
                    }
                }
            } // ScrollViewReader
            
            HCapsuleBar()
                .offset(barOffset)
        }
        .onChange(of: nbaGameStatsStore.secondSelectedIndex) { newValue in
            moveBar(index: newValue)
        }
    }
    
    func moveBar(index: Int) {
        let itemWidth = nbaGameStatsStore.itemWidth
        let barWidth = nbaGameStatsStore.barWidth
        
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0..<attackCategoriesCount:
                barOffset = CGSize(width: getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index), height: 0)
            case attackCategoriesCount..<attackCategoriesCount + defendCategoriesCount:
                barOffset = CGSize(width: barWidth + getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index), height: 0)
            default:
                barOffset = CGSize(width: (barWidth * 2) + getOffsetOfAniCapsuleBar(itemWidth: itemWidth, index: index), height: 0)
            }
        }
    }
}

struct NBAGameStatsSecondCategoryListItem: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    let index: Int
    let category: String
    
    var body: some View {
        Button(action: {
            nbaGameStatsStore.send(.selectSecondCategory(index: index))
        }) {
            Text(category)
                .fontWeight(.medium)
                .font(.system(size: nbaGameStatsStore.secondCategoryFontSize))
                .lineLimit(2)
                .frame(width: nbaGameStatsStore.itemWidth)
        }
        .foregroundStyle(.primary)
    }
}

struct NBAGameStatsDataListItem: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    let data: NBAGameBoxScoreStats
    let index: Int
    let isTotalStats: Bool
    
    var body: some View {
        Text(intDataText)
            .font(.system(size: nbaGameStatsStore.dataFontSize))
            .frame(width: nbaGameStatsStore.itemWidth)
    }
    
    private var intDataText: String {
        switch index {
        case 0: "\(data.points)"
        case 1: "\(data.assists)"
        case 2: "\(data.reboundsOffensive)"
        case 3: "\(data.fieldGoalsAttempted)"
        case 4: "\(data.fieldGoalsMade)"
        case 5: "\(data.fieldGoalsPercentage)"
        case 6: "\(data.threePointersAttempted)"
        case 7: "\(data.threePointersMade)"
        case 8: "\(data.threePointersPercentage)"
        case 9: "\(data.freeThrowsAttempted)"
        case 10: "\(data.freeThrowsMade)"
        case 11: "\(data.freeThrowsPercentage)"
        case 12: "\(data.reboundsDefensive)"
        case 13: "\(data.blocks)"
        case 14: "\(data.steals)"
        case 15: "\(data.reboundsTotal)"
        case 16: "\(data.turnovers)"
        case 17: "\(data.foulsPersonal)"
        case 18: "\(data.plusMinusPoints)"
        case 19: isTotalStats ? "" : data.minutes
        default: ""
        }
    }
}

struct NBAGameStatsPlayoffsSeriesTextContainer: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    var body: some View {
        let teamNameDic = nbaGameStatsStore.teamNameDictionary
        
        if let series = nbaGameStatsStore.displayModel?.game.seasonSeries {
            HStack {
                // NOTE: 게임별 시리즈 스코어 정보를 가져올 방법을 찾지 못해서 일단은 현재 시리즈 스코어로 표시
                Text("현재 시리즈 스코어: ")
                    .font(.system(size: 14))
                
                Text(teamNameDic["short_\(series.homeTeamId)"] ?? "")
                    .font(.system(size: 14))
                
                Text("\(series.homeTeamWins)")
                    .foregroundStyle(series.homeTeamWins >= series.homeTeamLosses ? .moare : .primary)
                
                Text("-")
                    .font(.system(size: 14))
                
                Text("\(series.homeTeamLosses)")
                    .foregroundStyle(series.homeTeamLosses >= series.homeTeamWins ? .moare : .primary)
                
                Text(teamNameDic["short_\(series.visitorTeamId)"] ?? "")
                    .font(.system(size: 14))
                
                Spacer()
            }
            .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        }
    }
}
