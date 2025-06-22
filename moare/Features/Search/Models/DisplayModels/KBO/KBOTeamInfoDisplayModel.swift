//
//  KBOTeamInfoDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOTeamInfoDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let team: KBOTeamInfo
    let venue: KBOTeamVenue
    let stats: KBOTeamStats?
    let lastGame: KBOGame?
    let nextGame: KBOGame?
}
