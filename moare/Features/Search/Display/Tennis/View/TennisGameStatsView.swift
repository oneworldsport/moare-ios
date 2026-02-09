//
//  TennisGameStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

import SwiftUI
import ComposableArchitecture

struct TennisGameStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<TennisGameStatsStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseGameStats.displayModel
        let game = displayModel.game
        let gameInfo = displayModel.game.gameInfo
        let statusCode = game.gameInfo.status?.code ?? 0
        
        let teamCategories: [GameStatsTeamState] = [
            GameStatsTeamState(
                name: "득점 흐름",
                imageUrl: nil
            ),
            GameStatsTeamState(
                name: "선수 기록",
                imageUrl: nil
            )
        ]
        
        let gameDetailTitle = "날짜: \n\n도시: \n경기장: \n코트 종류: "
        let gameDetailContent: String = {
            var result = ""
            result += "\(CalendarUtil.formatDate(date: gameInfo.gameDate).split(separator: " ").first ?? "")\n"
            result += "\(CalendarUtil.formatDate(date: gameInfo.gameDate, outputFormatType: .ampm))\n"
            result += "\(gameInfo.venue?.city?.name ?? "")\n"
            result += "\(gameInfo.venue?.name ?? "")\n"
            result += "\(StringConstants.Tennis.groundTypeKr(groundType: gameInfo.groundType))\n"
            
            return result
        }()
        
        VStack {
            if show {
                GameStatsViewContainer(
                    state: GameStatsContainerState(
                        shouldShowStats: statusCode != Constants.GameStatus.Tennis.notStarted,
                        shouldShowRefreshButton: Constants.GameStatus.Tennis.liveList.contains(statusCode),
                        teamCategories: teamCategories,
                        teamCategorySelectedIndex: store.baseGameStats.teamCategorySelectedIndex,
                        gameDetailTitle: gameDetailTitle,
                        gameDetailContent: gameDetailContent,
                        firstStatsCategories: [],
                        firstStatsPlayerList: [],
                    ),
                    actions: GameStatsContainerActions(
                        teamCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectTeam(index: index)))
                        },
                        firstStatsCategoryButtonAction: { index in
                        },
                        refreshButtonAction: {
                            await store.send(.refreshGame()).finish()
                        }
                    ),
                    shouldUseCustomStatsContent: true,
                    titleContent: {
                        HStack(spacing: 0) {
                            TennisTournamentTitle(leagueId: displayModel.leagueId, season: displayModel.season)
                            
                            Text(" | ")
                                .font(.system(size: 14))
                            
                            Text("\(displayModel.leagueKrName) \(displayModel.roundName)")
                                .font(.system(size: 14))
                            
                            Spacer()
                        }
                        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    },
                    gameContent: {
                        TennisGameStatsScoreInfoContainer(store: store)
                    },
                    customStatsContent: {
                        if store.baseGameStats.teamCategorySelectedIndex == 0 {
                            TennisGameStatsPointByPointContainer(store: store)
                        } else {
                            TennisGameStatsPlayerStatsContainer(store: store)
                        }
                    }
                )
            }
        }
        .onAppear {
            if !didPop {
                store.send(.baseGameStats(.initData))
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct TennisGameStatsScoreInfoContainer: View {
    @Bindable var store: StoreOf<TennisGameStatsStore>
    
    @State private var borderTextWidth: CGFloat = 0
    
    var body: some View {
        let displayModel = store.baseGameStats.displayModel
        let gameInfo = displayModel.game.gameInfo
        let homeTeam = gameInfo.homeTeam
        let awayTeam = gameInfo.awayTeam
        let gameStatus = gameInfo.status?.code ?? Constants.GameStatus.Tennis.notStarted
        let teamNameDic = store.baseGameStats.teamNameDictionary
        let homeTeamDefaultName = store.isDoubles ? (homeTeam?.name ?? "") : (homeTeam?.shortName ?? "")
        let awayTeamDefaultName = store.isDoubles ? (awayTeam?.name ?? "") : (awayTeam?.shortName ?? "")
        
        HStack(alignment: .bottom, spacing: 2) {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    URLImage(
                        url: Util.teamLogoURL(leagueId: displayModel.leagueId, teamId: homeTeam?.id),
                        size: .small
                    )
                    
                    Text(teamNameDic["short_\(homeTeam?.id ?? 0)"] ?? homeTeamDefaultName)
                        .font(.system(size: 13))
                        .lineLimit(2)
                    
                    if gameInfo.isGameFinished && gameInfo.isHomeWinner {
                        RoundedBorderText(
                            text: "승",
                            fontSize: 11,
                            textColor: .moare,
                            radius: 4,
                            strokeColor: .moare
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                CapsuleButton(
                    text: Constants.GameStatus.tennisGameStatusText(status: gameStatus),
                    color: Constants.GameStatus.gameStatusColor(leagueId: displayModel.leagueId, status: String(gameStatus))
                ) {
                }
                .disabled(true)
                .padding(.vertical, 4)
                
                HStack(spacing: 4) {
                    URLImage(
                        url: Util.teamLogoURL(leagueId: displayModel.leagueId, teamId: awayTeam?.id),
                        size: .small
                    )
                    
                    Text(teamNameDic["short_\(awayTeam?.id ?? 0)"] ?? awayTeamDefaultName)
                        .font(.system(size: 13))
                        .lineLimit(2)
                    
                    if gameInfo.isGameFinished && !gameInfo.isHomeWinner {
                        RoundedBorderText(
                            text: "승",
                            fontSize: 11,
                            textColor: .moare,
                            radius: 4,
                            strokeColor: .moare
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } // VStack
            .frame(width: 110)
            
            TennisGameStatsSetScoreContainer(
                store: store
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct TennisGameStatsSetScoreContainer: View {
    @Bindable var store: StoreOf<TennisGameStatsStore>
    
    var body: some View {
        let gameInfo = store.baseGameStats.displayModel.game.gameInfo
        let homeScore = gameInfo.homeScore?.display
        let awayScore = gameInfo.awayScore?.display
        
        HStack(alignment: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                if let homeScore, let awayScore {
                    Text("\(homeScore)")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(homeScore >= awayScore ? .moare : .primary)
                } else {
                    Text("-")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(.primary)
                }
                
                Capsule()
                    .fill(.secondary)
                    .frame(width: 42, height: 1)  // width: 30 + 8 + 4
                    .opacity(0.5)
                
                if let homeScore, let awayScore {
                    Text("\(awayScore)")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(awayScore >= homeScore ? .moare : .primary)
                } else {
                    Text("-")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(.primary)
                }
            }
            
            VStack(spacing: 0) {
                TennisGameStatsSetScoreTitle(store: store)
                
                Capsule()
                    .fill(.secondary)
                    .frame(height: 1)
                    .opacity(0.5)
                
                TennisGameStatsSetScoreItem(store: store)
            }
        }
        .frame(height: 127) // 25 + 1 + 50 + 1 + 50
    }
}

struct TennisGameStatsSetScoreTitle: View {
    @Bindable var store: StoreOf<TennisGameStatsStore>
    
    var body: some View {
        let gameInfo = store.baseGameStats.displayModel.game.gameInfo
        
        HStack(spacing: 0) {
            ForEach(1...gameInfo.defaultPeriodCount, id: \.self) { index in
                VCapsuleBar()
                    .opacity(0.5)
                Text("\(index)세트")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 25)
    }
}

struct TennisGameStatsSetScoreItem: View {
    @Bindable var store: StoreOf<TennisGameStatsStore>
    
    var body: some View {
        let gameInfo = store.baseGameStats.displayModel.game.gameInfo
        let homeSetScore = gameInfo.homeScore
        let awaySetScore = gameInfo.awayScore
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<gameInfo.defaultPeriodCount, id: \.self) { index in
                    let homePeriodScore = homeSetScore?.periods[index]
                    let homeTieBreakScore = homeSetScore?.periodsTieBreak[index]
                    let awayPeriodScore = awaySetScore?.periods[index]
                    
                    let isWinner = if homePeriodScore == 7 {
                        true
                    } else if let homePeriodScore, let awayPeriodScore {
                        (homePeriodScore == 6) && (homePeriodScore - awayPeriodScore >= 2)
                    } else {
                        false
                    }
                        
                    VCapsuleBar()
                        .opacity(0.5)
                    ZStack {
                        Text(homePeriodScore.displayOrDash)
                            .fontWeight(.medium)
                            .foregroundStyle(isWinner ? .moare : .primary)
                        
                        if let homeTieBreakScore {
                            Text("\(homeTieBreakScore)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(isWinner ? .moare : .primary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                .padding(.trailing, 4)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            
            Capsule()
                .fill(.secondary)
                .frame(height: 1)
                .opacity(0.5)
            
            HStack(spacing: 0) {
                ForEach(0..<gameInfo.defaultPeriodCount, id: \.self) { index in
                    let homePeriodScore = homeSetScore?.periods[index]
                    let awayPeriodScore = awaySetScore?.periods[index]
                    let awayTieBreakScore = awaySetScore?.periodsTieBreak[index]
                    
                    let isWinner = if awayPeriodScore == 7 {
                        true
                    } else if let homePeriodScore, let awayPeriodScore {
                        (awayPeriodScore == 6) && (awayPeriodScore - homePeriodScore >= 2)
                    } else {
                        false
                    }
                    
                    VCapsuleBar()
                        .opacity(0.5)
                    ZStack {
                        Text(awayPeriodScore.displayOrDash)
                            .fontWeight(.medium)
                            .foregroundStyle(isWinner ? .moare : .primary)
                        
                        if let awayTieBreakScore {
                            Text("\(awayTieBreakScore)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(isWinner ? .moare : .primary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                .padding(.trailing, 4)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
    }
}

struct TennisGameStatsPointByPointContainer: View {
    @Bindable var store: StoreOf<TennisGameStatsStore>
    
    @State private var selectedSetIndex = 0
    @State private var setButtonWidth: CGFloat = 0
    @State private var setBarXOffset: CGFloat = 0
    
    var body: some View {
        let displayModel = store.baseGameStats.displayModel
        let gameInfo = displayModel.game.gameInfo
        let homeTeam = gameInfo.homeTeam
        let awayTeam = gameInfo.awayTeam
        let teamNameDic = store.baseGameStats.teamNameDictionary
        let homeTeamDefaultName = store.isDoubles ? (homeTeam?.name ?? "") : (homeTeam?.shortName ?? "")
        let awayTeamDefaultName = store.isDoubles ? (awayTeam?.name ?? "") : (awayTeam?.shortName ?? "")
        
        let pointByPoint = displayModel.game.pointByPoint ?? []
        let selectedSet = pointByPoint.first { $0.set == selectedSetIndex + 1 }
        let selectedSetGames = (selectedSet?.games ?? []).sorted { $0.game < $1.game }
        
        // TODO: serving 표시, G표시, B표시
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<pointByPoint.count, id: \.self) { index in
                        let homePeriodScore = gameInfo.homeScore?.periods[index]
                        
                        if let _ = homePeriodScore {
                            Button(action: {
                                selectedSetIndex = index
                            }) {
                                Text("\(index + 1)세트")
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundStyle(.primary)
                            .readSize { size in
                                setButtonWidth = size.width
                            }
                            
                            if index != pointByPoint.count - 1 {
                                VCapsuleBar()
                                    .opacity(0.5)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
                
                HCapsuleBar()
                    .offset(x: setBarXOffset)
            }
            .onChange(of: setButtonWidth) {
                withAnimation(.spring(duration: 0.5)) {
                    setBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: setButtonWidth)
                }
            }
            .onChange(of: selectedSetIndex) {
                withAnimation(.spring(duration: 0.5)) {
                    setBarXOffset = getOffsetOfAniCapsuleBar(
                        itemWidth: setButtonWidth,
                        spacing: 2,
                        index: selectedSetIndex
                    )
                }
            }
            
            HStack(spacing: 0) {
                VStack {
                    ForEach(Array(selectedSetGames.enumerated()), id: \.offset) { index, _ in
                        HStack {
                            Text("Game\(index + 1)")
                                .font(.system(size: 14))
                            
                            VCapsuleBar(customWidth: 1)
                                .opacity(0.5)
                        }
                        .frame(height: 50)
                        
                        if index != selectedSetGames.count - 1 {
                            HDivider()
                                .frame(width: 1)
                                .opacity(0)
                        }
                    }
                }
                
                ScrollView(.horizontal) {
                    VStack(alignment: .leading) {
                        ForEach(Array(selectedSetGames.enumerated()), id: \.offset) { index, game in
                            let score = game.score
                            let points = game.points ?? []
                            
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text(teamNameDic["short_\(homeTeam?.id ?? 0)"] ?? homeTeamDefaultName)
                                        .font(.system(size: 14))
                                        .frame(width: 70, alignment: .leading)
                                    
                                    if let score {
                                        let text = if score.isTieBreak {
                                            ""
                                        } else {
                                            if score.isHomeServing {
                                                "S"
                                            } else if score.isHomeWinner {
                                                "B"
                                            } else {
                                                ""
                                            }
                                        }
                                        
                                        Text(text)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.moare)
                                            .frame(width: 20)
                                        
                                        Text("\(score.homeScore)")
                                            .font(.system(size: 14, weight: score.isHomeWinner ? .bold : .regular))
                                            .frame(width: 30)
                                    }
                                    
                                    VCapsuleBar(customWidth: 1)
                                        .opacity(0.5)
                                    
                                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                                        Text(point.homePoint)
                                            .font(.system(size: 14))
                                            .frame(width: 30)
                                        
                                        if index == points.count - 1 && score?.isGameFinished == true {
                                            let text = score?.isHomeWinner == true ? "G" : point.homePoint
                                            let color: Color = score?.isHomeWinner == true ? .moare : .primary
                                            
                                            Text(text)
                                                .font(.system(size: 14))
                                                .foregroundStyle(color)
                                                .frame(width: 30)
                                        }
                                    }
                                }
                                .frame(maxHeight: .infinity)
                                
                                HStack(spacing: 0) {
                                    Text(teamNameDic["short_\(awayTeam?.id ?? 0)"] ?? awayTeamDefaultName)
                                        .font(.system(size: 14))
                                        .frame(width: 70, alignment: .leading)
                                    
                                    if let score {
                                        let text = if score.isTieBreak {
                                            ""
                                        } else {
                                            if !score.isHomeServing {
                                                "S"
                                            } else if score.isAwayWinner {
                                                "B"
                                            } else {
                                                ""
                                            }
                                        }
                                        
                                        Text(text)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.moare)
                                            .frame(width: 20)
                                        
                                        Text("\(score.awayScore)")
                                            .font(.system(size: 14, weight: score.isAwayWinner ? .bold : .regular))
                                            .frame(width: 30)
                                    }
                                    
                                    VCapsuleBar(customWidth: 1)
                                        .opacity(0.5)
                                    
                                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                                        Text(point.awayPoint)
                                            .font(.system(size: 14))
                                            .frame(width: 30)
                                        
                                        if index == points.count - 1 && score?.isGameFinished == true {
                                            let text = score?.isAwayWinner == true ? "G" : point.awayPoint
                                            let color: Color = score?.isAwayWinner == true ? .moare : .primary
                                            
                                            Text(text)
                                                .font(.system(size: 14))
                                                .foregroundStyle(color)
                                                .frame(width: 30)
                                        }
                                    }
                                }
                                .frame(maxHeight: .infinity)
                            }
                            .frame(height: 50)
                            
                            if index != selectedSetGames.count - 1 {
                                HStack(spacing: 0) {
                                    Spacer()
                                        .frame(width: 112, height: 1) // 70 + 20 + 30 - 8(padding)
                                    HDivider(color: .secondary)
                                        .opacity(0.5)
                                }
                            }
                        }
                    }
                    .padding(.leading, 8)
                }
            }
        }
        .padding(.top, 8)
    }
}

struct TennisGameStatsPlayerStatsContainer: View {
    @Bindable var store: StoreOf<TennisGameStatsStore>
    
    @State private var textWidth: CGFloat = 0
    
    var body: some View {
        let displayModel = store.baseGameStats.displayModel
        let gameInfo = displayModel.game.gameInfo
        let homeTeam = gameInfo.homeTeam
        let awayTeam = gameInfo.awayTeam
        let teamNameDic = store.baseGameStats.teamNameDictionary
        let homeTeamDefaultName = store.isDoubles ? (homeTeam?.name ?? "") : (homeTeam?.shortName ?? "")
        let awayTeamDefaultName = store.isDoubles ? (awayTeam?.name ?? "") : (awayTeam?.shortName ?? "")
        
        let displayStats = (displayModel.game.statistics ?? []).flatMap { $0.itemsForDisplay() }
        
        VStack {
            HStack {
                HStack {
                    URLImage(
                        url: Util.teamLogoURL(leagueId: displayModel.leagueId, teamId: homeTeam?.id)
                    )
                    
                    Text(teamNameDic["short_\(homeTeam?.id ?? 0)"] ?? homeTeamDefaultName)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    URLImage(
                        url: Util.teamLogoURL(leagueId: displayModel.leagueId, teamId: awayTeam?.id),
                    )
                    
                    Text(teamNameDic["short_\(awayTeam?.id ?? 0)"] ?? awayTeamDefaultName)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            ForEach(Array(displayStats.enumerated()), id: \.offset) { _, stat in
                HStack {
                    Text(stat.home)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                    
                    ZStack {
                        Text(stat.krname)
                            .frame(width: textWidth)
                        
                        // 폭 측정용(보이지 않음)
                        Text(stat.krname)
//                            .fixedSize()
                            .opacity(0)
                            .readSize { size in
                                textWidth = max(textWidth, size.width)
                            }
                    }
                    
                    Text(stat.away)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 8)
    }
}
