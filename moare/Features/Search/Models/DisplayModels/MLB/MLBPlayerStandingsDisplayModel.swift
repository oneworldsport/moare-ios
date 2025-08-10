//
//  KBOPlayerStandingsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBPlayerStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let standings: [MLBPlayerStandingsDisplay]
}

struct MLBPlayerStandingsDisplay: Equatable {
    let player: MLBPlayerInfo
    let stats: MLBPlayerStats
}
