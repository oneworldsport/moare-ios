//
//  FootballDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct FBTeamStandingsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let league: FBLeague?
    let standings: [FBTeamStandingsDisplay]
}

// 이름 고민 필요
struct FBTeamStandingsDisplay: Equatable, Rankable {
    let team: FBTeamInfo
    let homeAwayStats: FBTeamStatsFixtures
    let goalsFor: FBHomeAwayIntStats
    let goalsAgainst: FBHomeAwayIntStats
    let rank: Int
    let points: Int
    var displayRank = 0 // 화면에서 순위 표시에 쓰이는 값
}
