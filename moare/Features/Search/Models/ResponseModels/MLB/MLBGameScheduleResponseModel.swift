//
//  KBOGameScheduleResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBGameScheduleResponseModel: Decodable, Equatable {
    let scheduledMonths: [String]?
    let schedule: [MLBGame]
}
