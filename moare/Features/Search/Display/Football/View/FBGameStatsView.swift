//
//  StatisticsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/5/24.
//

import SwiftUI
import ComposableArchitecture

struct FBGameStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<FBGameStatsStore>
    let didPop: Bool
    
    private let columnWidthList: [CGFloat] = [50, 50, 50, 50, 60, 50, 80, 70, 70, 80, 60, 60, 60, 50, 50, 50, 80, 50]
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseGameStats.displayModel
        let game = displayModel.game
        let playerNameDic = store.baseGameStats.playerNameDictionary
        let teamNameDic = store.baseGameStats.teamNameDictionary
        let fbLeagueScheduleModel = searchStore.displayModels[.fbLeagueSchedule] as? FBLeagueScheduleDisplayModel
        
        let teamIds = [game.teams.home.id, game.teams.away.id]
        let teamCategories: [GameStatsTeamState] = teamIds.map {
            return GameStatsTeamState(
                name: teamNameDic["short_\($0)"] ?? "",
                imageUrl: FBUtil.teamLogoURL(id: $0)
            )
        }
        
        let playerList: [StandingsItemState] = store.playerStats.compactMap {
            let stats = $0.statistics.first
            let playerId = $0.player.id
            
            var isStarter = false
            var position = ""
            
            if let lineups = store.lineups {
                for item in lineups.startXI {
                    if playerId == item.player.id {
                        isStarter = true
                        position = item.player.pos
                        break
                    }
                }
                
                for item in lineups.substitutes {
                    if playerId == item.player.id {
                        isStarter = false
                        position = item.player.pos
                        break
                    }
                }
            }
            
            if let stats {
                return StandingsItemState(
                    id: playerId,
                    imageUrl: $0.player.photo,
                    name: playerNameDic["\(playerId)"] ?? $0.player.name,
                    extraInfo: isStarter ? "선발" : "후보",
                    extraSubInfo: position,
                    dataList: [
                        String(stats.goals.total),
                        String(stats.penalty.scored),
                        String(stats.goals.assists),
                        String(stats.shots.total),
                        String(stats.shots.on),
                        String(stats.passes.key),
                        "\(stats.dribbles.success)/\(stats.dribbles.attempts)(\(stats.dribbles.success.percentage(of: stats.dribbles.attempts, to: 1))%)",
                        String(stats.offsides),
                        String(stats.tackles.total),
                        "\(stats.duels.won)/\(stats.duels.total)(\(stats.duels.won.percentage(of: stats.duels.total, to: 1))%)",
                        String(stats.tackles.interceptions),
                        String(stats.passes.total),
                        String(stats.fouls.drawn),
                        String(stats.fouls.committed),
                        String(stats.cards.yellow),
                        String(stats.cards.red),
                        String(stats.games.minutes),
                        stats.games.rating
                    ]
                )
            } else {
              return nil
            }
        } ?? []
        
        let gameDetailTitle = "장소: \n심판: "
        let gameDetailContent: String = {
            var result = ""
            result += "\(teamNameDic["venue_\(displayModel.game.teams.home.id)"] ?? "")\n"
            result += "\(displayModel.game.fixture.referee)\n"
            return result
        }()
        
        VStack {
            if show {
                GameStatsViewContainer(
                    state: GameStatsContainerState(
                        shouldShowTitle: fbLeagueScheduleModel == nil,
                        shouldShowGameItem: fbLeagueScheduleModel == nil,
                        shouldShowStats: displayModel.game.fixture.status.short != StringConstants.Football.gameNotStarted,
                        shouldShowCoach: true,
                        shouldShowRefreshButton: StringConstants.Football.gameLiveList.contains(displayModel.game.fixture.status.short),
                        teamCategories: teamCategories,
                        coachState: GameStatsCoachState(
                            name: store.coach?.name,
                            imageUrl: store.coach?.photo
                        ),
                        teamCategorySelectedIndex: store.baseGameStats.teamCategorySelectedIndex,
                        gameDetailTitle: gameDetailTitle,
                        gameDetailContent: gameDetailContent,
                        firstStatsCategories: StringConstants.Football.gameStatsSecondCategories,
                        firstStatsCategorySelectedIndex: store.baseGameStats.firstCategorySelectedIndex,
                        firstStatsColumnWidthList: columnWidthList,
                        firstStatsPlayerList: playerList,
                    ),
                    actions: GameStatsContainerActions(
                        teamCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectTeam(index)))
                        },
                        firstStatsCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectFirstCategory(index)))
                        },
                        refreshButtonAction: {
//                            searchStore.send(.refreshGame(season: displayModel.season, category: "football"))
                            store.send(.refreshGame)
                        }
                    ),
                    titleContent: {
                        HStack(spacing: 0) {
                            LeagueTitle(
                                url: game.league.logo,
                                leagueName: game.league.name,
                                leagueSeason: game.league.season
                            )
                            
                            Text(" - \(MatchDescriptionConverter.convert(descriptionType: .roundWithoutDash, input: game.league.round))")
                                .font(.system(size: 14))
                        }
                    },
                    gameContent: {
                        let previousViewStack = searchStore.viewStack.dropLast().last
                        // NOTE: || 연산자가 안먹고, switch case문도 오류가 나서 아래처럼 처리.
                        if case .fbPlayerInfo = previousViewStack {
                            FBLeagueScheduleListItem(
                                searchStore: searchStore,
                                fbLeagueScheduleStore: nil,
                                data: ModelConverter.fbGameToGameScheduleConverter(game: game),
                                teamNameDic: teamNameDic
                            )
                        } else if case .fbTeamInfo = previousViewStack {
                            FBLeagueScheduleListItem(
                                searchStore: searchStore,
                                fbLeagueScheduleStore: nil,
                                data: ModelConverter.fbGameToGameScheduleConverter(game: game),
                                teamNameDic: teamNameDic
                            )
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
