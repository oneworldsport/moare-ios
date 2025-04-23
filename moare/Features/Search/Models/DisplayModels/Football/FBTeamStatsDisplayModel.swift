//
//  FootballTeamGameStatsDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import Foundation

struct FBTeamStatsDisplayModel: Equatable {
    let team: FBTeamInfo
    let venue: FBVenue
    let stats: [FBTeamStats]
    let leagueId: Int?
}
