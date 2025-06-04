//
//  KBOTeamStandingsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBTeamStandingsDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let standings: [MLBTeamStandingsDisplay]
}

struct MLBTeamStandingsDisplay: Equatable {
    let team: MLBTeamInfo
    let stats: MLBTeamStats
}
