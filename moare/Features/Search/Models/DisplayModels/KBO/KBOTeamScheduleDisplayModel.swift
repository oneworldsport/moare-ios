//
//  KBOTeamScheduleDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/22/25.
//

struct KBOTeamScheduleDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let games: [KBOGameForSchedule]
}
