//
//  GameStatsContainerState.swift
//  moare
//
//  Created by Mohwa Yoon on 8/20/25.
//

import Foundation

struct GameStatsContainerState {
    var shouldShowTitle: Bool = true
    var shouldShowGameContent: Bool = true
    var shouldShowStats: Bool = true
    var shouldShowCoach: Bool = false
    var shouldShowRefreshButton: Bool = false
    let teamCategories: [GameStatsTeamState]
    var firstCategories: [String]? = nil
    var coachState: GameStatsCoachState? = nil
    var teamCategorySelectedIndex: Int = 0
    var firstCategorySelectedIndex: Int = 0
    var firstColumnWidth: CGFloat? = nil
    var gameDetailTitle: String = ""
    var gameDetailContent: String = ""
    var noStatsText: String? = nil
    
    var firstStatsTitle: String? = nil
    let firstStatsCategories: [String]
    var firstStatsCategorySelectedIndex: Int = 0
    var firstStatsColumnWidthList: [CGFloat] = []
    let firstStatsPlayerList: [StandingsItemState]
    
    var secondStatsTitle: String? = nil
    var secondStatsCategories: [String]? = nil
    var secondStatsCategorySelectedIndex: Int = 0
    var secondStatsColumnWidthList: [CGFloat] = []
    var secondStatsPlayerList: [StandingsItemState]? = nil
}

struct GameStatsTeamState {
    let name: String
    let imageUrl: String?
}

struct GameStatsCoachState {
    let name: String?
    var imageUrl: String? = nil
}

struct GameStatsContainerActions {
    var teamCategoryButtonAction: ((Int) -> Void)? = nil
    let firstStatsCategoryButtonAction: (Int) -> Void
    var secondStatsCategoryButtonAction: ((Int) -> Void)? = nil
    let refreshButtonAction: () -> Void
}
