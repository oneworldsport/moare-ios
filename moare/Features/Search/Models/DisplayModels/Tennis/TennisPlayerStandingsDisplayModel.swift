//
//  TennisPlayerStandingsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

struct TennisPlayerStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
}
