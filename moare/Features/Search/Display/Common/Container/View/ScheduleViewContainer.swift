//
//  ScheduleViewContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 5/30/25.
//

import SwiftUI

struct ScheduleViewContainer<TitleContent: View, GameListContent: View>: View {
    let state: ScheduleContainerState
    let actions: ScheduleContainerActions
    @ViewBuilder let titleContent: () -> TitleContent
    @ViewBuilder let gameListContent: () -> GameListContent
    
    @State private var shouldScrollCalendar = true
    
    private var isSameYearMonth: Bool {
        guard let calendarState = state.calendarUiState else {
            return false
        }
        
        let selectedYearMonth = calendarState.yearMonthList[calendarState.selectedYearMonthIndex]
        return CalendarUtil.isSameYearMonth(yearMonth: selectedYearMonth)
    }

    var body: some View {
        VStack(spacing: 0) {
            titleContent()
            
            // calendar
            if let calendarState = state.calendarUiState,
               let calendarActions = actions.calendarUiActions,
               state.shouldShowCalendar {
                
                CalendarList(
                    dateList: calendarState.yearMonthList,
                    calendarType: .yearmonth,
                    selectedIndex: calendarState.selectedYearMonthIndex
                ) { yearMonth, index in
                    shouldScrollCalendar = true
                    calendarActions.onSelectYearMonth(yearMonth, index)
                }
                .padding(.bottom, 6)
                
                CalendarList(
                    dateList: calendarState.days,
                    calendarType: .day,
                    selectedIndex: calendarState.selectedDayIndex,
                    shouldScroll: $shouldScrollCalendar,
                    containsToday: isSameYearMonth
                ) { day, index in
                    shouldScrollCalendar = false
                    calendarActions.onSelectDay(day, index)
                }
                .padding(.bottom, 6)
            }
            
            // all result open button
            if state.shouldShowAllResultToggleButton {
                HStack(spacing: 8) {
                    Spacer()
                    
                    if state.shouldShowTournamentButton {
                        CapsuleButton(
                            text: StringConstants.tournamentButtonText(leagueId: state.leagueId),
                            color: .secondary
                        ) {
                            actions.tournamentButtonAction?()
                        }
                    }
                    
                    CapsuleButton(
                        text: StringConstants.tournamentOrStandingsText(leagueId: state.leagueId),
                        color: .secondary
                    ) {
                        actions.tournamentOrteamStandingsButtonAction()
                    }
                    
                    CapsuleButton(
                        text: state.isAllResultOpened ? StringConstants.resultHide : StringConstants.resultOpen,
                        color: .secondary
                    ) {
                        actions.allResultButtonAction()
                    }
                }
                .padding(.horizontal, 8)
            }
            
            ZStack {
                // loading
                if state.displayDataState == .fetching {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 8)
                }
                
                // game list(schedule)
                if !state.shouldFetchSchedule || state.displayDataState == .success {
                    gameListContent()
                }
                
                // no result / error
                if case .failure(let message) = state.displayDataState {
                    Text(message)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 8)
                }
            }
        }
    }
}
