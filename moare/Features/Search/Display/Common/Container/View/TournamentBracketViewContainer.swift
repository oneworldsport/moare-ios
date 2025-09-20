//
//  TournamentViewContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 9/16/25.
//

import SwiftUI

struct RoundSeriesKey: Hashable {
    let round: Int
    let series: Int
}

struct TournamentBracketViewContainer<T: Decodable & Equatable>: View {
    let state: TournamentBracketContainerState<T>
    
    @State var leftItemHeights: [RoundSeriesKey: CGFloat] = [:]
    @State var rightItemHeights: [RoundSeriesKey: CGFloat] = [:]
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollView(.vertical) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(state.gameListTuple.indices, id: \.self) { roundIndex in
                        let item = state.gameListTuple[roundIndex]
                        let roundIndexForPosition = roundIndex + 1
                        let gameList = item.gameList
                        let title = item.title
                        let shouldShow = state.isConference ? title.contains("서부") : true
                        
                        // default or west
                        if shouldShow {
                            VStack(spacing: 0) {
                                Text(title)
                                
                                ForEach(gameList.indices, id: \.self) { seriesIndex in
                                    let games = gameList[seriesIndex]
                                    let seriesIndexForPosition = seriesIndex + 1
                                    
                                    if state.isSeries {
                                        TournamentSeriesLeftGameItem(
                                            leagueId: state.leagueId,
                                            teamNameDic: state.teamNameDic,
                                            games: games,
                                            itemPosition: RoundSeriesKey(round: roundIndexForPosition, series: seriesIndexForPosition),
                                            itemHeights: $leftItemHeights
                                        )
                                        .padding(.bottom, bottomPadding(roundIndexForPosition, seriesIndexForPosition, true))
                                    } else {
                                        if let game = games.first {
                                            TournamentSingleGameItem(state: TournamentGameItemState(
                                                homeTeamLogo: FBUtil.teamLogoURL(id: game.homeTeamId),
                                                homeTeamName: "",
                                                homeTeamScore: game.homeTeamScore,
                                                awayTeamLogo: FBUtil.teamLogoURL(id: game.awayTeamId),
                                                awayTeamName: "",
                                                awayTeamScore: game.awayTeamScore,
                                                gameStatusText: "",
                                                gameStatusColor: Color.moare,
                                                date: game.date)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        
                        if state.isConference {
                            // final
                            if title.contains("NBA 파이널") {
                                if let games = gameList.first {
                                    TournamentSeriesFinalGameItem(
                                        leagueId: state.leagueId,
                                        teamNameDic: state.teamNameDic,
                                        games: games
                                    )
                                }
                            }
                            
                            // east
                            if title.contains("동부") {
                                VStack(spacing: 0) {
                                    Text(item.title)
                                    
                                    ForEach(gameList.indices, id: \.self) { seriesIndex in
                                        let games = gameList[seriesIndex]
                                        let seriesIndexForPosition = seriesIndex + 1
                                        
                                        if state.isSeries {
                                            TournamentSeriesRightGameItem(
                                                leagueId: state.leagueId,
                                                teamNameDic: state.teamNameDic,
                                                games: games,
                                                itemPosition: RoundSeriesKey(round: roundIndexForPosition, series: seriesIndexForPosition),
                                                itemHeights: $rightItemHeights
                                            )
                                            .padding(.bottom, bottomPadding(roundIndexForPosition, seriesIndexForPosition, false))
                                        } else {
                                            if let game = games.first {
                                                TournamentSingleGameItem(state: TournamentGameItemState(
                                                    homeTeamLogo: FBUtil.teamLogoURL(id: game.homeTeamId),
                                                    homeTeamName: "",
                                                    homeTeamScore: game.homeTeamScore,
                                                    awayTeamLogo: FBUtil.teamLogoURL(id: game.awayTeamId),
                                                    awayTeamName: "",
                                                    awayTeamScore: game.awayTeamScore,
                                                    gameStatusText: "",
                                                    gameStatusColor: Color.moare,
                                                    date: game.date)
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func h(_ r: Int, _ s: Int, _ isLeft: Bool) -> CGFloat {
        isLeft ? (leftItemHeights[RoundSeriesKey(round: r, series: s)] ?? 0) : (rightItemHeights[RoundSeriesKey(round: r, series: s)] ?? 0)
    }
    
    private func bottomPadding(_ r: Int, _ s: Int, _ isLeft: Bool) -> CGFloat {
        if isLeft {
            switch (r, s) {
            case (1, 1): return h(2, 1, isLeft)
            case (1, 2): return h(3, 1, isLeft)
            case (1, 3): return h(2, 2, isLeft)
            case (2, 1): return h(3, 1, isLeft)
            default: return 0
            }
        } else {
            switch (r, s) {
            case (7, 1): return h(6, 1, isLeft)
            case (7, 2): return h(5, 1, isLeft)
            case (7, 3): return h(6, 2, isLeft)
            case (6, 1): return h(5, 1, isLeft)
            default: return 0
            }
        }
    }
}
