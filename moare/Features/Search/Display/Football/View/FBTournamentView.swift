//
//  FBTournamentView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/15/25.
//

import SwiftUI
import ComposableArchitecture

struct FBTournamentView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State var fbTournamentStore: StoreOf<FBTournamentStore>? = nil
    
    let displayModel: FBTournamentDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack {
                if let fbTournamentStore {
                    if displayModel.scheduleType == .tournamentBracket {
                        
                    } else {
                        TournamentDrawViewContainer(
                            state: TournamentDrawContainerState(
                                leagueId: displayModel.leagueId,
                                gameListDic: fbTournamentStore.gameListDic,
                                teamNameDic: fbTournamentStore.baseTournament.teamNameDictionary
                            )
                        )
                    }
                }
            }
            .onAppear {
                // init FBTournamentStore
                let fbTournamentStore: StoreOf<FBTournamentStore> = storeManager.getStore(forKey: StoreKeys.fbTournamentStore) ?? {
                    let newStore = Store(initialState: FBTournamentStore.State()) { FBTournamentStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTournamentStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbTournamentStore = fbTournamentStore
                }
                
                if searchStore.poppedView == nil {
                    fbTournamentStore.send(.baseTournament(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .fbTournament = searchStore.poppedView {
                    fbTournamentStore?.send(.baseTournament(.initData(displayModel: displayModel)))
                }
            }
        }
    }
}
