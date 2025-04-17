//
//  NbaModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/11/24.
//

import Foundation

struct NBATeamInfoResponseModel: Decodable, Equatable {
    let info: NBATeam?
    let lastGame: NBAGame?
    let nextGame: NBAGame?
}
