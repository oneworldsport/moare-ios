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
                    // TODO: 축구에서 Bracket생기면 작업
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
