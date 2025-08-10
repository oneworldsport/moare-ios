//
//  FootballPlayerInfoDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct FBPlayerInfoDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let info: FBPlayerInfo
    let stats: FBPlayerStats?
    let lastGame: FBGame?
    let lastGamePlayerStats: FBGamePlayerStatsDetail?
    let nextGame: FBGame?
}
