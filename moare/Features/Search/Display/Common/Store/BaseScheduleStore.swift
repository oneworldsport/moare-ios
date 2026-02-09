//
//  BaseScheduleStore.swift
//  moare
//
//  Created by Mohwa Yoon on 5/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BaseScheduleStore<T> {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: T
        var displayDataState: ApiFetchState = ApiFetchState.idle
        var yearMonthList: [String] = []
        var days: [DayInfo] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var selectedYearMonth = ""
        var selectedMonth = 0
        var selectedDay: DayInfo? = nil
        var selectedYearMonthIndex = 0
        var selectedDayIndex = 0
        var isAllResultOpened = false
        var scrollCalendar = true
        
        var selectedRelatedLeagueIndex = 0
        
        var teamNameDictionary: [String: String] = [:]
        
        init(displayModel: T) {
            self.displayModel = displayModel
        }
    }
    
    enum Action {
        case initData
        case selectDay(DayInfo, Int)
        case selectYearMonth(yearMonth: String, selectedIndex: Int, isInit: Bool = false)
        case setDefaultYearMonth(date: String)
        case selectRelatedLeague(index: Int)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                // init with default value
                state.displayDataState = .idle
                state.yearMonthList = []
                state.days = []
                
                state.selectedYearMonth = ""
                state.selectedMonth = 0
                state.selectedDay = nil
                state.selectedYearMonthIndex = 0
                state.selectedDayIndex = 0
                state.isAllResultOpened = false
                state.scrollCalendar = true
                
                state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                
                if let displayModel = state.displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case Constants.Ids.nba:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.nbaTeamDic)
                    case Constants.Ids.kbo:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.kboTeamDic)
                    case Constants.Ids.mlb:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlbTeamDic)
                    default: break
                    }
                }
                
                return .none
                
            case let .selectDay(day, index):
                state.selectedDay = day
                state.selectedDayIndex = index
                
                return .none
                
            case let .selectYearMonth(yearMonth, selectedIndex, _):
                state.selectedYearMonth = yearMonth
                state.selectedYearMonthIndex = selectedIndex
                
                let monthStr = yearMonth.components(separatedBy: "/").last
                state.selectedMonth = Int(monthStr ?? "0") ?? 0
                
                return .none
                
            case .setDefaultYearMonth(let date):
                let defaultYearMonth = CalendarUtil.formatDate(date:date, outputFormatType: .yearMonth)
                if let defaultYearMonthIndex = state.yearMonthList.firstIndex(where: { $0 == defaultYearMonth }) {
                    return .send(.selectYearMonth(yearMonth: defaultYearMonth, selectedIndex: defaultYearMonthIndex, isInit: true))
                } else {
                    print("Index not found.")
                }
        
                return .none
                
            case .selectRelatedLeague(let index):
                state.selectedRelatedLeagueIndex = index
                
                return .none
            }
        }
    }
}
