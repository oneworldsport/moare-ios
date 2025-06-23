//
//  CalendarUiState.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

struct CalendarUiState {
    var yearMonthList: [String]
    var days: [DayInfo]
    var selectedYearMonthIndex: Int
    var selectedDayIndex: Int
//    var yearMonthCalendarScrollTrigger: String
//    var dayCalendarScrollTrigger: String
}

struct CalendarUiActions {
    var onSelectYearMonth: (String, Int) -> Void
    var onSelectDay: (DayInfo, Int) -> Void
}
