//
//  MLBTournamentView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/29/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBTournamentView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<MLBTournamentStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseTournament.displayModel
        
        VStack {
            if show {
                TournamentBracketViewContainer(
                    state: TournamentBracketContainerState(
                        leagueId: displayModel.leagueId,
                        teamNameDic: store.baseTournament.teamNameDic,
                        gameListTuple: store.gameListTuple,
                        seedIdTupleList: store.seedIdTupleList,
                        isConference: true,
                        isSeries: true
                    ),
                    action: TournamentContainerAction(
                        selectSeries: { gameList in
                            store.send(.selectSeries(gameList: gameList))
                        }
                    )
                )
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
