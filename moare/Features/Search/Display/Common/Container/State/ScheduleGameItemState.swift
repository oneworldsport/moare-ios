//
//  ScheduleGameItemState.swift
//  moare
//
//  Created by Mohwa Yoon on 6/5/25.
//

import SwiftUI

struct ScheduleGameItemState {
    let leagueId: Int
    var isClickEnabled: Bool = true
    var homeTeamLogo: String?
    var homeTeamName: String
    var homeTeamScore: Int
    var awayTeamLogo: String?
    var awayTeamName: String
    var awayTeamScore: Int
    var isResultOpened: Bool = false
    var gameStatusText: String
    var gameStatusColor: Color
    var isCapsuleButtonDisabled: Bool = false
    var date: String
    var gameType: String? = nil
    var referee: String? = nil
    var shouldShowOnlyDateTime: Bool = true
    var shouldShowGameType: Bool = true
    var shouldShowReferee: Bool = false
    var shouldShowHomeLabel: Bool = false
    var shouldShowAwayLabel: Bool = false
    var isSvgLogo: Bool = false
    // TODO: GameForSchedule 모델로 바꿔야함
}

struct ScheduleGameItemActions {
    var onGameItemClick: () -> Void
    var onCapsuleButtonClick: () -> Void
}
