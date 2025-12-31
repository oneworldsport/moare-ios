//
//  FootballDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct NBATeamStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let standings: [NBATeamStandingsDisplay]
}

struct NBATeamStandingsDisplay: Equatable {
    let team: NBATeamInfo
    var stats: NBATeamStats
}
