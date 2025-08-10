//
//  KBOPlayerStandingsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOPlayerStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let standings: [KBOPlayerStandingsDisplay]
}

struct KBOPlayerStandingsDisplay: Equatable {
    let player: KBOPlayerInfo
    let stats: KBOPlayerStats
}
