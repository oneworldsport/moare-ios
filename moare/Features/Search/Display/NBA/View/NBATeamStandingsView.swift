//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamStandingsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTeamStandingsStore: StoreOf<NBATeamStandingsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATeamStandingsDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            if let nbaTeamStandingsStore {
            }
        }
    }
}
