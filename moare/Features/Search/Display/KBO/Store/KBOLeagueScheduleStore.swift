//
//  KBOLeagueScheduleStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KBOLeagueScheduleStore {
    typealias BaseSchedule = BaseScheduleStore<KBOLeagueScheduleDisplayModel>
    
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var baseSchedule = BaseSchedule.State()
        var filteredGames: [Int: [KBOGameForSchedule]] = [:]
        
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
        case updateResultOpenedState(itemKey: String, isOpened: Bool) // NOTE: 더블헤더가 있는 날에 취소된 경기가 있으면 gameId가 같은 경우가 있어 gameId 대신에 itemKey를 사용
        case updateGamesData(
            kboLeagueScheduleData: SportDecodableModel,
            kboGameStatsData: SportDecodableModel
        )
        
        /* ---------------------
           private
           --------------------- */
        case setDays(isInit: Bool = false)
        case fetchGames
        
        case updateViewStack(data: SportDecodableModel)
        case resetDataForViewStack
        
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(displayModel: KBOLeagueScheduleDisplayModel)
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
                switch state.baseSchedule.displayModel?.scheduleType {
                case .league:
                    if let date = state.baseSchedule.displayModel?.games.first?.date {
                        return .send(.baseSchedule(.setDefaultYearMonth(date: date)))
                    }
                    
                    return .send(.setDays(isInit: true))
                    
                case .team:
                    let upcomingGame = state.baseSchedule.displayModel?.games.first { game in
                        CalendarUtil.isUpcomingDay(date: game.date)
                    }
                    
                    
                    if let upcomingGame {
                        return .send(.baseSchedule(.setDefaultYearMonth(date: upcomingGame.date)))
                    } else {
                        if let date = state.baseSchedule.displayModel?.games.last?.date {
                            return .send(.baseSchedule(.setDefaultYearMonth(date: date)))
                        }
                    }
                    
                    return .send(.setDays(isInit: true))
    
                default:
                    return .none
                }
                
            case .baseSchedule(.setDefaultYearMonth(_)):
                return .send(.setDays(isInit: true))
                
            case .baseSchedule(_):
                return .none
                
            case .selectYearMonth(let yearMonth, let selectedIndex):
                state.baseSchedule.selectedYearMonth = yearMonth
                state.baseSchedule.selectedYearMonthIndex = selectedIndex
                
                switch state.baseSchedule.displayModel?.scheduleType {
                case .league:
                    return .send(.fetchGames)
                case .team:
                    return .send(.setDays(isInit: true))
                default :
                    return .send(.setDays(isInit: true))
                }
                
            case .toggleAllResult:
                let newState = !state.baseSchedule.isAllResultOpened
                state.baseSchedule.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                
                return .none
                
            case .updateResultOpenedState(let itemKey, let isOpened):
                state.gameResultOpenedStateList[itemKey] = isOpened
                
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
                        
                        gameResultOpenedStateList.merge((games ?? []).reduce(into: [:]) { $0[$1.itemKey] = state.baseSchedule.isAllResultOpened }) { _, new in new }
                        
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
                            entityId: 90101,
                            entityName: "KBO",
                            category: "baseball",
                            entityType: "league",
                            leagueId: 90101,
                            teamId: nil,
                            playerId: nil
                        )
                        
                        let result = try await searchClient.fetchLeagueSchedule(entity: entity, season: displayModel?.season, yearMonth: String(yearMonth))
                        
                        if case let .kboLeagueSchedule(_, displayModel) = result.data {
                            await send(.setDisplayModel(displayModel: displayModel))
                            await send(.updateViewStack(data: result.data))
                            await send(.setDays())
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case .updateGamesData(let kboLeagueScheduleData, let kboGameStatsData):
                guard case let .kboLeagueSchedule(leagueScheduleResponseModel, leagueScheduleDisplayModel) = kboLeagueScheduleData,
                        case let .kboGameStats(_, gameStatsDisplayModel) = kboGameStatsData else {
                    return .none
                }
                
                let game = gameStatsDisplayModel.game
                let itemKey = "\(game.gameInfo?.date.split(separator: "+").first ?? "")#\(game.gameInfo?.gameId ?? "")"
                let newGames = leagueScheduleDisplayModel.games.map {
                    $0.itemKey == itemKey ? ModelConverter.kboGameToGameScheduleConverter(game: game) : $0
                }
                
                var newDisplayModel = leagueScheduleDisplayModel
                newDisplayModel.games = newGames
                state.baseSchedule.displayModel = newDisplayModel
                
                var newFilteredGames = state.filteredGames
                newFilteredGames[state.baseSchedule.selectedDayIndex] = newDisplayModel.games.filter { game in
                    CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: state.baseSchedule.selectedDayIndex + 1)
                }
                
                state.filteredGames = newFilteredGames
                
                return .send(.updateViewStack(data: SportDecodableModel.kboLeagueSchedule(leagueScheduleResponseModel, newDisplayModel)))
                
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
