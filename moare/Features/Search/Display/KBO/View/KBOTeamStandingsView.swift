//
//  KBOTeamStandingsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/8/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTeamStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var kboTeamStandingsStore: StoreOf<KBOTeamStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: KBOTeamStandingsDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            let standings: [StandingsItemState] = kboTeamStandingsStore?.standings.map {
                let rankData = $0.stats.rankData
                let hitterData = $0.stats.hitterData
                let pitcherData = $0.stats.pitcherData
                let runnerData = $0.stats.runnerData
                
                return StandingsItemState(
                    imageUrl: KBOUtil.teamLogoURL(id: $0.team.id),
                    name: kboTeamStandingsStore?.baseTeamStandings.teamNameDictionary["short_\($0.team.id)"] ?? $0.team.teamName,
                    dataList: [
                        rankData.winpct,
                        rankData.gb,
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
            } ?? []
            
            // NOTE: Wrapped with VStack for store initializing
            VStack {
                if let kboTeamStandingsStore {
                    StandingsViewContainer(
                        state: StandingsContainerState(
                            secondCategories: StringConstants.KBO.teamStandingsCategories,
                            standings: standings,
                            secondCategorySelectedIndex: kboTeamStandingsStore.baseTeamStandings.secondCategorySelectedIndex
                        ),
                        actions: StandingsContainerActions(
                            secondCategoryButtonAction: { index, _ in
                                kboTeamStandingsStore.send(.baseTeamStandings(.selectSecondCategory(index)))
                            },
                            itemButtonAction: { id in
                                
                            }
                        ),
                        titleContent: {
                            HStack {
                                BaseballLeagueTitle(
                                    logoUrl: KBOUtil.kboLogoUrl,
                                    name: "KBO",
                                    season: kboTeamStandingsStore.standings.first?.stats.season ?? 2025
                                )
    
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                        },
                        customListContent: { _ in }
                    )
                }
            }
            .onAppear {
                // init KBOTeamStandingsStore
                let kboTeamStandingsStore: StoreOf<KBOTeamStandingsStore> = storeManager.getStore(forKey: StoreKeys.kboTeamStandingsStore) ?? {
                    let newStore = Store(initialState: KBOTeamStandingsStore.State()) { KBOTeamStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboTeamStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.kboTeamStandingsStore = kboTeamStandingsStore
                }
                
                if searchStore.poppedView == nil {
                    kboTeamStandingsStore.send(.baseTeamStandings(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .kboTeamStandings = searchStore.poppedView {
                    kboTeamStandingsStore?.send(.baseTeamStandings(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

