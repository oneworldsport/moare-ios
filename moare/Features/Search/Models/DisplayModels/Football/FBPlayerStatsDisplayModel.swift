//
//  FootballPlayerGameStatsDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import Foundation

struct FBPlayerStatsDisplayModel: Equatable {
    let player: FBPlayerInfo
    let team: FBTeamInfo?
    let stats: [FBPlayerStats]
}
