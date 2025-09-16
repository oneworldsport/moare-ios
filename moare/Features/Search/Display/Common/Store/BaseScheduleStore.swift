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
        var displayModel: T? = nil
        var displayDataState: ApiFetchState = ApiFetchState.idle
        var yearMonthList: [String] = []
        var days: [DayInfo] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var selectedYearMonth = ""
        var selectedDay: DayInfo? = nil
        var selectedYearMonthIndex = 0
        var selectedDayIndex = 0
        var isAllResultOpened = false
        var scrollCalendar = true
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: T)
        case selectDay(DayInfo, Int)
        case setDefaultYearMonth(date: String)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.displayDataState = .idle
                state.yearMonthList = []
                state.days = []
                
                state.selectedYearMonth = ""
                state.selectedDay = nil
                state.selectedYearMonthIndex = 0
                state.selectedDayIndex = 0
                state.isAllResultOpened = false
                state.scrollCalendar = true
                
                // init data
                state.displayModel = displayModel
                
                if let displayModel = displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case let id where Constants.Ids.footballLeagues.contains(id):
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
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
                
            case .selectDay(let day, let index):
                state.selectedDay = day
                state.selectedDayIndex = index
                
                return .none
                
            case .setDefaultYearMonth(let date):
                let defaultYearMonth = CalendarUtil.formatDate(date:date, formatType: .yearMonth)
                if let defaultYearMonthIndex = state.yearMonthList.firstIndex(where: { $0 == defaultYearMonth }) {
                    state.selectedYearMonth = defaultYearMonth
                    state.selectedYearMonthIndex = defaultYearMonthIndex
                } else {
                    print("Index not found.")
                }
        
                return .none
            }
        }
    }
}
