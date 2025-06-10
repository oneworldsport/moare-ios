//
//  MLBLeagueScheduleStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MLBLeagueScheduleStore {
    typealias BaseSchedule = BaseScheduleStore<MLBLeagueScheduleDisplayModel>
    
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var baseSchedule = BaseSchedule.State()
        var filteredGames: [Int: [MLBGameForSchedule]] = [:]
        
        /* ---------------------
           ui state
           --------------------- */
        var gameResultOpenedStateList: [String: Bool] = [:]
        
        /* ---------------------
           etc
           --------------------- */
        var dataForViewStack: SportDecodableModel? = nil
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
            mlbLeagueScheduleData: SportDecodableModel,
            mlbGameStatsData: SportDecodableModel
        )
        
        /* ---------------------
           private
           --------------------- */
        case setDays(isInit: Bool = false)
        case fetchGames
        
        case updateViewStack(data: SportDecodableModel)
        case resetDataForViewStack
        
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(displayModel: MLBLeagueScheduleDisplayModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseSchedule, action: \.baseSchedule) {
            BaseSchedule()
        }
        
        Reduce { state, action in
            switch action {
            case .baseSchedule(.initData):
                // init with default value
                state.filteredGames = [:]
                state.gameResultOpenedStateList = [:]
                
                // init data
                if let yearMonthList = state.baseSchedule.displayModel?.yearMonthList {
                    state.baseSchedule.yearMonthList = yearMonthList
                }
                
                // select default yearMonth
                if let date = state.baseSchedule.displayModel?.games.first?.date {
                    let defaultYearMonth = CalendarUtil.formatDate(date: date, formatType: .yearMonth)
                    let defaultYearMonthIndex = state.baseSchedule.yearMonthList.enumerated().first { $0.element == defaultYearMonth }
                    
                    state.baseSchedule.selectedYearMonth = defaultYearMonth
                    
                    if let defaultYearMonthIndex {
                        state.baseSchedule.selectedYearMonthIndex = defaultYearMonthIndex.offset
                    }
                }
                
                return .send(.setDays(isInit: true))
                
            case .baseSchedule(_):
                return .none
                
            case .selectYearMonth(let yearMonth, let selectedIndex):
                state.baseSchedule.selectedYearMonth = yearMonth
                state.baseSchedule.selectedYearMonthIndex = selectedIndex
                
                return .send(.fetchGames)
                
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
                        
                        let games = state.baseSchedule.displayModel?.games.filter { game in
                            CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: day.day)
                        }
                        
                        gameResultOpenedStateList.merge((games ?? []).reduce(into: [:]) { $0[$1.gameId] = state.baseSchedule.isAllResultOpened }) { _, new in new }
                        
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
                        
                        let entity = displayModel?.entityInfo.first ?? EntityInfo(
                            entityId: 90102,
                            entityName: "MLB",
                            category: "baseball",
                            entityType: "league",
                            leagueId: 90102,
                            teamId: nil,
                            playerId: nil
                        )
                        
                        let result = try await searchClient.fetchLeagueSchedule(entity: entity, yearMonth: String(yearMonth))
                        
                        if case let .mlbLeagueSchedule(_, displayModel) = result.data {
                            await send(.setDisplayModel(displayModel: displayModel))
                            await send(.updateViewStack(data: result.data))
                            await send(.setDays())
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case .updateGamesData(let mlbLeagueScheduleData, let mlbGameStatsData):
                guard case let .mlbLeagueSchedule(leagueScheduleResponseModel, leagueScheduleDisplayModel) = mlbLeagueScheduleData,
                        case let .mlbGameStats(_, gameStatsDisplayModel) = mlbGameStatsData else {
                    return .none
                }
                
                let game = gameStatsDisplayModel.game
                let homeTeamId = game.teams.home.id
                let awayTeamId = game.teams.away.id
                let homeTeamScore = game.linescore.teams.home.runs
                let awayTeamScore = game.linescore.teams.away.runs
                
                let newGames = leagueScheduleDisplayModel.games.map {
                    $0.gameId == game.game.id ? MLBGameForSchedule(
                        itemKey: "\(game.gameInfo.gameDate)#\(game.game.id)",
                        homeTeamId: homeTeamId,
                        awayTeamId: awayTeamId,
                        homeTeamScore: homeTeamScore,
                        awayTeamScore: awayTeamScore,
                        gameStatus: game.status.statusCode,
                        gameInfo: nil
                    ) : $0
                }
                
                var newDisplayModel = leagueScheduleDisplayModel
                newDisplayModel.games = newGames
                state.baseSchedule.displayModel = newDisplayModel
                
                var newFilteredGames = state.filteredGames
                newFilteredGames[state.baseSchedule.selectedDayIndex] = newDisplayModel.games.filter { game in
                    CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: state.baseSchedule.selectedDayIndex + 1)
                }
                
                state.filteredGames = newFilteredGames
                
                return .send(.updateViewStack(data: SportDecodableModel.mlbLeagueSchedule(leagueScheduleResponseModel, newDisplayModel)))
                
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
                state.baseSchedule.displayDataState = fetchState
                
                return .none
                
            case .setDisplayModel(let displayModel):
                state.baseSchedule.displayModel = displayModel
                
                return .none
            }
        }
    }
}
