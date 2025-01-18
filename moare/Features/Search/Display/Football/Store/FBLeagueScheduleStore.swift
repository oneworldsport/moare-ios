//
//  FBGameScheduleStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBLeagueScheduleStore {
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 100
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBLeagueScheduleDisplayModel? // optional for usage in FBGameStatsView
        let yearMonthList: [String]
        var days: [DayInfo] = []
        var filteredGames: [Int: [FBGame]] = [:]
        
        /* ---------------------
           ui state
           --------------------- */
        var selectedYearMonth = ""
        var selectedDay: DayInfo? = nil
        var selectedYearMonthIndex = 0
        var selectedDayIndex = 0
        var isAllResultOpened = false
        var scrollCalendar = true
    }
    
    enum Action {
        case initData
        case selectYearMonth(String, Int)
        case selectDay(DayInfo, Int)
        case toggleAllResult
        
        /* ---------------------
           private
           --------------------- */
        case setDays
        case fetchGames
        case setDisplayModel(FBLeagueScheduleDisplayModel)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                let displayModel = state.displayModel
                
                // set first yearMonth as selected
                state.selectedYearMonth = state.yearMonthList.first ?? ""
                
                return .run { send in
                    await send(.setDays)
                }
                
            case .selectYearMonth(let yearMonth, let index):
                state.selectedYearMonth = yearMonth
                state.selectedYearMonthIndex = index
                
                return .run { send in
                    await send(.fetchGames)
                }
                
            case .selectDay(let day, let index):
                state.selectedDay = day
                state.selectedDayIndex = index

                return .none
                
            case .toggleAllResult:
                state.isAllResultOpened.toggle()
                
                return .none
                
            case .setDays:
                // set days
                if let month = Int(state.selectedYearMonth.split(separator: "/").last ?? "") {
                    var days = CalendarUtil.getDaysInMonth(year: 2024, month: month)
                    
                    days = days.enumerated().compactMap { index, day in
                        var newDay = day
                        
                        let games = state.displayModel?.games.filter { game in
                            CalendarUtil.isSameDate(stringDate: game.fixture.date, selectedYearMonth: state.selectedYearMonth, selectedDay: day.day)
                        }
                        
                        state.filteredGames[index] = games
                        
                        if games?.isEmpty == true {
                            newDay.isDataEmpty = true
                        }
                        
                        return newDay
                    }
                    
                    state.days = days
                }
                
                // set first day that has games as selected
                for (index, day) in state.days.enumerated() {
                    if !day.isDataEmpty {
                        state.selectedDay = day
                        state.selectedDayIndex = index
                        break
                    }
                }
                
                return .none
                
            case .fetchGames:
                return .run { [selectedYearMonth = state.selectedYearMonth] send in
                    do {
                        let selectedYearMonth = selectedYearMonth.split(separator: "/")
                        let yearMonth = selectedYearMonth[0] + selectedYearMonth[1]
                        
                        // TODO: temporary leagueId
                        let result = try await searchClient.fetchLeagueSchedule(leagueId: "39", yearMonth: String(yearMonth))
                        
                        if case .fbLeagueSchedule(_, let displayModel) = result.data {
                            await send(.setDisplayModel(displayModel))
                        }
                    } catch {
                        print("\(error)")
                    }
                }
                
            case .setDisplayModel(let displayModel):
                state.displayModel = displayModel
                
                return .send(.setDays)
            }
        }
    }
}
