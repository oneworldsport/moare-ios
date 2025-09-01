//
//  FootballTeamInfoDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct FBTeamInfoDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let team: FBTeamInfo
    let venue: FBVenue
    let stats: FBTeamStats?
    let lastGame: FBGame?
    let nextGame: FBGame?
}
