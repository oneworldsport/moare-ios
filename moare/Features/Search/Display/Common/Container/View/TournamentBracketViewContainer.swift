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
    let action: TournamentContainerAction<T>
    
    @State var leftItemHeights: [RoundSeriesKey: CGFloat] = [:]
    @State var rightItemHeights: [RoundSeriesKey: CGFloat] = [:]
    
    private let leftBracketTitles = ["서부", "NL", "와일드카드", "준플레이오프", "플레이오프", "한국시리즈"]
    private let rightBracketTitles = ["동부", "AL"]
    private let finalBracketTitles = ["NBA", "월드", "MLS"]
    private let mlbBracketTitles = ["NL", "AL"]
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollView(.vertical) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(state.gameListTuple.indices, id: \.self) { roundIndex in
                        let item = state.gameListTuple[roundIndex]
                        let roundIndexForPosition = roundIndex + 1
                        let gameList = item.gameList
                        let title = item.title
                        let isLeft = state.isConference ? leftBracketTitles.contains(String(title.split(separator: " ").first ?? "")) : true
                        let isMLB = state.leagueId == Constants.Ids.mlb
                        let isKBO = state.leagueId == Constants.Ids.kbo
                        let isSeries = state.leagueId == Constants.Ids.mls ? (roundIndex == 0 || roundIndex == 6) : state.isSeries // mls는 (동/서부)1라운드만 series
                        
                        // left
                        if isLeft {
                            VStack(spacing: 0) {
                                Text(title)
                                    .fontWeight(.medium)
                                HCapsuleBar()
                                    .padding(.top, 6)
                                    .padding(.bottom, 12)
                                
                                ForEach(gameList.indices, id: \.self) { seriesIndex in
                                    let games = gameList[seriesIndex]
                                    let seriesIndexForPosition = seriesIndex + 1
                                    
                                    if isSeries {
                                        TournamentSeriesLeftGameItem(
                                            leagueId: state.leagueId,
                                            teamNameDic: state.teamNameDic,
                                            games: games,
                                            itemPosition: RoundSeriesKey(round: roundIndexForPosition, series: seriesIndexForPosition),
                                            shouldRemoveHBar: isKBO || (isMLB && roundIndexForPosition == 2), // mlb 2라운드, kbo
                                            itemHeights: $leftItemHeights,
                                            selectSeries: action.selectSeries
                                        )
                                        .padding(.bottom, bottomPadding(roundIndexForPosition, seriesIndexForPosition, true))
                                    } else {
                                        TournamentBracketSingleLeftGameItem(
                                            leagueId: state.leagueId,
                                            teamNameDic: state.teamNameDic,
                                            game: games?.first,
                                            itemPosition: RoundSeriesKey(round: roundIndexForPosition, series: seriesIndexForPosition),
                                            itemHeights: $leftItemHeights,
                                            selectGame: action.selectGame
                                        )
                                        .padding(.bottom, bottomPadding(roundIndexForPosition, seriesIndexForPosition, true))
                                    }
                                }
                            }
                        }
                        
                        if state.isConference {
                            // final
                            if finalBracketTitles.contains(String(title.split(separator: " ").first ?? "")) {
                                VStack(spacing: 0) {
                                    Text(title)
                                        .fontWeight(.medium)
                                    HCapsuleBar()
                                        .padding(.top, 6)
                                        .padding(.bottom, 12)
                                    
                                    if let games = gameList.first, let games {
                                        if isSeries {
                                            TournamentSeriesFinalGameItem(
                                                leagueId: state.leagueId,
                                                teamNameDic: state.teamNameDic,
                                                games: games,
                                                itemHeights: $leftItemHeights,
                                                selectSeries: action.selectSeries
                                            )
                                        } else {
                                            TournamentBracketSingleFinalGameItem(
                                                leagueId: state.leagueId,
                                                teamNameDic: state.teamNameDic,
                                                game: games.first,
                                                itemHeights: $leftItemHeights,
                                                selectGame: action.selectGame
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // right
                            if rightBracketTitles.contains(String(title.split(separator: " ").first ?? "")) {
                                VStack(spacing: 0) {
                                    Text(title)
                                        .fontWeight(.medium)
                                    HCapsuleBar()
                                        .padding(.top, 6)
                                        .padding(.bottom, 12)
                                    
                                    ForEach(gameList.indices, id: \.self) { seriesIndex in
                                        let games = gameList[seriesIndex]
                                        let seriesIndexForPosition = seriesIndex + 1
                                        
                                        if isSeries {
                                            TournamentSeriesRightGameItem(
                                                leagueId: state.leagueId,
                                                teamNameDic: state.teamNameDic,
                                                games: games,
                                                itemPosition: RoundSeriesKey(round: roundIndexForPosition, series: seriesIndexForPosition),
                                                shouldRemoveHBar: isMLB && roundIndexForPosition == 6, // mlb 2라운드만
                                                itemHeights: $rightItemHeights,
                                                selectSeries: action.selectSeries
                                            )
                                            .padding(.bottom, bottomPadding(roundIndexForPosition, seriesIndexForPosition, false))
                                        } else {
                                            TournamentBracketSingleRightGameItem(
                                                leagueId: state.leagueId,
                                                teamNameDic: state.teamNameDic,
                                                game: games?.first,
                                                itemPosition: RoundSeriesKey(round: roundIndexForPosition, series: seriesIndexForPosition),
                                                itemHeights: $rightItemHeights,
                                                selectGame: action.selectGame
                                            )
                                            .padding(.bottom, bottomPadding(roundIndexForPosition, seriesIndexForPosition, false))
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
