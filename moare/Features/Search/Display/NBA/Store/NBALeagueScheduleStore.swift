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
    typealias BaseSchedule = BaseScheduleStore<NBALeagueScheduleDisplayModel>
    
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var baseSchedule: BaseSchedule.State
        
        var filteredGames: [Int: [NBAGameForSchedule]] = [:]
        var gameResultOpenedStateList: [String: Bool] = [:]
        
        init(displayModel: NBALeagueScheduleDisplayModel) {
            self.baseSchedule = BaseSchedule.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case baseSchedule(BaseSchedule.Action)
        
        /* ---------------------
           view action
           --------------------- */
        case selectYearMonth(yearMonth: String, selectedIndex: Int)
        case toggleAllResult
        case updateResultOpenedState(gameId: String, isOpened: Bool)
        
        /* ---------------------
           private
           --------------------- */
        case setDays(isInit: Bool = false)
        case fetchGames
        
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(displayModel: NBALeagueScheduleDisplayModel)
        
        case updateFilteredGames
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseSchedule, action: \.baseSchedule) { BaseSchedule() }
        
        Reduce { state, action in
            switch action {
            case .baseSchedule(.initData):
                // init with default value
                state.filteredGames = [:]
                state.gameResultOpenedStateList = [:]
                
                // select default yearMonth
                state.baseSchedule.yearMonthList = state.baseSchedule.displayModel.yearMonthList

                switch state.baseSchedule.displayModel.scheduleType {
                case .league:
                    if let date = state.baseSchedule.displayModel.games.first?.date {
                        return .send(.baseSchedule(.setDefaultYearMonth(date: date)))
                    }
                    
                    return .send(.setDays(isInit: true))
                    
                case .team:
                    let upcomingGame = state.baseSchedule.displayModel.games.first { game in
                        CalendarUtil.isUpcomingDay(date: game.date)
                    }
                    
                    
                    if let upcomingGame {
                        return .send(.baseSchedule(.setDefaultYearMonth(date: upcomingGame.date)))
                    } else {
                        if let date = state.baseSchedule.displayModel.games.last?.date {
                            return .send(.baseSchedule(.setDefaultYearMonth(date: date)))
                        }
                    }
                    
                    return .send(.setDays(isInit: true))
                    
                case .teamFlat:
                    if let displayModel = state.baseSchedule.displayModel as? NBALeagueScheduleDisplayModel {
                            // filteredGames 초기화
                            state.filteredGames = [0: displayModel.games]
                            
                            // gameResultOpenedStateList 초기화
                            state.gameResultOpenedStateList = displayModel.games.reduce(into: [String: Bool]()) { dict, game in
                                dict[game.gameId] = false
                            }
                        }
                    
                    return .none
    
                default:
                    return .none
                }
                
            case .baseSchedule(.setDefaultYearMonth(_)):
                return .send(.setDays(isInit: true))
                
            case .selectYearMonth(let yearMonth, let selectedIndex):
                state.baseSchedule.selectedYearMonth = yearMonth
                state.baseSchedule.selectedYearMonthIndex = selectedIndex
                
                switch state.baseSchedule.displayModel.scheduleType {
                case .league:
                    return .send(.fetchGames)
                case .team:
                    return .send(.setDays())
                default :
                    return .none
                }
                
            case .toggleAllResult:
                let newState = !state.baseSchedule.isAllResultOpened
                state.baseSchedule.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                
                return .none
                
            case .updateResultOpenedState(let gameId, let isOpened):
                state.gameResultOpenedStateList[gameId] = isOpened
                
                return .none
                
            case .setDays(let isInit):
                // set filtered games to each day
                let components = state.baseSchedule.selectedYearMonth.split(separator: "/")
                
                if components.count == 2,
                   let year = Int(components[0]),
                   let month = Int(components[1]) {
                    var days = CalendarUtil.getDaysInMonth(year: Int("20\(year)") ?? 2025, month: month)
                    
                    var gameResultOpenedStateList: [String: Bool] = [:]
                    var newFilteredGame = state.filteredGames
                    
                    days = days.enumerated().compactMap { index, day in
                        var newDay = day
                        
                        let games = state.baseSchedule.displayModel.games.filter { game in
                            CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: day.day)
                        }
                        
                        gameResultOpenedStateList.merge((games ?? []).reduce(into: [:]) { $0[$1.gameId] = state.baseSchedule.isAllResultOpened }) { _, new in new }
                        
                        // NOTE: games는 optional인데 왜 컴파일 에러가 안나지..?
                        newFilteredGame[index] = games ?? []
                        
                        if games.isEmpty == true {
                            newDay.isDataEmpty = true
                        }
                        
                        return newDay
                    }
                    
                    // ui operation order
                    // 1. Set default 'isOpened' value as false to every games, before 'filteredGames' show.
                    state.gameResultOpenedStateList = gameResultOpenedStateList
                    
                    // 2. Set days to days calendar.
                    state.baseSchedule.days = days
                    
                    // 3. Move bar and scroll the days calendar.
                    if isInit {
                        // select default day
                        let defaultDay = CalendarUtil.getDefaultDay(yearMonth: state.baseSchedule.selectedYearMonth, dayList: state.baseSchedule.days)
                        
                        if let defaultDay = defaultDay {
                            state.baseSchedule.selectedDay = defaultDay.1
                            state.baseSchedule.selectedDayIndex = defaultDay.0
                        }
                    } else {
                        // select first day that has games
                        for (index, day) in state.baseSchedule.days.enumerated() {
                            if !day.isDataEmpty {
                                state.baseSchedule.selectedDay = day
                                state.baseSchedule.selectedDayIndex = index
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
                return .run { [selectedYearMonth = state.baseSchedule.selectedYearMonth, displayModel = state.baseSchedule.displayModel] send in
                    await send(.updateDisplayDataState(fetchState: .fetching), animation: AnimationConstants.AnimationType.defaultAnimation)
                    
                    do {
                        let selectedYearMonth = selectedYearMonth.split(separator: "/")
                        let yearMonth = selectedYearMonth[0] + selectedYearMonth[1]
                        
                        let entity = displayModel.entityInfo.first ?? EntityInfo(
                            entityId: 90001,
                            entityName: "NBA",
                            category: "basketball",
                            entityType: "league",
                            leagueId: 90001,
                            teamId: nil,
                            playerId: nil
                        )
                        
                        let result = try await searchClient.fetchLeagueSchedule(entity: entity, season: displayModel.season, yearMonth: String(yearMonth))
                        
                        if case let .nbaLeagueSchedule(_, displayModel) = result.data {
                            await send(.setDisplayModel(displayModel: displayModel))
                            await send(.setDays())
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case .updateDisplayDataState(let fetchState):
                state.baseSchedule.displayDataState = fetchState
                
                return .none
                
            case .setDisplayModel(let displayModel):
                state.baseSchedule.displayModel = displayModel
                
                return .none
                
            case .updateFilteredGames:
                var newFilteredGames = state.filteredGames
                newFilteredGames[state.baseSchedule.selectedDayIndex] = state.baseSchedule.displayModel.games.filter { game in
                    CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: state.baseSchedule.selectedDayIndex + 1)
                }
                
                state.filteredGames = newFilteredGames
                
                return .none
                
            case .baseSchedule:
                return .none
            } // switch action
        }
    }
}
