//
//  StoreManager.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct StoreKeys {
    static let searchStore = "SearchStore"
    static let fbPlayerInfoStore = "FBPlayerInfoStore"
    static let fbPlayerStatsStore = "FBPlayerStatsStore"
    static let fbPlayerStandingsStore = "FBPlayerStandingsStore"
    static let fbTeamInfoStore = "FBTeamInfoStore"
    static let fbTeamStatsStore = "FBTeamStatsStore"
    static let fbTeamStandingsStore = "FBTeamStandingsStore"
    static let fbTeamScheduleStore = "FBTeamScheduleStore"
    static let fbLeagueScheduleStore = "FBLeagueScheduleStore"
    static let fbGameStatsStore = "FBGameStatsStore"
}

class StoreManager: ObservableObject {
    @Published private var stores: [String: Any] = [:]

    
    func getStore<State, Action>(forKey key: String) -> Store<State, Action>? {
        stores[key] as? Store<State, Action>
    }
    
    func setStore<State, Action>(_ store: Store<State, Action>, forKey key: String) {
        stores[key] = store
    }
}
