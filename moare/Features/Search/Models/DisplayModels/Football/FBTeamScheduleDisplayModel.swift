//
//  FBTeamScheduleDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/15/25.
//

import Foundation

struct FBTeamScheduleDisplayModel: Equatable {
    let games: [FBGame]
    let leagueId: Int?
}
