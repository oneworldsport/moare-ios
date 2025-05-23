//
//  FootballPlayerInfoDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct NBAPlayerInfoDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let info: NBAPlayerInfo
    let stats: NBAPlayerStats?
    let lastGame: NBAGame?
    let lastGamePlayerStats: NBABoxScoreTeamPlayer?
    let nextGame: NBAGame?
}
