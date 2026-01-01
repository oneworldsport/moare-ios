//
//  FootballDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct NBATeamStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let standings: [NBATeamStandingsDisplay]
}

struct NBATeamStandingsDisplay: Equatable, Rankable {
    let team: NBATeamInfo
    let stats: NBATeamStats
    var displayRank = 0 // 화면에서 순위 표시에 쓰이는 값
}
