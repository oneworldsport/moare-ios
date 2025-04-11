//
//  FootballPlayerInfoDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct NBAPlayerInfoDisplayModel: Equatable {
    let info: NBAPlayerInfo
    let stats: NBAPlayerStats?
    let lastGame: NBAGame?
    let lastGamePlayerStats: NBABoxScoreTeamPlayer?
    let nextGame: NBAGame?
}
