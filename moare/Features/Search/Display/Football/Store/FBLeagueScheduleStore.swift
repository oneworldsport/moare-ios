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
    typealias BaseSchedule = BaseScheduleStore<FBLeagueScheduleDisplayModel>
    
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 80
        
        /* ---------------------
           data state
           --------------------- */
        var baseSchedule: BaseSchedule.State
        
        var league: FBLeague? = nil // FBGameStatsView에서 title 정보에 사용
        
        var filteredGames: [Int: [FBGameForSchedule]] = [:]
        var gameResultOpenedStateList: [String: Bool] = [:]
        var selectedGame: FBGameForSchedule? = nil
        
        // .onChange(of: store.baseSchedule.displayModel)이 실행될때 updateSelectedGame 액션이 실행되는데,
        // 내부에서 displayModel이 바뀌었을때는 실행되면 안되고 FBGameStatsView에서 새로고침 했을때만 실행되게 하기 위해 만든 flag.
        var shouldUpdateSelectedGame: Bool = true
        
        init(displayModel: FBLeagueScheduleDisplayModel) {
            self.baseSchedule = BaseSchedule.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseSchedule(BaseSchedule.Action)
        
        case selectYearMonth(yearMonth: String, selectedIndex: Int)
        case toggleAllResult
        case updateResultOpenedState(gameId: String, isOpened: Bool)
        case selectGame(game: FBGameForSchedule)
        
        case setDays(isInit: Bool = false)
        case fetchGames
        
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(FBLeagueScheduleDisplayModel)
        
        case updateFilteredGames
        case updateSelectedGame // FBGameStatsView에서 새로고침 했을때 사용되는 action
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showGameStats(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseSchedule, action: \.baseSchedule) { BaseSchedule() }
        
        Reduce { state, action in
            switch action {
            case .baseSchedule(.initData):
                // init with default value
                state.filteredGames = [:]
                state.gameResultOpenedStateList = [:]
                
                // init data
                state.baseSchedule.yearMonthList = state.baseSchedule.displayModel.yearMonthList
                
                // select default yearMonth
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
                
                // added to prevent any gaps
                // executed before .run{}
//                if state.displayDataState != .success {
//                    state.displayDataState = .success
//                }
                
                return .none
                
            case .fetchGames:
                return .run { [selectedYearMonth = state.baseSchedule.selectedYearMonth, displayModel = state.baseSchedule.displayModel] send in
                    await send(.updateDisplayDataState(fetchState: .fetching), animation: AnimationConstants.AnimationType.defaultAnimation)
                    
                    do {
                        let selectedYearMonth = selectedYearMonth.split(separator: "/")
                        let yearMonth = selectedYearMonth[0] + selectedYearMonth[1]
                        
                        let entity = displayModel.entityInfo.first ?? EntityInfo(
                            entityId: 39,
                            entityName: "프리미어리그",
                            category: "football",
                            entityType: "league",
                            leagueId: 39,
                            teamId: nil,
                            playerId: nil
                        )
                        
                        let result = try await searchClient.fetchLeagueSchedule(entity: entity, season: displayModel.season, yearMonth: String(yearMonth))
                        
                        
                        if case .fbLeagueSchedule(_, let displayModel) = result.data {
                            await send(.setDisplayModel(displayModel))
                            await send(.setDays())
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case let .selectGame(game):
                state.selectedGame = game
                state.filteredGames[state.baseSchedule.selectedDayIndex] = [game]
                
                return .run { [displayModel = state.baseSchedule.displayModel] send in
                    let result = try await searchClient.fetchById(
                        season: displayModel.season,
                        category: "football",
                        date: game.date,
                        dataType: "football_game_stats",
                        leagueId: displayModel.leagueId,
                        id: game.gameId
                    )
                    
                    await send(.delegate(.showGameStats(model: result.data)))
                    await send(.updateResultOpenedState(gameId: game.gameId, isOpened: true))
                }
                
            case .updateDisplayDataState(let fetchState):
                state.baseSchedule.displayDataState = fetchState
                
                return .none
                
            case .setDisplayModel(let displayModel):
                state.shouldUpdateSelectedGame = false
                state.baseSchedule.displayModel = displayModel
                
                return .none
                
            case .updateSelectedGame:
                if state.shouldUpdateSelectedGame {
                    if let gameId = state.selectedGame?.gameId {
                        if let game = state.baseSchedule.displayModel.games.first(where: { $0.gameId == gameId }) {
                            state.filteredGames[state.baseSchedule.selectedDayIndex] = [game]
                        }
                    }
                }
                
                state.shouldUpdateSelectedGame = true
                
                return .none
                
            case .updateFilteredGames:
                var newFilteredGames = state.filteredGames
                newFilteredGames[state.baseSchedule.selectedDayIndex] = state.baseSchedule.displayModel.games.filter { game in
                    CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: state.baseSchedule.selectedDayIndex + 1)
                }
                
                state.filteredGames = newFilteredGames
                state.selectedGame = nil // 해당 액션은 뒤로왔을때 실행되므로 선택된 게임은 없앤다.
                
                return .none
                
            case .baseSchedule:
                return .none
                
            case .delegate:
                return .none
            } // switch action
        }
    }
}
