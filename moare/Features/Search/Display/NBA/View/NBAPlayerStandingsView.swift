//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBAPlayerStandingsDisplayModel
    
    private let columnWidthList: [CGFloat] = [80, 80, 80, 80, 80, 80, 80, 80, 80,
                                              80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 50,
                                              80, 80, 80, 80, 80, 80]
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var totalScrollDistance: CGFloat = 0
    @State private var oldOffset: CGFloat = 0
    
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    
    @State private var canShowMoreStandings = true
    
    @State private var hScrollOffset: CGFloat = 0
    
    let coordinateSpaceName = "PlayerStandings"
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            let playerStandings: [StandingsItemState] = nbaPlayerStandingsStore?.filteredStandings.map {
                let stats = $0.stats
                let id = $0.player.personId
                return StandingsItemState(
                    id: id,
                    imageUrl: NBAUtil.playerPhotoURL(id: id),
                    name: nbaPlayerStandingsStore?.playerNameDictionary["\(id)"]?.dropFirstWord ?? $0.player.displayFirstLast.dropFirstWord,
                    subName: nbaPlayerStandingsStore?.teamNameDictionary["short_\($0.player.teamId)"] ?? $0.player.teamCity,
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
            } ?? []
            
            VStack {
                if let nbaPlayerStandingsStore {
                    StandingsViewContainer(
                        state: StandingsContainerState(
                            secondCategories: StringConstants.NBA.playerStandingsSecondCategories,
                            standings: playerStandings,
                            secondCategorySelectedIndex: nbaPlayerStandingsStore.secondSelectedIndex,
                            highlightState: StandingsHighlightItemState(
                                itemIndex: nbaPlayerStandingsStore.entityIndex,
                                standingsStartIndex: nbaPlayerStandingsStore.filteredStandingsStartIndex,
                                allStandingsCount: nbaPlayerStandingsStore.standings.count
                            ),
                            displayDataState: nbaPlayerStandingsStore.displayDataState,
                            columnWidthList: columnWidthList
                        ),
                        actions: StandingsContainerActions(
                            secondCategoryButtonAction: { index, category in
                                nbaPlayerStandingsStore.send(.selectSecondCategory(index: index, category: category))
                            },
                            itemButtonAction: { id in
                                searchStore.send(.showPlayerStats(category: "basketball", playerId: id))
                            },
                            showMoreStandingsAction: { isUp in
                                nbaPlayerStandingsStore.send(.showMoreStandings(isUp: isUp))
                            }
                        ),
                        titleContent: {
                            NBATitle(
                                leagueName: "NBA 정규시즌",
                                leagueSeason: Int(nbaPlayerStandingsStore.displayModel?.standings.first?.stats.groupValue.split(separator: "-").first ?? "\(CalendarUtil.currentYear)")
                            )
                        },
                        customListContent: { _ in }
                    )
                }
            }
            .onAppear {
                // init NBAPlayerStandingsStore
                let nbaPlayerStandingsStore: StoreOf<NBAPlayerStandingsStore> = storeManager.getStore(forKey: StoreKeys.nbaPlayerStandingsStore) ?? {
                    let newStore = Store(initialState: NBAPlayerStandingsStore.State()) { NBAPlayerStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaPlayerStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaPlayerStandingsStore = nbaPlayerStandingsStore
                }
                
                if searchStore.poppedView == nil {
                    nbaPlayerStandingsStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .nbaPlayerStandings = searchStore.poppedView {
                    nbaPlayerStandingsStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
}
