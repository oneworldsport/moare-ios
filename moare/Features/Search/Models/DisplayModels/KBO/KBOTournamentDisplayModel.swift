//
//  KBOTournamentDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 9/17/25.
//

struct KBOTournamentDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let scheduleType: ScheduleType
    var games: [KBOGameForSchedule]
}
