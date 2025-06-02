//
//  NBAGameListDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 5/31/25.
//

struct NBATournamentDisplayModel: Equatable {
    let yearMonthList: [String]
    var games: [NBAGame]
    let entityInfo: [EntityInfo]
}
