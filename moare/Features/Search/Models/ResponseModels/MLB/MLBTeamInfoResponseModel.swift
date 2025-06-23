//
//  KBOTeamInfoResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBTeamInfoResponseModel: Decodable, Equatable {
    let info: MLBTeam?
    let lastGame: MLBGame?
    let nextGame: MLBGame?
}
