//
//  FootballGamesScheduleDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/8/24.
//

import Foundation

struct FBLeagueScheduleDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let scheduleType: ScheduleType
    let yearMonthList: [String]
    var games: [FBGameForSchedule]
}
