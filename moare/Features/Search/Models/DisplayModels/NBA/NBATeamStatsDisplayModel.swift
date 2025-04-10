//
//  FootballTeamGameStatsDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import Foundation

struct NBATeamStatsDisplayModel: Equatable {
    let team: NBATeamInfo
    let venue: NBAVenue
    let stats: [NBATeamStats]
}
