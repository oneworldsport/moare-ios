//
//  FBTeamStandingsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/17/24.
//

import SwiftUI
import ComposableArchitecture

struct FBTeamStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBTeamStandingsDisplayModel
    
    private let columnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 50, 50, 50, 100, 100]
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            let teamStandings: [StandingsItemState] = fbTeamStandingsStore?.standings.map {
                return StandingsItemState(
                    id: $0.team.id,
                    imageUrl: $0.team.logo,
                    name: fbTeamStandingsStore?.teamNameDictionary["short_\($0.team.id)"] ?? $0.team.name,
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
            } ?? []
            
            VStack {
                if let fbTeamStandingsStore {
                    StandingsViewContainer(
                        state: StandingsContainerState(
                            secondCategories: StringConstants.Football.teamStandingsCategories,
                            standings: teamStandings,
                            secondCategorySelectedIndex: fbTeamStandingsStore.selectedIndex,
                            columnWidthList: columnWidthList
                        ),
                        actions: StandingsContainerActions(
                            secondCategoryButtonAction: { index, _ in
                                fbTeamStandingsStore.send(.selectCategory(index))
                            },
                            itemButtonAction: { id in
                                searchStore.send(.showTeamStats(teamId: id))
                            }
                        ),
                        titleContent: {
                            if let league = fbTeamStandingsStore.league {
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
                // init FBTeamStandingsStore
                let fbTeamStandingsStore: StoreOf<FBTeamStandingsStore> = storeManager.getStore(forKey: StoreKeys.fbTeamStandingsStore) ?? {
                    let newStore = Store(initialState: FBTeamStandingsStore.State()) { FBTeamStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTeamStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbTeamStandingsStore = fbTeamStandingsStore
                }
                
                if searchStore.poppedView == nil {
                    fbTeamStandingsStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                // NOTE: When come to this view(go back action) from same type of view(FBTeamStandingsView), .onAppear is not triggered.
                // So this .onChange is used to execute .initData. Should think about better structure.
                // And still has problem about some properties in store like some ui states, not sustaining its before value.
                if case .fbTeamStandings = searchStore.poppedView {
                    fbTeamStandingsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
    
    private func calculatePoints(data: FBTeamStatsFixtures) -> String {
        return "\((data.wins.total * 3) + data.draws.total)"
    }
    
    private func getRecordString(data: FBTeamStatsFixtures, isHome: Bool = true) -> String {
        return isHome ? "\(data.wins.home)승 \(data.draws.home)무 \(data.loses.home)패" :
        "\(data.wins.away)승 \(data.draws.away)무 \(data.loses.away)패"
    }
}
