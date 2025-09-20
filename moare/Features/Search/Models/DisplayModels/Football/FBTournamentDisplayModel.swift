//
//  FBTournamentDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 9/15/25.
//

struct FBTournamentDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let scheduleType: ScheduleType
    var games: [FBGameForSchedule]
}
