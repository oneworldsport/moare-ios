//
//  KBOTeamStandingsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/8/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTeamStandingsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<KBOTeamStandingsStore>
    let didPop: Bool
    
    private let columnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 60, 60, 50, 50, 50, 70]
    
    @State private var show = false
    
    var body: some View {
        let teamStandings: [StandingsItemState] = store.standings.map {
            let rankData = $0.stats.rankData
            let hitterData = $0.stats.hitterData
            let pitcherData = $0.stats.pitcherData
            let runnerData = $0.stats.runnerData
            
            return StandingsItemState(
                id: $0.team.id,
                imageUrl: KBOUtil.teamLogoURL(id: $0.team.id),
                name: store.baseStandings.teamNameDictionary["short_\($0.team.id)"] ?? $0.team.teamName,
                dataList: [
                    rankData.gb,
                    rankData.winpct,
                    rankData.wins,
                    rankData.losses,
                    rankData.gp,
                    rankData.streak,
                    hitterData.avg,
                    hitterData.h,
                    hitterData.hr,
                    hitterData.slg,
                    hitterData.r,
                    pitcherData.era,
                    pitcherData.avg,
                    pitcherData.h,
                    pitcherData.hr,
                    pitcherData.r,
                    runnerData.sbPercent
                ]
            )
        }
        
        // NOTE: Wrapped with VStack for store initializing
        VStack {
            if show {
                StandingsViewContainer(
                    state: StandingsContainerState(
                        secondCategories: StringConstants.KBO.teamStandingsCategories,
                        standings: teamStandings,
                        secondCategorySelectedIndex: store.baseStandings.categorySelectedIndex,
                        firstColumnWidth: 100,
                        columnWidthList: columnWidthList
                    ),
                    actions: StandingsContainerActions(
                        secondCategoryButtonAction: { index, _ in
                            store.send(.baseStandings(.selectCategory(index: index)))
                        },
                        itemButtonAction: { id in
                            searchStore.send(.showTeamStats(teamId: id))
                        }
                    ),
                    titleContent: {
                        BaseballLeagueTitle(
                            logoUrl: KBOUtil.kboLogoUrl,
                            name: "KBO",
                            season: store.standings.first?.stats.season
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

