//
//  FootballGamesScheduleDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/8/24.
//

import Foundation

struct FBLeagueScheduleDisplayModel: Equatable {
    let yearMonthList: [String]
    let games: [FBGame]
}

struct FBLeagueScheduleCalendarDisplay: Equatable {
    let month: String
    let days: [String]
}
