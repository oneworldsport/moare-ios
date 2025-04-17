//
//  FootballGamesScheduleDisplayModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/8/24.
//

import Foundation

struct NBALeagueScheduleDisplayModel: Equatable {
    let yearMonthList: [String]
    var games: [NBAGame]
    let entityInfo: [EntityInfo]
}
