//
//  FootballPlayerInfoDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct FBPlayerInfoDisplayModel: Equatable {
    let info: FBPlayerInfo
    let stats: FBPlayerStats?
    let lastGame: FBGame?
    let lastGamePlayerStats: FBGamePlayerStatsDetail?
    let nextGame: FBGame?
}
