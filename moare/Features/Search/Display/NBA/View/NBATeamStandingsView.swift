//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATeamStandingsDisplayModel
    
    private let columnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80]
    
    private let headerCategories = ["서부 컨퍼런스", "동부 컨퍼런스"]
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            let teamStandings: [StandingsItemState] = nbaTeamStandingsStore?.standings.map {
                let stats = $0.stats
                return StandingsItemState(
                    id: $0.team.id,
                    imageUrl: NBAUtil.teamLogoURL(id: $0.team.id),
                    name: nbaTeamStandingsStore?.teamNameDictionary["short_\($0.team.id)"] ?? $0.team.fullName,
                    dataList: [
                        String(calculateGamesBack(team: stats, standings: nbaTeamStandingsStore?.standings ?? [])),
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
            } ?? []
            
            VStack {
                if let nbaTeamStandingsStore {
                    StandingsViewContainer(
                        state: StandingsContainerState(
                            headerCategories: headerCategories,
                            secondCategories: StringConstants.NBA.teamStandingsCategories,
                            standings: teamStandings,
                            headerCategorySelectedIndex: nbaTeamStandingsStore.selectedConferenceIndex,
                            secondCategorySelectedIndex: nbaTeamStandingsStore.selectedCategoryIndex,
                            columnWidthList: columnWidthList
                        ),
                        actions: StandingsContainerActions(
                            headerCategoryButtonAction: { index in
                                nbaTeamStandingsStore.send(.selectConference(index: index))
                            },
                            secondCategoryButtonAction: { index, _ in
                                nbaTeamStandingsStore.send(.selectCategory(index: index))
                            },
                            itemButtonAction: { id in
                                searchStore.send(.showTeamStats(teamId: id))
                            }
                        ),
                        titleContent: {
                            NBATitle(
                                leagueName: "NBA 정규시즌",
                                leagueSeason: Int(nbaTeamStandingsStore.displayModel?.standings.first?.stats.groupValue.split(separator: "-").first ?? "\(CalendarUtil.currentYear)")
                            )
                        },
                        customListContent: { _ in }
                    )
                }
            }
            .onAppear {
                // init NBATeamStandingsStore
                let nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore> = storeManager.getStore(forKey: StoreKeys.nbaTeamStandingsStore) ?? {
                    let newStore = Store(initialState: NBATeamStandingsStore.State()) { NBATeamStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaTeamStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaTeamStandingsStore = nbaTeamStandingsStore
                }
                
                if searchStore.poppedView == nil {
                    nbaTeamStandingsStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .nbaTeamStandings = searchStore.poppedView {
                    nbaTeamStandingsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
    
    private func calculateGamesBack(team: NBATeamStats, standings: [NBATeamStandingsDisplay]) -> Double {
        guard let leader = standings.max(by: { $0.stats.winsPct < $1.stats.winsPct }) else {
            return 0.0
        }

        let gamesBack = Double((leader.stats.wins - team.wins) + (team.losses - leader.stats.losses)) / 2.0
        return gamesBack
    }
}
