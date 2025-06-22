//
//  KBOTeamStandingsResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBTeamStandingsResponseModel: Decodable, Equatable {
    let standings: [MLBTeam]
}
