//
//  FootballPlayerStandingsDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct FBPlayerStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let standings: [FBPlayerStandingsDisplay]
}

struct FBPlayerStandingsDisplay: Equatable {
    let player: FBPlayerInfo
    let stats: FBPlayerStats
}
