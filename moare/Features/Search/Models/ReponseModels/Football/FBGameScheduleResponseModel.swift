//
//  FootballGameStatsResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/9/24.
//

import Foundation

struct FBGameScheduleResponseModel: Decodable, Equatable {
    var scheduledMonths: [String]? = nil
    var schedule: [FBGame] = []
}
