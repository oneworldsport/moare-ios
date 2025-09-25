//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerStandingsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<NBAPlayerStandingsStore>
    let didPop: Bool
    
    private let columnWidthList: [CGFloat] = [80, 80, 80, 80, 80, 80, 80, 80, 80,
                                              80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 50,
                                              80, 80, 80, 80, 80, 80]
    
    @State private var show = false
    
    var body: some View {
        let playerStandings: [StandingsItemState] = store.filteredStandings.map {
            let stats = $0.stats
            let id = $0.player.personId
            return StandingsItemState(
                id: id,
                imageUrl: NBAUtil.playerPhotoURL(id: id),
                name: store.baseStandings.playerNameDictionary["\(id)"]?.dropFirstWord ?? $0.player.displayFirstLast.dropFirstWord,
                subName: store.baseStandings.teamNameDictionary["short_\($0.player.teamId)"] ?? $0.player.teamCity,
                dataList: [
                    String(stats.ptsPG),
                    String(stats.astPG),
                    String(stats.orebPG),
                    String(stats.fgaPG),
                    String(stats.fgmPG),
                    String(stats.fgPct),
                    String(stats.fg3aPG),
                    String(stats.fg3mPG),
                    String(stats.fg3Pct),
                    String(stats.ftaPG),
                    String(stats.ftmPG),
                    String(stats.ftPct),
                    String(stats.drebPG),
                    String(stats.blkPG),
                    String(stats.stlPG),
                    String(stats.rebPG),
                    String(stats.tovPG),
                    String(stats.pfPG),
                    String(stats.pfdPG),
                    String(stats.blkaPG),
                    String(stats.plusMinusPG),
                    String(stats.gp),
                    stats.minPG,
                    String(stats.wins),
                    String(stats.losses),
                    String(stats.winsPct),
                    String(stats.td3),
                    String(stats.dd2)
                ]
            )
        }
        
        VStack {
            if show {
                StandingsViewContainer(
                    state: StandingsContainerState(
                        secondCategories: StringConstants.NBA.playerStandingsSecondCategories,
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
                            store.send(.showPlayerStats(id: id))
                        },
                        showMoreStandingsAction: { isUp in
                            store.send(.showMoreStandings(isUp: isUp))
                        }
                    ),
                    titleContent: {
                        NBATitle(
                            leagueName: "NBA 정규시즌",
                            leagueSeason: Int(store.baseStandings.displayModel.standings.first?.stats.groupValue.split(separator: "-").first ?? "\(CalendarUtil.currentYear)")
                        )
                    },
                    customListContent: { _ in }
                )
            }
        }
        .onAppear {
            if !didPop {
                store.send(.baseStandings(.initData))
            }
            
            // TODO: 왜 SearchView 애니메이션은 안먹히지?
            // NOTE: show를 먼저하고 .initData를 나중에하면 애니메이션이 다름(카테고리가 위에서 내려오고, 순위 리스트는 오른쪽에서 나옴)
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}
