//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBAPlayerInfoView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaPlayerInfoStore: StoreOf<NBAPlayerInfoStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBAPlayerInfoDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            if let nbaPlayerInfoStore {
            }
        }
    }
}
