//
//  FootballGamesScheduleDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/8/24.
//

import Foundation

struct FBLeagueScheduleDisplayModel: DisplayModelBase {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let yearMonthList: [String]
    var games: [FBGameForSchedule]
}
