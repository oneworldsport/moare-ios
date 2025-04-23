//
//  FootballTeamInfoDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct FBTeamInfoDisplayModel: Equatable {
    let team: FBTeamInfo
    let venue: FBVenue
    let stats: FBTeamStats?
    let lastGame: FBGame?
    let nextGame: FBGame?
    let leagueId: Int?
}
