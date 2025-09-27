//
//  MLBGameStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBGameStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<MLBGameStatsStore>
    let didPop: Bool
    
    private let firstStatsColumnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 50, 50, 50]
    private let secondStatsColumnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 50]
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseGameStats.displayModel
        let game = displayModel.game
        let playerNameDic = store.baseGameStats.playerNameDictionary
        let teamNameDic = store.baseGameStats.teamNameDictionary
        
        let teamIds = [game.teams.home.id, game.teams.away.id]
        let teamCategories: [GameStatsTeamState] = teamIds.map {
            return GameStatsTeamState(
                name: teamNameDic["short_\($0)"] ?? "",
                imageUrl: MLBUtil.teamLogoURL(id: $0)
            )
        }
        
        let hitterList: [StandingsItemState] = store.teamHitters.map {
            let playerData = $0.1
            let playerBatting = playerData.stats?.batting
            
            return StandingsItemState(
                numInfo: Int(playerData.battingOrder.prefix(1)),
                imageUrl: MLBUtil.playerPhotoURL(id: Int($0.0.trimmingPrefix("ID"))),
                name: playerNameDic["\(playerData.person?.id ?? 0)"] ?? (playerData.person?.fullName ?? ""),
                extraInfo: playerData.position?.abbreviation,
                dataList: [
                    String(playerBatting?.atBats ?? 0),
                    String(playerBatting?.hits ?? 0),
                    String(playerBatting?.homeRuns ?? 0),
                    String(playerBatting?.rbi ?? 0),
                    String(playerBatting?.runs ?? 0),
                    String(playerBatting?.stolenBases ?? 0),
                    String(playerBatting?.baseOnBalls ?? 0),
                    String(playerBatting?.strikeOuts ?? 0)
                ]
            )
        }
        let pitcherList: [StandingsItemState] = store.teamPitchers.map {
            let playerData = $0.1
            let playerPitching = playerData.stats?.pitching
            
            return StandingsItemState(
                imageUrl: MLBUtil.playerPhotoURL(id: Int($0.0.trimmingPrefix("ID"))),
                name: playerNameDic["\(playerData.person?.id ?? 0)"] ?? (playerData.person?.fullName ?? ""),
                dataList: [
                    playerPitching?.inningsPitched ?? "0.0",
                    String(playerPitching?.runs ?? 0),
                    String(playerPitching?.earnedRuns ?? 0),
                    String(playerPitching?.baseOnBalls ?? 0),
                    String(playerPitching?.strikeOuts ?? 0),
                    String(playerPitching?.hits ?? 0)
                ]
            )
        }
        
        let gameDetailTitle = "날짜: \n\n장소: \n관중수: \n심판: "
        let gameDetailContent: String = {
            let officials = game.boxscore?.officials ?? []
            var result = ""
            result += "\(CalendarUtil.formatDate(date: game.gameInfo.gameDate).split(separator: " ").first ?? "")\n"
            result += "\(CalendarUtil.formatDate(date: game.gameInfo.gameDate, formatType: .ampm))\n"
            result += "\(teamNameDic["venue_\(game.teams.home.id)"] ?? "")\n"
            result += "\(game.gameInfo.attendance)\n"
            result += officials.map { "• \($0.official.fullName)" }.joined(separator: "\n")
            return result
        }()
        
        VStack {
            if show {
                GameStatsViewContainer(
                    state: GameStatsContainerState(
                        shouldShowStats: game.status.detailedState != StringConstants.MLB.gameScheduled,
                        shouldShowRefreshButton: game.status.detailedState == StringConstants.MLB.gameLive,
                        teamCategories: teamCategories,
                        teamCategorySelectedIndex: store.baseGameStats.teamCategorySelectedIndex,
                        gameDetailTitle: gameDetailTitle,
                        gameDetailContent: gameDetailContent,
                        firstStatsTitle: "타자",
                        firstStatsCategories: StringConstants.MLB.gameStatsHittingCategories,
                        firstStatsCategorySelectedIndex: store.baseGameStats.firstCategorySelectedIndex,
                        firstStatsColumnWidthList: firstStatsColumnWidthList,
                        firstStatsPlayerList: hitterList,
                        secondStatsTitle: "투수",
                        secondStatsCategories: StringConstants.MLB.gameStatsPitchingCategories,
                        secondStatsCategorySelectedIndex: store.baseGameStats.secondCategorySelectedIndex,
                        secondStatsColumnWidthList: secondStatsColumnWidthList,
                        secondStatsPlayerList: pitcherList
                    ),
                    actions: GameStatsContainerActions(
                        teamCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectTeam(index: index)))
                        },
                        firstStatsTitleCategoryAction: {
                            store.send(.sortByBattingOrder)
                        },
                        firstStatsCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectFirstCategory(index)))
                        },
                        secondStatsCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectSecondCategory(index)))
                        },
                        refreshButtonAction: {
                            store.send(.refreshGame())
                        }
                    ),
                    titleContent: {
                        BaseballLeagueTitleForGameStats(
                            logoUrl: MLBUtil.mlbLogoUrl,
                            name: "MLB",
                            season: Int(store.baseGameStats.displayModel.game.game.season)
                        )
                    },
                    gameContent: {
//                            if game.status.detailedState == StringConstants.MLB.gameScheduled {
//
//                            } else {
//                                MLBGameStatsScoreInfoItem(mlbGameStatsStore: mlbGameStatsStore)
//                            }
                        MLBGameStatsScoreInfoItem(mlbGameStatsStore: store)
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

struct MLBGameStatsScoreInfoItem: View {
    @Bindable var mlbGameStatsStore: StoreOf<MLBGameStatsStore>
    
    @State private var borderTextWidth: CGFloat = 0
    
    var body: some View {
        let displayModel = mlbGameStatsStore.baseGameStats.displayModel
        let game = displayModel.game
        let homeTeamId = game.teams.home.id
        let awayTeamId = game.teams.away.id
        let teamNameDic = mlbGameStatsStore.baseGameStats.teamNameDictionary
        let gameStatus = game.status.detailedState
        
        HStack(alignment: .bottom) {
            VStack(spacing: 0) {
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
                        url: MLBUtil.teamLogoURL(id: awayTeamId),
                        size: .small
                    )
                    
                    Text(teamNameDic["short_\(awayTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                CapsuleButton(
                    text: Constants.GameStatus.mlbGameStatusText(status: gameStatus, linescore: game.linescore),
                    color: Constants.GameStatus.gameStatusColor(leagueId: Constants.Ids.mlb, status: gameStatus)
                ) {
                }
                .disabled(true)
                .padding(.vertical, 4)
                
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
                        url: MLBUtil.teamLogoURL(id: homeTeamId),
                        size: .small
                    )
                    
                    Text(teamNameDic["short_\(homeTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } // VStack
            .frame(width: 110)
            
            MLBGameStatsLineScoreContainer(mlbGameStatsStore: mlbGameStatsStore)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct MLBGameStatsLineScoreContainer: View {
    @Bindable var mlbGameStatsStore: StoreOf<MLBGameStatsStore>
    
    var body: some View {
        let game = mlbGameStatsStore.baseGameStats.displayModel.game
        let isGameScheduled = game.status.detailedState == StringConstants.MLB.gameScheduled
        let lineScore = game.linescore
        let homeTeamLineScore = lineScore?.teams.home.runs ?? 0
        let awayTeamLineScore = lineScore?.teams.away.runs ?? 0
        
        HStack(alignment: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                if !isGameScheduled {
                    Text("\(awayTeamLineScore)")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(awayTeamLineScore >= homeTeamLineScore ? .moare : .primary)
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
                
                if !isGameScheduled {
                    Text("\(homeTeamLineScore)")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(
                            homeTeamLineScore >= awayTeamLineScore ? .moare : .primary
                        )
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
                MLBGameStatsLineScoreTitle(lineScoreInnings: lineScore?.innings ?? [])
                
                Capsule()
                    .fill(.secondary)
                    .frame(height: 1)
                    .opacity(0.5)
                
                MLBGameStatsLineScoreItem(
                    mlbGameStatsStore: mlbGameStatsStore,
                    isHome: false,
                    lineScoreInnings: lineScore?.innings ?? []
                )
                
                Capsule()
                    .fill(.secondary)
                    .frame(height: 1)
                    .opacity(0.5)
                
                MLBGameStatsLineScoreItem(
                    mlbGameStatsStore: mlbGameStatsStore,
                    isHome: true,
                    lineScoreInnings: lineScore?.innings ?? []
                )
            }
        }
        .frame(height: 127) // 25 + 1 + 50 + 1 + 50
    }
}

struct MLBGameStatsLineScoreTitle: View {
    let lineScoreInnings: [MLBGameLineScoreInning]
    
    var body: some View {
        let inningsCount = lineScoreInnings.isEmpty ? 9 : lineScoreInnings.count
        
        HStack(spacing: 0) {
            ForEach(1...inningsCount, id: \.self) { index in
                VCapsuleBar()
                    .opacity(0.5)
                Text("\(index)")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 25)
    }
}

struct MLBGameStatsLineScoreItem: View {
    @Bindable var mlbGameStatsStore: StoreOf<MLBGameStatsStore>
    
    let isHome: Bool
    let lineScoreInnings: [MLBGameLineScoreInning]
    
    var body: some View {
        HStack(spacing: 0) {
            if !lineScoreInnings.isEmpty {
                ForEach(lineScoreInnings.indices, id: \.self) { index in
                    let data = lineScoreInnings[index]
                    
                    VCapsuleBar()
                        .opacity(0.5)
                    Text("\(isHome ? data.home.runs : data.away.runs)")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            } else {
                ForEach(0..<9, id: \.self) { index in
                    VCapsuleBar()
                        .opacity(0.5)
                    Text("-")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
}
