//
//  NbaModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/11/24.
//

import Foundation

struct NBAGameScheduleResponseModel: Decodable, Equatable {
    let scheduleType: ScheduleType?
    let scheduledMonths: [String]?
    let schedule: [NBAGameForSchedule]
}
