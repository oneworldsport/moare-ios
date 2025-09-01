//
//  FBPlayerStandingsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import SwiftUI
import ComposableArchitecture

struct FBPlayerStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBPlayerStandingsDisplayModel
    
    private let columnWidthList: [CGFloat] = [50, 50, 70, 50, 70, 50, 70, 50, 70, 80, 70, 50, 50, 50, 50, 70, 70, 80, 70]
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            let playerStandings: [StandingsItemState] = fbPlayerStandingsStore?.filteredStandings.map {
                let stats = $0.stats
                return StandingsItemState(
                    id: $0.player.id,
                    imageUrl: $0.player.photo,
                    name: fbPlayerStandingsStore?.playerNameDictionary["\($0.player.id)"]?.dropFirstWord ?? $0.player.name.dropFirstWord,
                    subName: fbPlayerStandingsStore?.teamNameDictionary["short_\(stats.team.id)"] ?? stats.team.name,
                    dataList: [
                        String(stats.goals.total),
                        String(stats.goals.assists),
                        String(stats.goals.total + stats.goals.assists),
                        String(stats.shots.total),
                        String(stats.shots.on),
                        String(stats.passes.key),
                        String(stats.dribbles.success),
                        String(stats.penalty.scored),
                        String(stats.tackles.total),
                        String(stats.duels.won),
                        String(stats.passes.total),
                        String(stats.fouls.committed),
                        String(stats.cards.yellow),
                        String(stats.cards.red),
                        String(stats.games.appearences),
                        String(stats.games.lineups),
                        String(stats.substitutes.substituteIn),
                        String(stats.games.minutes),
                        String(Double(stats.games.rating)?.rounded(to: 2) ?? 0.0)
                    ]
                )
            } ?? []
            
            VStack {
                if let fbPlayerStandingsStore {
                    StandingsViewContainer(
                        state: StandingsContainerState(
                            secondCategories: StringConstants.Football.playerStandingsSecondCategories,
                            standings: playerStandings,
                            secondCategorySelectedIndex: fbPlayerStandingsStore.secondSelectedIndex,
                            highlightState: StandingsHighlightItemState(
                                itemIndex: fbPlayerStandingsStore.entityIndex,
                                standingsStartIndex: fbPlayerStandingsStore.filteredStandingsStartIndex,
                                allStandingsCount: fbPlayerStandingsStore.standings.count
                            ),
                            displayDataState: fbPlayerStandingsStore.displayDataState,
                            columnWidthList: columnWidthList
                        ),
                        actions: StandingsContainerActions(
                            secondCategoryButtonAction: { index, category in
                                fbPlayerStandingsStore.send(.selectSecondCategory(index: index, category: category))
                            },
                            itemButtonAction: { id in
                                searchStore.send(.showPlayerStats(category: "football", playerId: id))
                            },
                            showMoreStandingsAction: { isUp in
                                fbPlayerStandingsStore.send(.showMoreStandings(isUp: isUp))
                            }
                        ),
                        titleContent: {
                            if let league = fbPlayerStandingsStore.league {
                                LeagueTitle(
                                    url: league.logo,
                                    leagueName: league.name,
                                    leagueSeason: league.season
                                )
                            }
                        },
                        customListContent: { _ in }
                    )
                }
            }
            .onAppear {
                // init FBPlayerStandingsStore
                let fbPlayerStandingsStore: StoreOf<FBPlayerStandingsStore> = storeManager.getStore(forKey: StoreKeys.fbPlayerStandingsStore) ?? {
                    let newStore = Store(initialState: FBPlayerStandingsStore.State()) { FBPlayerStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbPlayerStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbPlayerStandingsStore = fbPlayerStandingsStore
                }
                
                if searchStore.poppedView == nil {
                    fbPlayerStandingsStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .fbPlayerStandings = searchStore.poppedView {
                    fbPlayerStandingsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
}
