//
//  MLBTeamScheduleDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/22/25.
//

struct MLBTeamScheduleDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let games: [MLBGameForSchedule]
}
