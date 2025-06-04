//
//  KBOPlayerInfoDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOPlayerInfoDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let info: KBOPlayerInfo
    let stats: KBOPlayerStats?
    let lastGame: KBOGame?
    let lastGamePlayerHitterStats: KBOGameHitterStats?
    let lastGamePlayerPitcherStats: KBOGamePitcherStats?
    let nextGame: KBOGame?
}
