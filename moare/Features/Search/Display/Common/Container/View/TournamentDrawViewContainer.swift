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
        ScrollView(.horizontal) {
            ScrollView(.vertical) {
                HStack(alignment: .top) {
                    ForEach(state.gameListTuple.indices, id: \.self) { roundIndex in
                        let item = state.gameListTuple[roundIndex]
                        let gameList = item.gameList
                        let title = item.title
                        
                        VStack(spacing: 0) {
                            Text(title)
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 270)
                            HCapsuleBar()
                                .padding(.top, 6)
                                .padding(.bottom, 12)
                            
                            ForEach(gameList.indices, id: \.self) { index in
                                let games = gameList[index]
                                
                                if state.isSeries {
                                    // TODO: 추첨인데 시리즈인 경우가 생기면 작업
                                    ForEach(games, id: \.gameId) { game in
                                        
                                    }
                                } else {
                                    if let game = games.first {
                                        TournamentSingleGameItem(
                                            leagueId: state.leagueId,
                                            game: game,
                                            teamNameDic: state.teamNameDic
                                        )
                                        .padding(.bottom, 12)
                                    }
                                }
                            }
                        }
                        
                        if roundIndex != state.gameListTuple.count - 1 {
                            VCapsuleBar()
                                .padding(.top, 40)
                                .padding(.bottom, 12)
                                .opacity(0.5)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}
