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
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseStandings.displayModel
        let leagueId = displayModel.leagueId
        
        let teamStandings: [StandingsItemState] = store.standings.map {
            return StandingsItemState(
                id: $0.team.id,
                rank: $0.displayRank,
                imageUrl: $0.team.logo,
                name: store.baseStandings.teamNameDictionary["short_\($0.team.id)"] ?? $0.team.name,
                dataList: [
//                    calculatePoints(data: $0.homeAwayStats),
                    String($0.points),
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
        
        let columnWidthList: [CGFloat] = leagueId == Constants.Ids.worldCup ? [50, 50, 50, 50, 50, 50, 50, 50] : [50, 50, 50, 50, 50, 50, 50, 50, 100, 100]
        let headerCategories = leagueId == Constants.Ids.worldCup ? ["A조 ~ F조", "G조 ~ L조"] : ["서부 컨퍼런스", "동부 컨퍼런스"]
        
        VStack {
            if show {
                StandingsViewContainer(
                    state: StandingsContainerState(
                        headerCategories: store.isMLS || store.isGroupStandings ? headerCategories : nil,
                        secondCategories: store.isGroupStandings ? StringConstants.Football.teamGroupStandingsCategories : StringConstants.Football.teamStandingsCategories,
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
                            // TODO: UEFA 리그는 showTeamStats가 안돼서 Button disabled 처리 해야함.
                            store.send(.showTeamStats(id: id))
                        }
                    ),
                    shouldUseCustomListContent: leagueId == Constants.Ids.worldCup,
                    titleContent: {
                        if let league = store.league {
                            FBLeagueTitle(
                                url: league.logo,
                                leagueName: league.name,
                                leagueSeason: league.season
                            )
                        }
                    },
                    customListContent: { totalHScrollDistance in
                        let groupStandings = store.groupStandings
                        
                        VStack {
                            ForEach(groupStandings.keys.sorted(), id: \.self) { group in
                                if let standings = groupStandings[group] {
                                    FBTeamStandingsDataList(
                                        searchStore: searchStore,
                                        fbTeamStandingsStore: store,
                                        group: "\(group)조",
                                        standings: standings,
                                        totalHScrollDistance: totalHScrollDistance
                                    )
                                }
                            }
                        }
                    }
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

struct FBTeamStandingsDataList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>
    
    let group: String
    let standings: [FBTeamStandingsDisplay]
    let totalHScrollDistance: CGFloat
    
    var body: some View {
        let displayModel = fbTeamStandingsStore.baseStandings.displayModel
        let leagueId = displayModel.leagueId
        let teamNameDic = fbTeamStandingsStore.baseStandings.teamNameDictionary
        
        HStack(spacing: 0) {
            // title, rank items
            VStack(spacing: 0) {
                ForEach(0..<(standings.count + 1), id:\.self) { index in
                    if index == 0 {
                        Text(group)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                        
                        HCapsuleBar()
                    } else {
                        let data = standings[index - 1]
                        
                        StandingsRankItem(
                            id: data.team.id,
                            rank: data.displayRank,
                            imageUrl: Util.teamLogoURL(leagueId: leagueId, teamId: data.team.id),
                            name: teamNameDic["short_\(data.team.id)"] ?? data.team.name,
                            action: { id in
                                fbTeamStandingsStore.send(.showTeamStats(id: id))
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
                            
                            ForEach(0..<StringConstants.Football.teamGroupStandingsCategories.count, id:\.self) { index in
                                FBTeamStandingsDataListItem(
                                    fbTeamStandingsStore: fbTeamStandingsStore,
                                    data: data,
                                    standings: standings,
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

struct FBTeamStandingsDataListItem: View {
    @Bindable var fbTeamStandingsStore: StoreOf<FBTeamStandingsStore>
    
    let data: FBTeamStandingsDisplay
    let standings: [FBTeamStandingsDisplay]
    let index: Int
    
    var body: some View {
        Text(intDataText)
            .font(.system(size: 15))
            .frame(width: 50)
    }
    
    private var intDataText: String {
        switch index {
        case 0:
            String(data.points)
        case 1:
            String(data.homeAwayStats.wins.total)
        case 2:
            String(data.homeAwayStats.draws.total)
        case 3:
            String(data.homeAwayStats.loses.total)
        case 4:
            String(data.homeAwayStats.played.total)
        case 5:
            String(data.goalsFor.total)
        case 6:
            String(data.goalsAgainst.total)
        case 7:
            String(data.goalsFor.total - data.goalsAgainst.total)
            
        default:
            ""
        }
    }
}
