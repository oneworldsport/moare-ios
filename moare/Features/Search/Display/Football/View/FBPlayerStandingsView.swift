//
//  FBPlayerStandingsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import SwiftUI
import ComposableArchitecture

struct FBPlayerStandingsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<FBPlayerStandingsStore>
    
    private let columnWidthList: [CGFloat] = [50, 50, 70, 50, 70, 50, 70, 50, 70, 80, 70, 50, 50, 50, 50, 70, 70, 80, 70]
    
    @State private var show = false
    
    var body: some View {
        let playerStandings: [StandingsItemState] = store.filteredStandings.map {
            let stats = $0.stats
            return StandingsItemState(
                id: $0.player.id,
                imageUrl: $0.player.photo,
                name: store.baseStandings.playerNameDictionary["\($0.player.id)"]?.dropFirstWord ?? $0.player.name.dropFirstWord,
                subName: store.baseStandings.teamNameDictionary["short_\(stats.team.id)"] ?? stats.team.name,
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
        }
        
        VStack {
            if show {
                StandingsViewContainer(
                    state: StandingsContainerState(
                        secondCategories: StringConstants.Football.playerStandingsSecondCategories,
                        standings: playerStandings,
                        secondCategorySelectedIndex: store.baseStandings.categorySelectedIndex,
                        highlightState: StandingsHighlightItemState(
                            itemIndex: store.baseStandings.entityIndex,
                            standingsStartIndex: store.baseStandings.filteredStandingsStartIndex,
                            allStandingsCount: store.standings.count
                        ),
                        displayDataState: store.baseStandings.displayDataState,
                        columnWidthList: columnWidthList
                    ),
                    actions: StandingsContainerActions(
                        secondCategoryButtonAction: { index, category in
                            store.send(.baseStandings(.selectCategory(index: index, category: category)))
                        },
                        itemButtonAction: { id in
                            searchStore.send(.showPlayerStats(category: "football", playerId: id))
                        },
                        showMoreStandingsAction: { isUp in
                            store.send(.showMoreStandings(isUp: isUp))
                        }
                    ),
                    titleContent: {
                        if let league = store.league {
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
            store.send(.baseStandings(.initData))
            
            // TODO: 왜 SearchView 애니메이션은 안먹히지?
            // NOTE: show를 먼저하고 .initData를 나중에하면 애니메이션이 다름(카테고리가 위에서 내려오고, 순위 리스트는 오른쪽에서 나옴)
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}
