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
    let isCombinedView: Bool
    
    private let columnWidthList: [CGFloat] = [80, 50, 50, 50, 50, 50, 70, 70, 100, 50, 70, 100, 70, 50, 80, 70, 70, 50, 50]
    
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
                imageUrl: FBUtil.teamLogoURL(id: $0)
            )
        }
        
        let playerList: [StandingsItemState] = store.playerStats.compactMap {
            let stats = $0.statistics.first
            let playerId = $0.player.id
            
            if let stats {
                return StandingsItemState(
                    id: playerId,
                    imageUrl: $0.player.photo,
                    name: playerNameDic["\(playerId)"] ?? $0.player.name,
                    extraInfo: $0.isStarter ? "선발" : "후보",
                    extraSubInfo: $0.position ?? "",
                    dataList: [
                        String(stats.games.minutes),
                        String(stats.goals.total),
                        String(stats.penalty.scored),
                        String(stats.goals.assists),
                        "",
                        String(stats.shots.total),
                        String(stats.shots.on),
                        String(stats.passes.total),
                        "\(stats.dribbles.success)/\(stats.dribbles.attempts)(\(stats.dribbles.success.percentage(of: stats.dribbles.attempts, to: 1))%)",
                        "",
                        String(stats.tackles.total),
                        "\(stats.duels.won)/\(stats.duels.total)(\(stats.duels.won.percentage(of: stats.duels.total, to: 1))%)",
                        String(stats.tackles.interceptions),
                        "",
                        String(stats.offsides),
                        String(stats.fouls.drawn),
                        String(stats.fouls.committed),
                        String(stats.cards.yellow),
                        String(stats.cards.red),
                    ]
                )
            } else {
              return nil
            }
        }
        
        let gameDetailTitle = "장소: \n심판: "
        let gameDetailContent: String = {
            var result = ""
            result += "\(teamNameDic["venue_\(displayModel.game.teams.home.id)"] ?? displayModel.game.fixture.venue.name)\n"
            result += "\(displayModel.game.fixture.referee)\n"
            return result
        }()
        
        VStack {
            if show {
                GameStatsViewContainer(
                    state: GameStatsContainerState(
                        shouldShowTitle: !isCombinedView,
                        shouldShowGameContent: !isCombinedView,
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
                        firstStatsCategories: StringConstants.Football.gameStatsCategories,
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
                        FBLeagueTitleForGameStats(
                            url: game.league.logo,
                            leagueName: game.league.name,
                            leagueSeason: game.league.season,
                            description: game.league.round
                        )
                    },
                    gameContent: {
                        FBLeagueScheduleListItem(
                            searchStore: searchStore,
                            fbLeagueScheduleStore: nil,
                            data: ModelConverter.fbGameToGameScheduleConverter(game: game),
                            leagueId: displayModel.leagueId,
                            teamNameDic: teamNameDic
                        )
                    },
                    customStatsContent: {}
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
