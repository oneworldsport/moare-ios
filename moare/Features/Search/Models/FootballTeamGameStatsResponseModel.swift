//
//  FootballTeamGameStatsResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import Foundation

struct FootballTeamGameStatsResponseModel: Codable, Equatable {
//    let team: Team
//    let statistics: [Statistic]
}

struct Statistic: Codable, Equatable {
    let type: String?
    let value: String?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        
        if let intValue = try? container.decode(Int.self, forKey: .value) {
            value = String(intValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = stringValue
        } else {
            value = nil
        }
    }
}
