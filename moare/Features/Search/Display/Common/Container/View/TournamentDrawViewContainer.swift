//
//  TournamentDrawViewContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 9/17/25.
//

import SwiftUI

// NOTE: 현재는 축구에서만 쓰임
struct TournamentDrawViewContainer<T: Decodable & Equatable>: View {
    let state: TournamentDrawContainerState<T>
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollView(.vertical) {
                HStack(alignment: .top) {
                    ForEach(state.gameListTuple.indices, id: \.self) { roundIndex in
                        let item = state.gameListTuple[roundIndex]
                        let games = item.gameList.compactMap { $0 }.flatMap { $0 }  // 중첩 배열인 gameList를(nil을 제거하고) 펼쳐서 1차원 배열로 만든다
                        let title = item.title
                        
                        VStack(spacing: 0) {
                            Text(title)
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 270)
                            HCapsuleBar()
                                .padding(.top, 6)
                                .padding(.bottom, 12)
                            
                            ForEach(games.indices, id: \.self) { index in
                                let game = games[index]
                                
                                if state.isSeries {
                                    // TODO: 추첨인데 시리즈인 경우가 생기면 작업
                                } else {
                                    TournamentSingleGameItem(
                                        leagueId: state.leagueId,
                                        game: game,
                                        teamNameDic: state.teamNameDic
                                    )
                                    .padding(.bottom, 12)
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
