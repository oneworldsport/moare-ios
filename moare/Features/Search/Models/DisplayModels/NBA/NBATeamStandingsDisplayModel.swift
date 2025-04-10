//
//  FootballDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct NBATeamStandingsDisplayModel: Equatable {
    let keywords: [Keyword]
    let standings: [NBATeamStandingsDisplay]
}

struct NBATeamStandingsDisplay: Equatable {
    let team: NBATeamInfo
    let stats: NBATeamStats?
}
