//
//  KBOTournamentView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/17/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTournamentView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State var kboTournamentStore: StoreOf<KBOTournamentStore>? = nil
    
    let displayModel: KBOTournamentDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack {
                if let kboTournamentStore {
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
                // init KBOTournamentStore
                let kboTournamentStore: StoreOf<KBOTournamentStore> = storeManager.getStore(forKey: StoreKeys.kboTournamentStore) ?? {
                    let newStore = Store(initialState: KBOTournamentStore.State()) { KBOTournamentStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboTournamentStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.kboTournamentStore = kboTournamentStore
                }
                
                if searchStore.poppedView == nil {
                    kboTournamentStore.send(.baseTournament(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .kboTournament = searchStore.poppedView {
                    kboTournamentStore?.send(.baseTournament(.initData(displayModel: displayModel)))
                }
            }
        }
    }
}
