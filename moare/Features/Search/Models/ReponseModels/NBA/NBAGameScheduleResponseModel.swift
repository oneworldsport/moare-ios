//
//  NbaModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/11/24.
//

import Foundation

struct NBAGameScheduleResponseModel: Decodable, Equatable {
    var scheduledMonths: [String]? = nil
    var schedule: [NBAGame] = []
}
