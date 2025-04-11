//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAGameStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaGameStatsStore: StoreOf<NBAGameStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBAGameStatsDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            if let nbaGameStatsStore {
            }
        }
    }
}
