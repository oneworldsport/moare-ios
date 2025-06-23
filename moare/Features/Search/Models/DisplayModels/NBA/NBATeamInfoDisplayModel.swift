//
//  FootballTeamInfoDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct NBATeamInfoDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let team: NBATeamInfo
    let venue: NBAVenue
    let stats: NBATeamStats?
    let lastGame: NBAGame?
    let nextGame: NBAGame?
}
