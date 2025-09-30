//
//  ScheduleGameItemState.swift
//  moare
//
//  Created by Mohwa Yoon on 6/5/25.
//

import SwiftUI

struct ScheduleGameItemState<T: Decodable & Equatable> {
    let leagueId: Int
    let game: GameForSchedule<T>
    let teamNameDic: [String: String]
    var isClickEnabled: Bool = true
    var isResultOpened: Bool = false
    var gameStatusText: String
    var gameStatusColor: Color
    var isCapsuleButtonDisabled: Bool = false
    var gameType: String? = nil
    var referee: String? = nil
    var shouldShowOnlyDateTime: Bool = true
    var shouldShowGameType: Bool = true
    var shouldShowReferee: Bool = false
    var shouldShowHomeLabel: Bool = false
    var shouldShowAwayLabel: Bool = false
}

struct ScheduleGameItemActions {
    var onGameItemClick: () -> Void
    var onCapsuleButtonClick: () -> Void
}
