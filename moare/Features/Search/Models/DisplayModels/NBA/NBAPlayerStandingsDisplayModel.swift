//
//  FootballPlayerStandingsDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct NBAPlayerStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let standings: [NBAPlayerStandingsDisplay]
}

struct NBAPlayerStandingsDisplay: Equatable {
    let player: NBAPlayerInfo
    let stats: NBAPlayerStats
}
