//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBALeagueScheduleStore {
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: NBALeagueScheduleDisplayModel? = nil
        var displayDataState: ApiFetchState = ApiFetchState.idle
        var yearMonthList: [String] = []
        var days: [DayInfo] = []
        var filteredGames: [Int: [NBAGame]] = [:]
        
        /* ---------------------
           ui state
           --------------------- */
        var selectedYearMonth = ""
        var selectedDay: DayInfo? = nil
        var selectedYearMonthIndex = 0
        var selectedDayIndex = 0
        var isAllResultOpened = false
        var scrollCalendar = true
        var gameResultOpenedStateList: [String: Bool] = [:]
        
        /* ---------------------
           etc
           --------------------- */
        var dataForViewStack: SportDecodableModel? = nil
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: NBALeagueScheduleDisplayModel)
        
        /* ---------------------
           view action
           --------------------- */
        case selectYearMonth(yearMonth: String, selectedIndex: Int)
        case selectDay(day: DayInfo, selectedIndex: Int)
        case toggleAllResult
        case updateResultOpenedState(gameCode: String, isOpened: Bool)
        case updateGamesData(
            nbaLeagueScheduleData: SportDecodableModel,
            nbaGameStatsData: SportDecodableModel
        )
        
        /* ---------------------
           private
           --------------------- */
        case setDays(isInit: Bool = false)
        case fetchGames
        
        case updateViewStack(data: SportDecodableModel)
        case resetDataForViewStack
        
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(displayModel: NBALeagueScheduleDisplayModel)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.displayDataState = .idle
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
                if let date = displayModel.games.first?.gameSummary?.date {
                    let defaultYearMonth = CalendarUtil.formatDate(date: date, formatType: .yearMonth)
                    let defaultYearMonthIndex = state.yearMonthList.enumerated().first { $0.element == defaultYearMonth }
                    
                    state.selectedYearMonth = defaultYearMonth
                    
                    if let defaultYearMonthIndex {
                        state.selectedYearMonthIndex = defaultYearMonthIndex.offset
                    }
                }
                
                return .send(.setDays(isInit: true))
                
            case .selectYearMonth(let yearMonth, let selectedIndex):
                state.selectedYearMonth = yearMonth
                state.selectedYearMonthIndex = selectedIndex
                
                return .send(.fetchGames)
                
            case .selectDay(let day, let index):
                state.selectedDay = day
                state.selectedDayIndex = index

                return .none
                
            case .toggleAllResult:
                let newState = !state.isAllResultOpened
                state.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                
                return .none
                
            case .updateResultOpenedState(let gameCode, let isOpened):
                state.gameResultOpenedStateList[gameCode] = isOpened
                
                return .none
                
            case .setDays(let isInit):
                // set filtered games to each day
                let components = state.selectedYearMonth.split(separator: "/")
                
                if components.count == 2,
                   let year = Int(components[0]),
                   let month = Int(components[1]) {
                    var days = CalendarUtil.getDaysInMonth(year: Int("20\(year)") ?? 2025, month: month)
                    
                    var gameResultOpenedStateList: [String: Bool] = [:]
                    var newFilteredGame = state.filteredGames
                    
                    days = days.enumerated().compactMap { index, day in
                        var newDay = day
                        
                        let games = state.displayModel?.games.filter { game in
                            if let gameSummary = game.gameSummary {
                                CalendarUtil.isSameDate(stringDate: gameSummary.date, selectedYearMonth: state.selectedYearMonth, selectedDay: day.day)
                            } else {
                                false
                            }
                        }
                        
                        gameResultOpenedStateList.merge((games ?? []).reduce(into: [:]) { $0[$1.gameSummary?.gameCode ?? ""] = state.isAllResultOpened }) { _, new in new }
                        
                        // NOTE: games는 optional인데 왜 컴파일 에러가 안나지..?
                        newFilteredGame[index] = games ?? []
                        
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
                    
                    return .send(.updateDisplayDataState(fetchState: .success), animation: AnimationConstants.AnimationType.defaultAnimation)
                }
                
                return .none
                
            case .fetchGames:
                return .run { [selectedYearMonth = state.selectedYearMonth, displayModel = state.displayModel] send in
                    await send(.updateDisplayDataState(fetchState: .fetching), animation: AnimationConstants.AnimationType.defaultAnimation)
                    
                    do {
                        let selectedYearMonth = selectedYearMonth.split(separator: "/")
                        let yearMonth = selectedYearMonth[0] + selectedYearMonth[1]
                        
                        let entity = displayModel?.entityInfo.first ?? EntityInfo(
                            entityId: 90001,
                            entityName: "NBA",
                            category: "basketball",
                            entityType: "league",
                            leagueId: 90001
                        )
                        
                        let result = try await searchClient.fetchLeagueSchedule(entity: entity, yearMonth: String(yearMonth))
                        
                        if case let .nbaLeagueSchedule(_, displayModel) = result.data {
                            await send(.setDisplayModel(displayModel: displayModel))
                            await send(.updateViewStack(data: result.data))
                            await send(.setDays())
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case .updateGamesData(let nbaLeagueScheduleData, let nbaGameStatsData):
                guard case let .nbaLeagueSchedule(leagueScheduleResponseModel, leagueScheduleDisplayModel) = nbaLeagueScheduleData,
                        case let .nbaGameStats(_, gameStatsDisplayModel) = nbaGameStatsData else {
                    return .none
                }
                
                let newGames = leagueScheduleDisplayModel.games.map {
                    $0.gameSummary?.gameCode == gameStatsDisplayModel.game.gameSummary?.gameCode ? gameStatsDisplayModel.game : $0
                }
                
                var newDisplayModel = leagueScheduleDisplayModel
                newDisplayModel.games = newGames
                state.displayModel = newDisplayModel
                
                var newFilteredGames = state.filteredGames
                newFilteredGames[state.selectedDayIndex] = newDisplayModel.games.filter { game in
                    if let gameSummary = game.gameSummary {
                        CalendarUtil.isSameDate(stringDate: gameSummary.date, selectedYearMonth: state.selectedYearMonth, selectedDay: state.selectedDayIndex + 1)
                    } else {
                        false
                    }
                }
                
                state.filteredGames = newFilteredGames
                
                return .send(.updateViewStack(data: SportDecodableModel.nbaLeagueSchedule(leagueScheduleResponseModel, newDisplayModel)))
                
            case .updateViewStack(let data):
                state.dataForViewStack = data
                
                return .run { send in
                    // NOTE: TCA에서 (.run이 아닌)한 액션의 case 안에서의 동작은 다 끝나고 한번에 반영되기 때문에, 한 동작 안에서 같은 state를 두번 바꾸면 마지막에 바꾼걸로 반영이 된다. -> 아직 확실하지는 않음
                    // 여기서는 목적이 onChanges trigger를 위해 state.dataForViewStack를 두번 바꾸는것이기 때문에 이렇게 진행.
                    await send(.resetDataForViewStack)
                }
                
            case .resetDataForViewStack:
                // Set nil for next update. Because the data is same as SportDecodableModel, .onChange() is not triggered.
                // Has to figure out better structrue.
                state.dataForViewStack = nil
                
                return .none
                
            case .updateDisplayDataState(let fetchState):
                state.displayDataState = fetchState
                
                return .none
                
            case .setDisplayModel(let displayModel):
                state.displayModel = displayModel
                
                return .none
            } // switch action
        }
    }
}
