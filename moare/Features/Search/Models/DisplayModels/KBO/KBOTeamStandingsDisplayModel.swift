//
//  KBOTeamStandingsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOTeamStandingsDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let standings: [KBOTeamStandingsDisplay]
}

struct KBOTeamStandingsDisplay: Equatable {
    let team: KBOTeamInfo
    let stats: KBOTeamStats
}
