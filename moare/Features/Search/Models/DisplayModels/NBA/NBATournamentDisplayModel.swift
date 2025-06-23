//
//  NBAGameListDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 5/31/25.
//

struct NBATournamentDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let yearMonthList: [String]
    var games: [NBAGame]
}
