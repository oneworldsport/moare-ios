//
//  FBTeamStandingsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/17/24.
//

import SwiftUI
import ComposableArchitecture

struct FBTeamStandingsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<FBTeamStandingsStore>
    let didPop: Bool
    
    private let columnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 50, 50, 50, 100, 100]
    private let headerCategories = ["서부 컨퍼런스", "동부 컨퍼런스"]
    
    @State private var show = false
    
    var body: some View {
        let teamStandings: [StandingsItemState] = store.standings.map {
            return StandingsItemState(
                id: $0.team.id,
                imageUrl: $0.team.logo,
                name: store.baseStandings.teamNameDictionary["short_\($0.team.id)"] ?? $0.team.name,
                dataList: [
                    calculatePoints(data: $0.homeAwayStats),
                    String($0.homeAwayStats.wins.total),
                    String($0.homeAwayStats.draws.total),
                    String($0.homeAwayStats.loses.total),
                    String($0.homeAwayStats.played.total),
                    String($0.goalsFor.total),
                    String($0.goalsAgainst.total),
                    String($0.goalsFor.total - $0.goalsAgainst.total),
                    getRecordString(data: $0.homeAwayStats),
                    getRecordString(data: $0.homeAwayStats, isHome: false)
                ]
            )
        }
        
        VStack {
            if show {
                StandingsViewContainer(
                    state: StandingsContainerState(
                        headerCategories: store.isMLS ? headerCategories : nil,
                        secondCategories: StringConstants.Football.teamStandingsCategories,
                        standings: teamStandings,
                        headerCategorySelectedIndex: store.baseStandings.headerCategorySelectedIndex,
                        secondCategorySelectedIndex: store.baseStandings.categorySelectedIndex,
                        columnWidthList: columnWidthList
                    ),
                    actions: StandingsContainerActions(
                        headerCategoryButtonAction: { index in
                            store.send(.baseStandings(.selectHeaderCategory(index: index)))
                        },
                        secondCategoryButtonAction: { index, _ in
                            store.send(.baseStandings(.selectCategory(index: index)))
                        },
                        itemButtonAction: { id in
                            searchStore.send(.showTeamStats(teamId: id))
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
            if !didPop {
                store.send(.baseStandings(.initData))
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
    
    private func calculatePoints(data: FBTeamStatsFixtures) -> String {
        return "\((data.wins.total * 3) + data.draws.total)"
    }
    
    private func getRecordString(data: FBTeamStatsFixtures, isHome: Bool = true) -> String {
        return isHome ? "\(data.wins.home)승 \(data.draws.home)무 \(data.loses.home)패" :
        "\(data.wins.away)승 \(data.draws.away)무 \(data.loses.away)패"
    }
}
