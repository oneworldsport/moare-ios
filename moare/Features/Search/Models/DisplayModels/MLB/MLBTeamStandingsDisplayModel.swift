//
//  KBOTeamStandingsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBTeamStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let standings: [MLBTeamStandingsDisplay]
}

struct MLBTeamStandingsDisplay: Equatable, Rankable {
    let team: MLBTeamInfo
    let stats: MLBTeamStats
    var displayRank = 0 // 화면에서 순위 표시에 쓰이는 값
}
