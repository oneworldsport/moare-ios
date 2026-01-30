//
//  TennisTournamentDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

struct TennisTournamentDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let scheduleType: ScheduleType
    var games: [TennisGameForSchedule]
}
