//
//  TennisGameScheduleResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

struct TennisGameScheduleResponseModel: Decodable, Equatable {
    let scheduleType: ScheduleType?
    let scheduledMonths: [String]?
    let startDate: String?
    let endDate: String?
    let relatedLeagueIds: [Int]?
    let schedule: [TennisGameForSchedule]
}
