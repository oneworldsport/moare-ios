//
//  MLBTeamStandingsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/8/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBTeamStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var mlbTeamStandingsStore: StoreOf<MLBTeamStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: MLBTeamStandingsDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            
            VStack {
                if let mlbTeamStandingsStore {
                    StandingsViewContainer(
                        state: StandingsContainerState(
                            headerCategories: StringConstants.MLB.conferenceCategory,
                            secondCategories: StringConstants.MLB.teamStandingsCategories,
                            standings: [],
                            headerCategorySelectedIndex: mlbTeamStandingsStore.headerCategorySelectedIndex,
                            secondCategorySelectedIndex: mlbTeamStandingsStore.baseTeamStandings.secondCategorySelectedIndex,
                            columnWidthList: mlbTeamStandingsStore.columnWidthList
                        ),
                        actions: StandingsContainerActions(
                            headerCategoryButtonAction: { index in
                                mlbTeamStandingsStore.send(.selectHeaderCategory(index: index))
                            },
                            secondCategoryButtonAction: { index, _ in
                                mlbTeamStandingsStore.send(.baseTeamStandings(.selectSecondCategory(index)))
                            },
                            itemButtonAction: { _ in
                            }
                        ),
                        shouldUseCustomListContent: true,
                        titleContent: {
                            BaseballLeagueTitle(
                                logoUrl: MLBUtil.mlbLogoUrl,
                                name: "MLB",
                                season: mlbTeamStandingsStore.westStandings.first?.team.season
                            )
                        },
                        customListContent: { totalHScrollDistance in
                            VStack {
                                // west
                                MLBTeamStandingsDataList(
                                    mlbTeamStandingsStore: mlbTeamStandingsStore,
                                    divisionTitle: "서부",
                                    standings: mlbTeamStandingsStore.westStandings,
                                    totalHScrollDistance: totalHScrollDistance
                                )
                                
                                // east
                                MLBTeamStandingsDataList(
                                    mlbTeamStandingsStore: mlbTeamStandingsStore,
                                    divisionTitle: "동부",
                                    standings: mlbTeamStandingsStore.eastStandings,
                                    totalHScrollDistance: totalHScrollDistance
                                )
                                
                                // central
                                MLBTeamStandingsDataList(
                                    mlbTeamStandingsStore: mlbTeamStandingsStore,
                                    divisionTitle: "중부",
                                    standings: mlbTeamStandingsStore.centralStandings,
                                    totalHScrollDistance: totalHScrollDistance
                                )
                            }
                        }
                    )
                }
            }
            .onAppear {
                // init MLBTeamStandingsStore
                let mlbTeamStandingsStore: StoreOf<MLBTeamStandingsStore> = storeManager.getStore(forKey: StoreKeys.mlbTeamStandingsStore) ?? {
                    let newStore = Store(initialState: MLBTeamStandingsStore.State()) { MLBTeamStandingsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.mlbTeamStandingsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.mlbTeamStandingsStore = mlbTeamStandingsStore
                }
                
                if searchStore.poppedView == nil {
                    mlbTeamStandingsStore.send(.baseTeamStandings(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .mlbTeamStandings = searchStore.poppedView {
                    mlbTeamStandingsStore?.send(.baseTeamStandings(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

struct MLBTeamStandingsDataList: View {
    @Bindable var mlbTeamStandingsStore: StoreOf<MLBTeamStandingsStore>
    
    let divisionTitle: String
    let standings: [MLBTeamStandingsDisplay]
    let totalHScrollDistance: CGFloat
    
    var body: some View {
        let teamNameDic = mlbTeamStandingsStore.baseTeamStandings.teamNameDictionary
        
        HStack(spacing: 0) {
            // title, rank items
            VStack(spacing: 0) {
                ForEach(0..<(standings.count + 1), id:\.self) { index in
                    if index == 0 {
                        Text(divisionTitle)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                        
                        HCapsuleBar()
                    } else {
                        let data = standings[index - 1]
                        
                        StandingsRankItem(
                            rank: index,
                            imageUrl: MLBUtil.teamLogoURL(id: data.team.id),
                            isSvgLogo: true,
                            name: teamNameDic["short_\(data.team.id)"] ?? data.team.shortName,
                            action: { id in
                                
                            }
                        )
                    }
                }
            }
            .background(.white)
            .zIndex(1)
            .offset(x: totalHScrollDistance < 0 ? 0 : totalHScrollDistance)
            
            // data items
            VStack(spacing: 0) {
                ForEach(0..<(standings.count + 1), id:\.self) { index in
                    HStack(spacing: 0) {
                        if index == 0 {
                            EmptyView()
                        } else {
                            let data = standings[index - 1]
                            
                            ForEach(0..<StringConstants.MLB.teamStandingsCategories.count, id:\.self) { index in
                                MLBTeamStandingsDataListItem(
                                    mlbTeamStandingsStore: mlbTeamStandingsStore,
                                    data: data,
                                    index: index
                                )
                            }
                        }
                    }
                    .frame(height: 40)
                }
            }
        }
    }
}

struct MLBTeamStandingsDataListItem: View {
    @Bindable var mlbTeamStandingsStore: StoreOf<MLBTeamStandingsStore>
    
    let data: MLBTeamStandingsDisplay
    let index: Int
    
    var body: some View {
        Text(intDataText)
            .font(.system(size: 15))
            .frame(width: mlbTeamStandingsStore.columnWidthList[safe: index] ?? 100)
    }
    
    private var intDataText: String {
        switch index {
        case 0:
            data.stats.recordData?.gamesBack ?? ""
        case 1:
            data.stats.recordData?.winningPercentage ?? ""
        case 2:
            String(data.stats.recordData?.wins ?? 0)
        case 3:
            String(data.stats.recordData?.losses ?? 0)
        case 4:
            String(data.stats.recordData?.gamesPlayed ?? 0)
        case 5:
            if let streak = data.stats.recordData?.streak {
                if streak.streakCode.hasPrefix("W") {
                    "\(streak.streakNumber)승"
                } else {
                    "\(streak.streakNumber)패"
                }
            } else {
                ""
            }
        case 6:
            data.stats.hitting?.avg ?? ""
        case 7:
            String(data.stats.hitting?.hits ?? 0)
        case 8:
            String(data.stats.hitting?.homeRuns ?? 0)
        case 9:
            data.stats.hitting?.slg ?? ""
        case 10:
            String(data.stats.hitting?.runs ?? 0)
        case 11:
            data.stats.pitching?.era ?? ""
        case 12:
            data.stats.pitching?.avg ?? ""
        case 13:
            String(data.stats.pitching?.hits ?? 0)
        case 14:
            String(data.stats.pitching?.homeRuns ?? 0)
        case 15:
            String(data.stats.pitching?.runs ?? 0)
        case 16:
            data.stats.hitting?.stolenBasePercentage ?? ""
            
        default:
            ""
        }
    }
}

