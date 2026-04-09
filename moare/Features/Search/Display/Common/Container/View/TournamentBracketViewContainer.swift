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
    
    // zoom
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var contentSize: CGSize = .zero
    private let minZoomScale = 0.3
    private let maxZoomScale = 1.3
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(state.gameListTuple.indices, id: \.self) { roundIndex in
                    let item = state.gameListTuple[roundIndex]
                    let maxRound = state.gameListTuple.count
                    let roundIndexForPosition = roundIndex + 1
                    let gameList = item.gameList
                    let title = item.title
                    let isLeft = state.isConference ? leftBracketTitles.contains(String(title.split(separator: " ").first ?? "")) : true
                    let isMLB = state.leagueId == Constants.Ids.mlb
                    let isKBO = state.leagueId == Constants.Ids.kbo
                    let isSeries = if state.leagueId == Constants.Ids.mls {
                        // mls는 (동/서부)1라운드만 series
                        roundIndex == 0 || roundIndex == 6
                    } else if Constants.Ids.footballUEFALeagues.contains(state.leagueId) {
                        // uefa리그들은 final만 single
                        roundIndex != 3
                    } else {
                        state.isSeries
                    }
                    
                    // left
                    if isLeft {
                        VStack(spacing: 0) {
                            Text(title)
                                .fontWeight(.medium)
                                .frame(minWidth: 170)
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
                                        maxRound: maxRound,
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
                                    .frame(minWidth: 170)
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
                                    .frame(minWidth: 170)
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
                                            maxRound: maxRound,
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
            // zoom
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            updateContentSize(proxy.size)
                        }
                        .onChange(of: proxy.size) {
                            updateContentSize(proxy.size)
                        }
                }
            )
            .scaleEffect(scale, anchor: .topLeading)
            .padding()
            .frame(
                width: contentSize.width * scale,
                height: contentSize.height * scale,
                alignment: .topLeading
            )
        }
        // zoom
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = min(max(lastScale * value, minZoomScale), maxZoomScale)
                }
                .onEnded { _ in
                    lastScale = scale
                }
        )
    }
    
    private func h(_ r: Int, _ s: Int, _ direction: RoundDirection) -> CGFloat {
        switch direction {
        case .left:
            return leftItemHeights[RoundSeriesKey(round: r, series: s)] ?? 0
        case .right:
            return rightItemHeights[RoundSeriesKey(round: r, series: s)] ?? 0
        }
    }
    
    private func bottomPadding(_ round: Int, _ series: Int, _ direction: RoundDirection) -> CGFloat {
        precondition(round >= 1, "round must be >= 1")
        precondition(series >= 1, "series must be >= 1")
        
        let k = series.trailingZeroBitCount
        
        let newRound: Int
        switch direction {
        case .left:
            newRound = round + k + 1
        case .right:
            newRound = round - k - 1
        }
        
        let newSeries = ((series >> k) + 1) / 2
        
        return h(newRound, newSeries, direction)
    }
    
    // zoom
    private func updateContentSize(_ newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }
        guard abs(contentSize.width - newSize.width) > 0.5 ||
              abs(contentSize.height - newSize.height) > 0.5 else { return }
        contentSize = newSize
    }
}
