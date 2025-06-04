//
//  FootballTeamInfoResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct FBTeamInfoResponseModel: Decodable, Equatable {
    let info: FBTeam?
    let lastGame: FBGame?
    let nextGame: FBGame?
}
