//
//  FootballPlayerStandingsResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct FBPlayerStandingsResponseModel: Decodable, Equatable {
    let standings: [FBPlayer]
}
