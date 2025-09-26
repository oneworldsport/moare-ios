//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamStandingsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<NBATeamStandingsStore>
    let didPop: Bool
    
    private let columnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80]
    private let headerCategories = ["서부 컨퍼런스", "동부 컨퍼런스"]
    
    @State private var show = false
    
    var body: some View {
        let teamStandings: [StandingsItemState] = store.standings.map {
            let stats = $0.stats
            return StandingsItemState(
                id: $0.team.id,
                imageUrl: NBAUtil.teamLogoURL(id: $0.team.id),
                name: store.baseStandings.teamNameDictionary["short_\($0.team.id)"] ?? $0.team.fullName,
                dataList: [
                    NBAUtil.calculateGamesBack(team: stats, standings: store.standings) == 0.0 ? "-" : String(NBAUtil.calculateGamesBack(team: stats, standings: store.standings)),
                    String(stats.winsPct),
                    String(stats.wins),
                    String(stats.losses),
                    String(stats.gp),
                    String(stats.ptsPG),
                    String(stats.plusMinusPG),
                    String(stats.astPG),
                    String(stats.rebPG),
                    String(stats.fgPct),
                    String(stats.fg3Pct),
                    String(stats.ftPct),
                    String(stats.blkPG),
                    String(stats.stlPG),
                    String(stats.tovPG),
                    String(stats.pfPG)
                ]
            )
        }
        
        VStack {
            if show {
                StandingsViewContainer(
                    state: StandingsContainerState(
                        headerCategories: headerCategories,
                        secondCategories: StringConstants.NBA.teamStandingsCategories,
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
                            store.send(.showTeamStats(id: id))
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
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}
