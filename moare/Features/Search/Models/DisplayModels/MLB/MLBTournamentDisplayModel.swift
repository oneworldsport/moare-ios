//
//  MLBTournamentDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 9/29/25.
//

struct MLBTournamentDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let scheduleType: ScheduleType
    var games: [MLBGameForSchedule]
}
