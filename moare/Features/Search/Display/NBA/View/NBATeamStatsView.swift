//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTeamStatsStore: StoreOf<NBATeamStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATeamStatsDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            if let nbaTeamStatsStore {
            }
        }
    }
}
