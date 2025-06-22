//
//  KBOTeamStandingsResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOTeamStandingsResponseModel: Decodable, Equatable {
    let standings: [KBOTeam]
}
