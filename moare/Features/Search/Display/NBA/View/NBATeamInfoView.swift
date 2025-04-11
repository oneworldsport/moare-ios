//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTeamInfoStore: StoreOf<NBATeamInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATeamInfoDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            if let nbaTeamInfoStore {
            }
        }
    }
}
