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
    
    // football
    static let fbPlayerInfoStore = "FBPlayerInfoStore"
    static let fbPlayerStatsStore = "FBPlayerStatsStore"
    static let fbPlayerStandingsStore = "FBPlayerStandingsStore"
    static let fbTeamInfoStore = "FBTeamInfoStore"
    static let fbTeamStatsStore = "FBTeamStatsStore"
    static let fbTeamStandingsStore = "FBTeamStandingsStore"
    static let fbTeamScheduleStore = "FBTeamScheduleStore"
    static let fbLeagueScheduleStore = "FBLeagueScheduleStore"
    static let fbGameStatsStore = "FBGameStatsStore"
    
    // nba
    static let nbaPlayerInfoStore = "NBAPlayerInfoStore"
    static let nbaPlayerStatsStore = "NBAPlayerStatsStore"
    static let nbaPlayerStandingsStore = "NBAPlayerStandingsStore"
    static let nbaTeamInfoStore = "NBATeamInfoStore"
    static let nbaTeamStatsStore = "NBATeamStatsStore"
    static let nbaTeamStandingsStore = "NBATeamStandingsStore"
    static let nbaTeamScheduleStore = "NBATeamScheduleStore"
    static let nbaLeagueScheduleStore = "NBALeagueScheduleStore"
    static let nbaGameStatsStore = "NBAGameStatsStore"
    static let nbaLeagueTournamentStore = "NBALeagueTournamentStore"
    
    // kbo
    static let kboPlayerInfoStore = "KBOPlayerInfoStore"
    static let kboPlayerStatsStore = "KBOPlayerStatsStore"
    static let kboPlayerStandingsStore = "KBOPlayerStandingsStore"
    static let kboTeamInfoStore = "KBOTeamInfoStore"
    static let kboTeamStatsStore = "KBOTeamStatsStore"
    static let kboTeamStandingsStore = "KBOTeamStandingsStore"
    static let kboTeamScheduleStore = "KBOTeamScheduleStore"
    static let kboLeagueScheduleStore = "KBOLeagueScheduleStore"
    static let kboGameStatsStore = "KBOGameStatsStore"
    
    // mlb
    static let mlbPlayerInfoStore = "MLBPlayerInfoStore"
    static let mlbPlayerStatsStore = "MLBPlayerStatsStore"
    static let mlbPlayerStandingsStore = "MLBPlayerStandingsStore"
    static let mlbTeamInfoStore = "MLBTeamInfoStore"
    static let mlbTeamStatsStore = "MLBTeamStatsStore"
    static let mlbTeamStandingsStore = "MLBTeamStandingsStore"
    static let mlbTeamScheduleStore = "MLBTeamScheduleStore"
    static let mlbLeagueScheduleStore = "MLBLeagueScheduleStore"
    static let mlbGameStatsStore = "MLBGameStatsStore"
    
    // sign
    static let signStore = "SignStore"
    static let moatStore = "MoatStore"
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
