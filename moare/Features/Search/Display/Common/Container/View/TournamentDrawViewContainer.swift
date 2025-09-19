//
//  TournamentDrawViewContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 9/17/25.
//

import SwiftUI

struct TournamentDrawViewContainer<T: Decodable & Equatable>: View {
    let state: TournamentDrawContainerState<T>
    
    var body: some View {
        let leagueId = state.leagueId
        
        ScrollView(.horizontal) {
            ScrollView(.vertical) {
                HStack {
                    ForEach(Array(state.gameListDic.keys), id: \.self) { key in
                        let gameList = state.gameListDic[key] ?? []
                        
                        VStack(spacing: 0) {
                            Text(key)
                                .font(.system(size: 20, weight: .medium))
                            HCapsuleBar()
                                .padding(.top, 4)
                                .padding(.bottom, 8)
                            
                            ForEach(gameList.indices, id: \.self) { index in
                                let games = gameList[index]
                                
                                if state.isSeries {
                                    ForEach(games, id: \.gameId) { game in
                                        
                                    }
                                } else {
                                    if let game = games.first {
                                        let shouldShowScore = game.gameStatus != Constants.GameStatus.Football.notStarted
                                        
                                        TournamentSingleGameItem(state: TournamentGameItemState(
                                            homeTeamLogo: Util.teamLogoURL(leagueId: leagueId, teamId: game.homeTeamId),
                                            homeTeamName: state.teamNameDic["short_\(game.homeTeamId)"] ?? "",
                                            homeTeamScore: shouldShowScore ? game.homeTeamScore : nil,
                                            awayTeamLogo: Util.teamLogoURL(leagueId: leagueId, teamId: game.awayTeamId),
                                            awayTeamName: state.teamNameDic["short_\(game.awayTeamId)"] ?? "",
                                            awayTeamScore: shouldShowScore ? game.awayTeamScore : nil,
                                            gameStatusText: Constants.GameStatus.gameStatusText(leagueId: leagueId, status: game.gameStatus),
                                            gameStatusColor: Constants.GameStatus.gameStatusColor(leagueId: leagueId, status: game.gameStatus),
                                            date: game.date)
                                        )
                                        .padding(.bottom, 8)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}
