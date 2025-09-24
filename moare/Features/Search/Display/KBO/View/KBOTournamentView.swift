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
    
    @State private var show = false
    
    var body: some View {
        VStack {
            if show {
//                    TournamentDrawViewContainer(
//                        state: TournamentDrawContainerState(
//                            leagueId: displayModel.leagueId,
//                            teamNameDic: kboTournamentStore.baseTournament.teamNameDic,
//                            gameListTuple: kboTournamentStore.gameListTuple,
//                            isSeries: true
//                        )
//                    )
            }
        }
        .onAppear {
            store.send(.baseTournament(.initData))
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}
