//
//  ScheduleContainerState.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

struct ScheduleContainerState {
    var shouldShowCalendar: Bool = true
    var shouldShowAllResultToggleButton: Bool = true
    var shouldFetchSchedule: Bool = true
    var displayDataState: ApiFetchState = .idle
//    var shouldFillBelow: Bool = true
    var calendarUiState: CalendarUiState? = nil
    var isAllResultOpened: Bool = false
}

struct ScheduleContainerActions {
    var calendarUiActions: CalendarUiActions?
    var allResultButtonAction: () -> Void
}
