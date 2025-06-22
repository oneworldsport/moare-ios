//
//  KBOPlayerStatsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOPlayerStatsDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let player: KBOPlayerInfo
    let stats: [KBOPlayerStats]
}
