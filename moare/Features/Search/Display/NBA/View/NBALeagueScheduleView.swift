//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBALeagueScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaLeagueScheduleStore: StoreOf<NBALeagueScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBALeagueScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            if let nbaLeagueScheduleStore {
            }
        }
    }
}
