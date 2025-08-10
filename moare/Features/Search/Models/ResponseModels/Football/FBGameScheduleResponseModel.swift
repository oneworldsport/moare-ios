//
//  FootballGameStatsResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/9/24.
//

import Foundation

struct FBGameScheduleResponseModel: Decodable, Equatable {
    let scheduleType: ScheduleType?
    let scheduledMonths: [String]?
    let schedule: [FBGameForSchedule]
}

enum ScheduleType: String, Decodable, Equatable {
    case team = "team"
    case league = "league"
    case teamFlat = "team_flat"
}
