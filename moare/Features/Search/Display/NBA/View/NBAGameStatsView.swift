//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAGameStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<NBAGameStatsStore>
    let didPop: Bool
    
    private let columnWidthList: [CGFloat] = [70, 50, 50, 70, 50, 110, 110, 110, 50, 50, 50, 50, 50, 50, 50, 100, 70]
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseGameStats.displayModel
        let game = displayModel.game
        let playerNameDic = store.baseGameStats.playerNameDictionary
        let teamNameDic = store.baseGameStats.teamNameDictionary
        
        let teamIds = [game.gameSummary?.homeTeamId, game.gameSummary?.awayTeamId]
        let teamCategories: [GameStatsTeamState] = teamIds.map {
            return GameStatsTeamState(
                name: teamNameDic["short_\($0 ?? 0)"] ?? "",
                imageUrl: NBAUtil.teamLogoURL(id: $0)
            )
        }
        
        let playerList: [StandingsItemState] = store.playerStats.map {
            let stats = $0.statistics
            let playerId = $0.personId
            
            return StandingsItemState(
                id: playerId,
                imageUrl: NBAUtil.playerPhotoURL(id: playerId),
                name: playerNameDic["\(playerId)"] ?? $0.nameI,
                extraInfo: $0.isStarter ? "선발" : "후보",
                extraSubInfo: $0.position,
                dataList: [
                    stats.minutes,
                    String(stats.points),
                    String(stats.assists),
                    String(stats.reboundsTotal),
                    "",
                    "\(stats.fieldGoalsMade)/\(stats.fieldGoalsAttempted)(\(stats.fieldGoalsPercentageStr))",
                    "\(stats.threePointersMade)/\(stats.threePointersAttempted)(\(stats.threePointersPercentageStr))",
                    "\(stats.freeThrowsMade)/\(stats.freeThrowsAttempted)(\(stats.freeThrowsPercentageStr))",
                    "",
                    String(stats.steals),
                    String(stats.blocks),
                    "",
                    String(stats.turnovers),
                    String(stats.foulsPersonal),
                    "",
                    "\(stats.reboundsOffensive)/\(stats.reboundsDefensive)",
                    String(stats.plusMinusPoints),
                ]
            )
        }
        
        let gameDetailTitle = "날짜: \n\n장소: \n관중수: \n심판: "
        let gameDetailContent: String = {
            var result = ""
            result += "\(CalendarUtil.formatDate(date: game.gameSummary?.gameDate).split(separator: " ").first ?? "")\n"
            result += "\(CalendarUtil.formatDate(date: game.gameSummary?.gameDate, outputFormatType: .ampm))\n"
            result += "\(teamNameDic["venue_\(game.gameSummary?.homeTeamId ?? 0)"] ?? "")\n"
            result += "\(game.gameSummary?.attendance ?? 0)\n"
            
            if let officials = game.officials {
//                result += officials.map { "• \($0.firstName + $0.lastName)" }.joined(separator: "\n")
                result += officials.map { "• \($0.name)" }.joined(separator: "\n")
            }
            
            return result
        }()
        
        VStack {
            if show {
                GameStatsViewContainer(
                    state: GameStatsContainerState(
                        shouldShowStats: game.gameSummary?.gameStatus != Constants.GameStatus.NBA.notStarted,
                        shouldShowRefreshButton: game.gameSummary?.gameStatus == Constants.GameStatus.NBA.live,
                        teamCategories: teamCategories,
                        teamCategorySelectedIndex: store.baseGameStats.teamCategorySelectedIndex,
                        gameDetailTitle: gameDetailTitle,
                        gameDetailContent: gameDetailContent,
                        firstStatsCategories: StringConstants.NBA.gameStatsCategories,
                        firstStatsCategorySelectedIndex: store.baseGameStats.firstCategorySelectedIndex,
                        firstStatsColumnWidthList: columnWidthList,
                        firstStatsPlayerList: playerList,
                    ),
                    actions: GameStatsContainerActions(
                        teamCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectTeam(index: index)))
                        },
                        firstStatsTitleCategoryAction: {
                            store.send(.selectTitleCategory)
                        },
                        firstStatsCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectFirstCategory(index)))
                        },
                        refreshButtonAction: {
                            await store.send(.refreshGame()).finish()
                        }
                    ),
                    titleContent: {
                        let gameSummary = displayModel.game.gameSummary
                        let gameType = if let gameSummary {
                            if gameSummary.isPlayoffs {
                                "\(gameSummary.gameLabelKr) | \(gameSummary.seriesGameNumber)"
                            } else {
                                gameSummary.weekName
                            }
                        } else {
                            ""
                        }
                        
                        HStack(spacing: 0) {
                            NBATitle(
                                leagueName: "NBA",
                                leagueSeason: displayModel.season
                            )
//                            game.gameSummary?.season.split(separator: "-").first.flatMap { Int(String($0)) } // TODO: 이 문법으로 다른 비슷한 코드도 다 바꾸기
                            
                            Text(" | \(gameType)")
                                .font(.system(size: 14))
                            
                            Spacer()
                        }
                        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                        
                        if let gameSummary, gameSummary.isPlayoffs {
                            NBAGameStatsPlayoffsSeriesText(seriesTextKr: gameSummary.seriesTextKr)
                        }
                    },
                    gameContent: {
//                            if game.gameSummary?.gameStatusId == StringConstants.NBA.gameScheduled {
//
//                            } else {
//                                NBAGameStatsScoreInfoItem(nbaGameStatsStore: nbaGameStatsStore)
//                            }
                        
                        NBAGameStatsScoreInfoItem(nbaGameStatsStore: store)
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

struct NBAGameStatsScoreInfoItem: View {
    @Bindable var nbaGameStatsStore: StoreOf<NBAGameStatsStore>
    
    @State private var borderTextWidth: CGFloat = 0
    
    var body: some View {
        let displayModel = nbaGameStatsStore.baseGameStats.displayModel
        let game = displayModel.game
        let homeTeamId = nbaGameStatsStore.homeTeamId
        let awayTeamId = nbaGameStatsStore.awayTeamId
        let homeTeamLineScore = nbaGameStatsStore.homeTeamLineScore
        let awayTeamLineScore = nbaGameStatsStore.awayTeamLineScore
        let teamNameDic = nbaGameStatsStore.baseGameStats.teamNameDictionary
        
        HStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    RoundedBorderText(
                        text: "홈",
                        fontSize: 11,
                        textColor: .moare,
                        radius: 4,
                        strokeColor: .moare
                    )
                    .frame(width: borderTextWidth, alignment: .leading)
                    
                    URLImage(
                        url: NBAUtil.teamLogoURL(id: homeTeamId),
                        size: .small
                    )
                    
                    Text(teamNameDic["short_\(homeTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                GameStatusCapsuleButton(
                    gameStatusContext: .nba(status: game.gameSummary?.gameStatus ?? 1, period: game.gameSummary?.period), leagueId: Constants.Ids.nba
                ) {}
                .disabled(true)
                .padding(.vertical, 4)
                
                HStack(spacing: 0) {
                    RoundedBorderText(
                        text: "원정",
                        fontSize: 11,
                        textColor: .secondary,
                        radius: 4,
                        strokeColor: .secondary
                    )
                    .readSize { size in
                        borderTextWidth = size.width
                    }
                    
                    URLImage(
                        url: NBAUtil.teamLogoURL(id: awayTeamId),
                        size: .small
                    )
                    
                    Text(teamNameDic["short_\(awayTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } // VStack
            .frame(width: 110)
            
            if let homeTeamLineScore, let awayTeamLineScore {
                NBAGameStatsLineScoreContainer(
                    homeTeamLineScore: homeTeamLineScore,
                    awayTeamLineScore: awayTeamLineScore
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct NBAGameStatsLineScoreContainer: View {
    let homeTeamLineScore: NBALineScore
    let awayTeamLineScore: NBALineScore
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                if let homeTeamPts = homeTeamLineScore.pts, let awayTeamPts = awayTeamLineScore.pts {
                    Text("\(homeTeamPts)")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(homeTeamPts >= awayTeamPts ? .moare : .primary)
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
                
                if let homeTeamPts = homeTeamLineScore.pts, let awayTeamPts = awayTeamLineScore.pts {
                    Text("\(awayTeamPts)")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(awayTeamPts >= homeTeamPts ? .moare : .primary)
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
                NBAGameStatsLineScoreTitle(lineScore: homeTeamLineScore)
                
                Capsule()
                    .fill(.secondary)
                    .frame(height: 1)
                    .opacity(0.5)
                
                NBAGameStatsLineScoreItem(lineScore: homeTeamLineScore)
                
                Capsule()
                    .fill(.secondary)
                    .frame(height: 1)
                    .opacity(0.5)
                
                NBAGameStatsLineScoreItem(lineScore: awayTeamLineScore)
            }
        }
        .frame(height: 127) // 25 + 1 + 50 + 1 + 50
    }
}

struct NBAGameStatsLineScoreTitle: View {
    let lineScore: NBALineScore
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1..<5) { index in
                VCapsuleBar()
                    .opacity(0.5)
                Text("\(index)")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
            }
            
            if let score = lineScore.ptsOt1, score != 0 {
                VCapsuleBar()
                    .opacity(0.5)
                Text("1OT")
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }
            if let score = lineScore.ptsOt2, score != 0 {
                VCapsuleBar()
                    .opacity(0.5)
                Text("2OT")
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }
            if let score = lineScore.ptsOt3, score != 0 {
                VCapsuleBar()
                    .opacity(0.5)
                Text("3OT")
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 25)
    }
}

struct NBAGameStatsLineScoreItem: View {
    let lineScore: NBALineScore
    
    var body: some View {
        HStack(spacing: 0) {
            VCapsuleBar()
                .opacity(0.5)
            Text(lineScore.ptsQtr1.displayOrDash)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
            VCapsuleBar()
                .opacity(0.5)
            Text(lineScore.ptsQtr2.displayOrDash)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
            VCapsuleBar()
                .opacity(0.5)
            Text(lineScore.ptsQtr3.displayOrDash)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
            VCapsuleBar()
                .opacity(0.5)
            Text(lineScore.ptsQtr4.displayOrDash)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
            
            if let score = lineScore.ptsOt1, score != 0 {
                VCapsuleBar()
                    .opacity(0.5)
                Text("\(score)")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
            }
            if let score = lineScore.ptsOt2, score != 0 {
                VCapsuleBar()
                    .opacity(0.5)
                Text("\(score)")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
            }
            if let score = lineScore.ptsOt3, score != 0 {
                VCapsuleBar()
                    .opacity(0.5)
                Text("\(score)")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
}

struct NBAGameStatsPlayoffsSeriesText: View {
    let seriesTextKr: String
    
    var body: some View {
        let pattern = /^(.*?)\s+(\d+)\s*-\s*(\d+)\s+(.*)$/

        if let match = try? pattern.wholeMatch(in: seriesTextKr) {
            let before = String(match.output.1).trimmingCharacters(in: .whitespacesAndNewlines)
            let score1 = Int(match.output.2)!
            let score2 = Int(match.output.3)!
            let after = String(match.output.4).trimmingCharacters(in: .whitespacesAndNewlines)

         
            HStack(spacing: 0) {
                Text(before)
                    .font(.system(size: 14))
                
                Text(" \(score1)")
                    .foregroundStyle(score1 >= score2 ? .moare : .primary)
                
                Text(" - ")
                    .font(.system(size: 14))
                
                Text("\(score2) ")
                    .foregroundStyle(score2 >= score1 ? .moare : .primary)
                
                Text(after)
                    .font(.system(size: 14))
                
                Spacer()
            }
            .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        }
    }
}
