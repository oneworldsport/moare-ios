//
//  ScheduleContainerState.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

struct ScheduleContainerState {
    let leagueId: Int
    var shouldShowCalendar: Bool = true
    var shouldShowAllResultToggleButton: Bool = true
    var shouldFetchSchedule: Bool = true
    var displayDataState: ApiFetchState = .idle
//    var shouldFillBelow: Bool = true
    var calendarUiState: CalendarUiState? = nil
    var isAllResultOpened: Bool = false
    var shouldShowTournamentButton: Bool = false
    var shouldShowTournamentOrTeamStandingsButton: Bool = true
    
    var startDate: String? = nil
    var endDate: String? = nil
    var relatedLeagues: [String] = []
    var selectedRelatedLeagueIndex: Int = 0
}

struct ScheduleContainerActions {
    var calendarUiActions: CalendarUiActions?
    var allResultButtonAction: () -> Void
    var tournamentOrteamStandingsButtonAction: () -> Void
    var tournamentButtonAction: (() -> Void)? = nil
    var relatedLeagueButtonAction: ((Int) -> Void)? = nil
}
