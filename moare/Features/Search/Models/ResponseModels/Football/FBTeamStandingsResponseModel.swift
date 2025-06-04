//
//  FootballTeamStandingsResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct FBTeamStandingsResponseModel: Decodable, Equatable {
    let standings: [FBTeam]
}
