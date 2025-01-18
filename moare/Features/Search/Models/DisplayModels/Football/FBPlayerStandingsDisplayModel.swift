//
//  FootballPlayerStandingsDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct FBPlayerStandingsDisplayModel {
    let keywords: [Keyword]
    let standings: [FBPlayerStandingsDisplay]
}

struct FBPlayerStandingsDisplay {
    let player: FBPlayerInfo
    let stats: FBPlayerStats
}
