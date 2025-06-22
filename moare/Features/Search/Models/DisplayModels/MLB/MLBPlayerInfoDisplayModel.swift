//
//  KBOPlayerInfoDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBPlayerInfoDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let info: MLBPlayerInfo
    let teamId: Int?
    let stats: MLBPlayerStats?
    let lastGame: MLBGame?
    let lastGamePlayerStats: MLBGameBoxscoreTeamPlayer?
    let nextGame: MLBGame?
}
