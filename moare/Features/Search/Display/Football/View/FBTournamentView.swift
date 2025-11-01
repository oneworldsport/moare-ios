//
//  FBTournamentView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/15/25.
//

import SwiftUI
import ComposableArchitecture

struct FBTournamentView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<FBTournamentStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseTournament.displayModel
        
        VStack {
            if show {
                if displayModel.scheduleType == .tournamentBracket {
                    TournamentBracketViewContainer(
                        state: TournamentBracketContainerState(
                            leagueId: displayModel.leagueId,
                            teamNameDic: store.baseTournament.teamNameDic,
                            gameListTuple: store.gameListTuple,
                            seedIdTupleList: store.seedIdTupleList,
                            isConference: true,
                            isSeries: false
                        ),
                        action: TournamentContainerAction(
                            selectSeries: { gameList in
                                store.send(.selectSeries(gameList: gameList))
                            },
                            selectGame: { game in
                                store.send(.selectGame(game: game))
                            }
                        )
                    )
                } else {
                    TournamentDrawViewContainer(
                        state: TournamentDrawContainerState(
                            leagueId: displayModel.leagueId,
                            teamNameDic: store.baseTournament.teamNameDic,
                            gameListTuple: store.gameListTuple,
                            isSeries: false
                        )
                    )
                }
            }
        }
        .onAppear {
            if !didPop {
                store.send(.baseTournament(.initData))
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}
