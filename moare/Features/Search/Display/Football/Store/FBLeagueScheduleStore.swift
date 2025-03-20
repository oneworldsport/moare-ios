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
        var displayModel: FBLeagueScheduleDisplayModel? = nil
        var displayDataState: ApiFetchState = ApiFetchState.idle
        var yearMonthList: [String] = []
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
        var gameResultOpenedStateList: [Int: Bool] = [:]
        
        var dataForViewStack: SportDecodableModel? = nil
    }
    
    enum Action {
        case initData(displayModel: FBLeagueScheduleDisplayModel)
        case selectYearMonth(yearMonth: String, selectedIndex: Int)
        case selectDay(DayInfo, Int)
        case toggleAllResult
        case updateResultOpenedState(fixtureId: Int, isOpened: Bool)
        case updateGamesData(
            fbLeagueScheduleData: SportDecodableModel,
            fbGameStatsData: SportDecodableModel
        )
        
        /* ---------------------
           private
           --------------------- */
        case setDays(isInit: Bool = false)
        case fetchGames
        case setDisplayModel(FBLeagueScheduleDisplayModel)
        case updateViewStack(data: SportDecodableModel)
        case resetDataForViewStack
        case updateDisplayDataState(fetchState: ApiFetchState)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.displayModel = nil
                state.displayDataState = .idle
                state.yearMonthList = []
                state.days = []
                state.filteredGames = [:]
                state.selectedYearMonth = ""
                state.selectedDay = nil
                state.selectedYearMonthIndex = 0
                state.selectedDayIndex = 0
                state.isAllResultOpened = false
                state.scrollCalendar = true
                state.gameResultOpenedStateList = [:]
                state.dataForViewStack = nil
                
                // init data
                state.displayModel = displayModel
                state.yearMonthList = displayModel.yearMonthList
                
                // select default yearMonth
                if let date = displayModel.games.first?.fixture.date {
                    let defaultYearMonth = CalendarUtil.formatDate(date: date, formatType: .yearMonth)
                    let defaultYearMonthIndex = state.yearMonthList.enumerated().first { $0.element == defaultYearMonth }
                    
                    state.selectedYearMonth = defaultYearMonth
                    
                    if let index = defaultYearMonthIndex {
                        state.selectedYearMonthIndex = index.offset
                    }
                }
                
                return .run { send in
                    await send(.setDays(isInit: true))
                }
                
            case .selectYearMonth(let yearMonth, let selectedIndex):
                state.selectedYearMonth = yearMonth
                state.selectedYearMonthIndex = selectedIndex
                
                return .run { send in
                    await send(.fetchGames)
                }
                
            case .selectDay(let day, let index):
                state.selectedDay = day
                state.selectedDayIndex = index

                return .none
                
            case .toggleAllResult:
                let newState = !state.isAllResultOpened
                state.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                
                return .none
                
            case .updateResultOpenedState(let fixtureId, let isOpened):
                state.gameResultOpenedStateList[fixtureId] = isOpened
                
                return .none
                
            case .setDays(let isInit):
                // set filtered games to each day
                let components = state.selectedYearMonth.split(separator: "/")
                
                if components.count == 2,
                   let year = Int(components[0]),
                   let month = Int(components[1]) {
                    var days = CalendarUtil.getDaysInMonth(year: Int("20\(year)") ?? 2025, month: month)
                    var gameResultOpenedStateList: [Int: Bool] = [:]
                    var newFilteredGame = state.filteredGames
                    
                    days = days.enumerated().compactMap { index, day in
                        var newDay = day
                        
                        let games = state.displayModel?.games.filter { game in
                            CalendarUtil.isSameDate(stringDate: game.fixture.date, selectedYearMonth: state.selectedYearMonth, selectedDay: day.day)
                        }
                        
                        gameResultOpenedStateList.merge((games ?? []).reduce(into: [:]) { $0[$1.fixture.id] = state.isAllResultOpened }) { _, new in new }
                        
                        newFilteredGame[index] = games
                        
                        if games?.isEmpty == true {
                            newDay.isDataEmpty = true
                        }
                        
                        return newDay
                    }
                    
                    // ui operation order
                    // 1. Set default 'isOpened' value as false to every games, before 'filteredGames' show.
                    state.gameResultOpenedStateList = gameResultOpenedStateList
                    
                    // 2. Set days to days calendar.
                    state.days = days
                    
                    // 3. Move bar and scroll the days calendar.
                    if isInit {
                        // select default day
                        let defaultDay = CalendarUtil.getDefaultDay(yearMonth: state.selectedYearMonth, dayList: state.days)
                        
                        if let defaultDay = defaultDay {
                            state.selectedDay = defaultDay.1
                            state.selectedDayIndex = defaultDay.0
                        }
                    } else {
                        // select first day that has games
                        for (index, day) in state.days.enumerated() {
                            if !day.isDataEmpty {
                                state.selectedDay = day
                                state.selectedDayIndex = index
                                break
                            }
                        }
                    }
                    
                    // 4. Remove loading.
//                    state.displayDataState = .success
                    
                    // 5. Show 'filteredGames'
                    state.filteredGames = newFilteredGame
                    
                    return .run { send in
                        await send(.updateDisplayDataState(fetchState: .success))
                    }
                }
                
                // added to prevent any gaps
                // executed before .run{}
//                if state.displayDataState != .success {
//                    state.displayDataState = .success
//                }
                
                return .none
                
            case .fetchGames:
                return .run { [selectedYearMonth = state.selectedYearMonth, displayModel = state.displayModel] send in
                    await send(.updateDisplayDataState(fetchState: .fetching))
                    
                    do {
                        let selectedYearMonth = selectedYearMonth.split(separator: "/")
                        let yearMonth = selectedYearMonth[0] + selectedYearMonth[1]
                        
                        let leagueId = displayModel?.games.first?.league.id ?? 39
                        
                        let result = try await searchClient.fetchLeagueSchedule(leagueId: leagueId, yearMonth: String(yearMonth))
                        
                        if case .fbLeagueSchedule(_, let displayModel) = result.data {
                            await send(.setDisplayModel(displayModel))
                            await send(.updateViewStack(data: result.data))
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")))
                        print("\(error)")
                    }
                }
                
            case .setDisplayModel(let displayModel):
                state.displayModel = displayModel
                
                return .send(.setDays())
                
            case .updateGamesData(let fbLeagueScheduleData, let fbGameStatsData):
                guard case .fbLeagueSchedule(let leagueScheduleResponseModel, let leagueScheduleDisplayModel) = fbLeagueScheduleData,
                        case .fbGameStats(_, let gameStatsDisplayModel) = fbGameStatsData else {
                    return .none
                }
                
                let newGames = leagueScheduleDisplayModel.games.map {
                    $0.fixture.id == gameStatsDisplayModel.game.fixture.id ? gameStatsDisplayModel.game : $0
                }
                
                var newDisplayModel = leagueScheduleDisplayModel
                newDisplayModel.games = newGames
                state.displayModel = newDisplayModel
                
                var newFilteredGames = state.filteredGames
                newFilteredGames[state.selectedDayIndex] = newDisplayModel.games.filter {
                    CalendarUtil.isSameDate(stringDate: $0.fixture.date, selectedYearMonth: state.selectedYearMonth, selectedDay: state.selectedDayIndex + 1)
                }
                
                state.filteredGames = newFilteredGames
                
                return .send(.updateViewStack(data: SportDecodableModel.fbLeagueSchedule(leagueScheduleResponseModel, newDisplayModel)))
                
            case .updateViewStack(let data):
                state.dataForViewStack = data
                
                return .run { send in
                    await send(.resetDataForViewStack)
                }
                
            case .resetDataForViewStack:
                // Set nil for next update. Because the data is same as SportDecodableModel, .onChange() is not triggered.
                // Has to figure out better structrue.
                state.dataForViewStack = nil
                
                return .none
                
            case .updateDisplayDataState(let fetchState):
                withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                    state.displayDataState = fetchState
                }
                
                return .none
            }
        }
    }
}
