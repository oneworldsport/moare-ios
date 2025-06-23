//
//  FootballPlayerGameStatsDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import Foundation

struct NBAPlayerStatsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let player: NBAPlayerInfo
    let stats: [NBAPlayerStats]
}
