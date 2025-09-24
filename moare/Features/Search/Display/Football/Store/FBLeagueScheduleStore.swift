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
        
        var filteredGames: [Int: [FBGameForSchedule]] = [:]
        var gameResultOpenedStateList: [String: Bool] = [:]
        
        var dataForViewStack: SportDecodableModel? = nil
        
        init(displayModel: FBLeagueScheduleDisplayModel) {
            self.baseSchedule = BaseSchedule.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseSchedule(BaseSchedule.Action)
        
        /* ---------------------
           view action
           --------------------- */
        case selectYearMonth(yearMonth: String, selectedIndex: Int)
        case toggleAllResult
        case updateResultOpenedState(gameId: String, isOpened: Bool)
        case updateGamesData(
            fbLeagueScheduleData: SportDecodableModel,
            fbGameStatsData: SportDecodableModel
        )
        
        /* ---------------------
           private
           --------------------- */
        case setDays(isInit: Bool = false)
        case fetchGames
        
        case updateViewStack(data: SportDecodableModel)
        case resetDataForViewStack
        
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(FBLeagueScheduleDisplayModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseSchedule, action: \.baseSchedule) { BaseSchedule() }
        
        Reduce { state, action in
            switch action {
            case .baseSchedule(.initData):
                // init with default value
                state.filteredGames = [:]
                state.gameResultOpenedStateList = [:]
                state.dataForViewStack = nil
                
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
                            await send(.updateViewStack(data: result.data))
                            await send(.setDays())
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case .updateGamesData(let fbLeagueScheduleData, let fbGameStatsData):
                guard case let .fbLeagueSchedule(leagueScheduleResponseModel, leagueScheduleDisplayModel) = fbLeagueScheduleData,
                        case let .fbGameStats(_, gameStatsDisplayModel) = fbGameStatsData else {
                    return .none
                }
                
                let game = gameStatsDisplayModel.game
                let newGames = leagueScheduleDisplayModel.games.map {
                    $0.gameId == String(game.fixture.id) ? ModelConverter.fbGameToGameScheduleConverter(game: game) : $0
                }
                
                var newDisplayModel = leagueScheduleDisplayModel
                newDisplayModel.games = newGames
                state.baseSchedule.displayModel = newDisplayModel
                
                var newFilteredGames = state.filteredGames
                newFilteredGames[state.baseSchedule.selectedDayIndex] = newDisplayModel.games.filter { game in
                    CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: state.baseSchedule.selectedDayIndex + 1)
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
                state.baseSchedule.displayDataState = fetchState
                
                return .none
                
            case .setDisplayModel(let displayModel):
                state.baseSchedule.displayModel = displayModel
                
                return .none
                
            case .baseSchedule:
                return .none
            } // switch action
        }
    }
}
