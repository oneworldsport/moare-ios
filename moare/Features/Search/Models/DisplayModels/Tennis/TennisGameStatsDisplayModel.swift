//
//  TennisGameStatsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

struct TennisGameStatsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let game: TennisGame
    var leagueKrName: String = ""
    var roundName: String = ""
}
