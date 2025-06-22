//
//  KBOTeamStatsDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOTeamStatsDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let team: KBOTeamInfo
    let venue: KBOTeamVenue
    let stats: [KBOTeamStats]
}
