//
//  KBOTournamentView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/17/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTournamentView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<KBOTournamentStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        VStack {
            if show {
                TournamentBracketViewContainer(
                    state: TournamentBracketContainerState(
                        leagueId: store.baseTournament.displayModel.leagueId,
                        teamNameDic: store.baseTournament.teamNameDic,
                        gameListTuple: store.gameListTuple,
                        seedIdTupleList: store.seedIdTupleList,
                        isConference: false,
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
