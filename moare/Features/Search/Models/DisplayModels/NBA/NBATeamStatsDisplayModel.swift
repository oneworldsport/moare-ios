//
//  FootballTeamGameStatsDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import Foundation

struct NBATeamStatsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let team: NBATeamInfo
    let venue: NBAVenue
    let stats: [NBATeamStats]
}
