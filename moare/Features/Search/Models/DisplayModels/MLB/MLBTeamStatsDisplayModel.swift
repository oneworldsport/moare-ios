//
//  KBOTeamStatsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBTeamStatsDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let team: MLBTeamInfo
    let venue: MLBNameObj
    let stats: [MLBTeamStats]
}
