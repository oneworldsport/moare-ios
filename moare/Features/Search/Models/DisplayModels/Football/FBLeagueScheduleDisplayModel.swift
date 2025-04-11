//
//  FootballGamesScheduleDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/8/24.
//

import Foundation

struct FBLeagueScheduleDisplayModel: Equatable {
    let yearMonthList: [String]
    var games: [FBGame]
    let entityInfo: [EntityInfo]
}

struct FBLeagueScheduleCalendarDisplay: Equatable {
    let month: String
    let days: [String]
}
