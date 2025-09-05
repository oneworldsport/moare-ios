//
//  StatisticsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/5/24.
//

import SwiftUI
import ComposableArchitecture

struct FBGameStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbGameStatsStore: StoreOf<FBGameStatsStore>? = nil
    @State var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>? = nil
    
    let displayModel: FBGameStatsDisplayModel
    
    private let columnWidthList: [CGFloat] = [50, 50, 50, 50, 60, 50, 80, 70, 70, 80, 60, 60, 60, 50, 50, 50, 80, 50]
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            let game = displayModel.game
            let fbLeagueScheduleModel = searchStore.displayModels[.fbLeagueSchedule] as? FBLeagueScheduleDisplayModel
            
            let teamIds = [displayModel.game.teams.home.id, displayModel.game.teams.away.id]
            let teamCategories: [GameStatsTeamState] = teamIds.map {
                return GameStatsTeamState(
                    name: fbGameStatsStore?.teamNameDictionary["short_\($0)"] ?? "",
                    imageUrl: FBUtil.teamLogoURL(id: $0)
                )
            }
            
            let playerList: [StandingsItemState] = fbGameStatsStore?.playerStats.compactMap {
                let stats = $0.statistics.first
                let playerId = $0.player.id
                
                var isStarter = false
                var position = ""
                
                if let lineups = fbGameStatsStore?.lineups {
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
                        name: fbGameStatsStore?.playerNameDictionary["\(playerId)"] ?? $0.player.name,
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
            
            let gameDetailTitle = "심판: "
            let gameDetailContent = displayModel.game.fixture.referee
            
            VStack {
                if let fbGameStatsStore {
                    GameStatsViewContainer(
                        state: GameStatsContainerState(
                            shouldShowTitle: fbLeagueScheduleModel == nil,
                            shouldShowGameItem: fbLeagueScheduleModel == nil,
                            shouldShowStats: displayModel.game.fixture.status.short != StringConstants.Football.gameNotStarted,
                            shouldShowCoach: true,
                            shouldShowRefreshButton: StringConstants.Football.gameLiveList.contains(displayModel.game.fixture.status.short),
                            teamCategories: teamCategories,
                            coachState: GameStatsCoachState(
                                name: fbGameStatsStore.coach?.name,
                                imageUrl: fbGameStatsStore.coach?.photo
                            ),
                            teamCategorySelectedIndex: fbGameStatsStore.selectedTeamIndex,
                            gameDetailTitle: gameDetailTitle,
                            gameDetailContent: gameDetailContent,
                            firstStatsCategories: StringConstants.Football.gameStatsSecondCategories,
                            firstStatsCategorySelectedIndex: fbGameStatsStore.secondSelectedIndex,
                            firstStatsColumnWidthList: columnWidthList,
                            firstStatsPlayerList: playerList,
                        ),
                        actions: GameStatsContainerActions(
                            teamCategoryButtonAction: { index in
                                fbGameStatsStore.send(.selectTeam(index))
                            },
                            firstStatsCategoryButtonAction: { index in
                                fbGameStatsStore.send(.selectSecondCategory(index))
                            },
                            refreshButtonAction: {
                                searchStore.send(.refreshGame(season: displayModel.season, category: "football"))
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
//                            if let fbLeagueScheduleStore {
//                                FBLeagueScheduleListItem(
//                                    searchStore: searchStore,
//                                    fbLeagueScheduleStore: fbLeagueScheduleStore,
//                                    data: ModelConverter.fbGameToGameScheduleConverter(game: game),
//                                    teamNameDic: fbGameStatsStore.teamNameDictionary
//                                )
//                            }
                        }
                    )
                }
            }
            .onAppear {
                // init FBGameStatsStore
                let fbGameStatsStore: StoreOf<FBGameStatsStore> = storeManager.getStore(forKey: StoreKeys.fbGameStatsStore) ?? {
                    let newStore = Store(initialState: FBGameStatsStore.State()) { FBGameStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbGameStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbGameStatsStore = fbGameStatsStore
                }
                
                if searchStore.poppedView == nil {
                    fbGameStatsStore.send(.initData(displayModel: displayModel))
                }
                
                // TODO: has to figure out better structure
                // when game_stats show at first(meaning ScheduleView never showed)
                let scheduleStore: StoreOf<FBLeagueScheduleStore> = storeManager.getStore(forKey: StoreKeys.fbLeagueScheduleStore) ?? {
                    let newStore = Store(initialState: FBLeagueScheduleStore.State()) { FBLeagueScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbLeagueScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbLeagueScheduleStore = scheduleStore
                }
                
//                if displayModel.game.fixture.status.short != "NS" && displayModel.game.fixture.status.short != "FT" {
//                    searchStore.send(.refreshGame(category: "football"))
//                }
            } // onAppear
            .onChange(of: displayModel) {
                if case .fbGameStats = searchStore.poppedView {
                    fbGameStatsStore?.send(.initData(displayModel: displayModel))
                }
                
                // for refreshGame
                if case .fbGameStats = searchStore.viewStack.last {
                    fbGameStatsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
}
