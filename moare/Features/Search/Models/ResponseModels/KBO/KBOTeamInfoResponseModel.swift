//
//  KBOTeamInfoResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOTeamInfoResponseModel: Decodable, Equatable {
    let info: KBOTeam?
    let lastGame: KBOGame?
    let nextGame: KBOGame?
}
