//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaPlayerStatsStore: StoreOf<NBAPlayerStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBAPlayerStatsDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            if let nbaPlayerStatsStore {
            }
        }
    }
}
