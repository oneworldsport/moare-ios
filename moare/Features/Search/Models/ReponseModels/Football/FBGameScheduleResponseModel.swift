//
//  FootballGameStatsResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/9/24.
//

import Foundation

struct FBGameScheduleResponseModel: Decodable, Equatable {
    var scheduledMonths: [String] = []
    var schedule: [FBGame] = []
    
    private enum CodingKeys: String, CodingKey {
        case scheduledMonths = "scheduled_months"
        case schedule
    }
}
