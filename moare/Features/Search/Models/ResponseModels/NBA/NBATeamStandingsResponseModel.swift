//
//  NbaModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/11/24.
//

import Foundation

struct NBATeamStandingsResponseModel: Decodable, Equatable {
    let standings: [NBATeam]
}
