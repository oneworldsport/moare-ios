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
        var baseSchedule: BaseSchedule.State
        
        var filteredGames: [Int: [KBOGameForSchedule]] = [:]
        var gameResultOpenedStateList: [String: Bool] = [:]
        
        init(displayModel: KBOLeagueScheduleDisplayModel) {
            self.baseSchedule = BaseSchedule.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseSchedule(BaseSchedule.Action)
        
        /* ---------------------
           view action
           --------------------- */
        case toggleAllResult
        case updateResultOpenedState(itemKey: String, isOpened: Bool) // NOTE: 더블헤더가 있는 날에 취소된 경기가 있으면 gameId가 같은 경우가 있어 gameId 대신에 itemKey를 사용
        case selectGame(game: KBOGameForSchedule)
        case showTournament
        case showTeamStandings
        case refreshGames
        
        /* ---------------------
           private
           --------------------- */
        case setDays(isInit: Bool = false)
        case fetchGames
        
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(displayModel: KBOLeagueScheduleDisplayModel)
        case updateDisplayModelGames([KBOGameForSchedule])
        
        case updateFilteredGames
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showGameStats(model: SportDecodableModel)
        case showTournament(model: SportDecodableModel)
        case showTeamStandings(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseSchedule, action: \.baseSchedule) { BaseSchedule() }
        
        Reduce { state, action in
            switch action {
            case .baseSchedule(.initData):
                let displayModel = state.baseSchedule.displayModel
                
                // init with default value
                state.filteredGames = [:]
                state.gameResultOpenedStateList = [:]
                
                // init data
                state.baseSchedule.yearMonthList = displayModel.yearMonthList
                
                // select default yearMonth
                switch displayModel.scheduleType {
                case .league:
                    if let date = displayModel.games.first?.date {
                        return .send(.baseSchedule(.setDefaultYearMonth(date: date)))
                    }
                    
                    return .send(.setDays(isInit: true))
                    
                case .team:
                    let upcomingGame = displayModel.games.first { game in
                        CalendarUtil.isUpcomingDay(date: game.date)
                    }
                    
                    
                    if let upcomingGame {
                        return .send(.baseSchedule(.setDefaultYearMonth(date: upcomingGame.date)))
                    } else {
                        if let date = displayModel.games.last?.date {
                            return .send(.baseSchedule(.setDefaultYearMonth(date: date)))
                        }
                    }
                    
                    return .send(.setDays(isInit: true))
                    
                case .teamFlat:
                    // filteredGames 초기화
                    state.filteredGames = [0: displayModel.games]
                    
                    // gameResultOpenedStateList 초기화
                    state.gameResultOpenedStateList = displayModel.games.reduce(into: [String: Bool]()) { dict, game in
                        dict[game.itemKey] = false
                    }
                    
                    // paging기능이 생기면서 baseSchedule.days에 기본값(0)을 넣어줘야 아이템이 보임
                    state.baseSchedule.days = [DayInfo(day: 0, dayOfWeek: 0, displayName: "")]
                    
                    return .none
    
                default:
                    return .none
                }
                
            case let .baseSchedule(.selectYearMonth(_, _, isInit)):
                if isInit {
                    return .send(.setDays(isInit: isInit))
                } else {
                    switch state.baseSchedule.displayModel.scheduleType {
                    case .league:
                        return .send(.fetchGames)
                    case .team:
                        return .send(.setDays())
                    default :
                        return .none
                    }
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
                    var days = CalendarUtil.getDaysInMonth(year: Int("20\(year)") ?? CalendarUtil.currentYear, month: month)
                    
                    var gameResultOpenedStateList: [String: Bool] = [:]
                    var newFilteredGame = state.filteredGames
                    
                    days = days.enumerated().compactMap { index, day in
                        var newDay = day
                        
                        let games = state.baseSchedule.displayModel.games.filter { game in
                            CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: day.day)
                        }
                        
                        gameResultOpenedStateList.merge((games).reduce(into: [:]) { $0[$1.itemKey] = state.baseSchedule.isAllResultOpened }) { _, new in new }
                        
                        newFilteredGame[index] = games
                        
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
                            entityId: 90101,
                            entityName: "KBO",
                            category: "baseball",
                            entityType: "league",
                            leagueId: 90101,
                            teamId: nil,
                            playerId: nil
                        )
                        
                        let result = try await searchClient.fetchLeagueSchedule(entity: entity, season: displayModel.season, yearMonth: String(yearMonth))
                        
                        if case let .kboLeagueSchedule(_, displayModel) = result.data {
                            await send(.setDisplayModel(displayModel: displayModel))
                            await send(.setDays())
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case let .selectGame(game):
                return .run { [displayModel = state.baseSchedule.displayModel] send in
                    let result = try await searchClient.fetchById(
                        season: displayModel.season,
                        category: "baseball",
                        date: game.date,
                        dataType: "baseball_game_stats",
                        leagueId: displayModel.leagueId,
                        id: game.gameId
                    )
                    
                    await send(.delegate(.showGameStats(model: result.data)))
                    await send(.updateResultOpenedState(itemKey: game.itemKey, isOpened: true))
                }
                
            case .showTournament:
                let season = state.baseSchedule.displayModel.season
                
                return .run { send in
                    let keywordInfo = KeywordInfo(
                        keyword: "KBO 가을야구",
                        weight: 100,
                        keywords: [Keyword(keyword: "가을야구", id: "tournament", priority: 2)],
                        entities: [
                            EntityInfo(
                                entityId: Constants.Ids.kbo,
                                entityName: "KBO",
                                category: "baseball",
                                entityType: "league",
                                leagueId: Constants.Ids.kbo,
                                teamId: nil,
                                playerId: nil
                            )
                        ]
                    )
                    
                    let result = try await searchClient.fetchDataByKeyword(keyword: keywordInfo, season: season)
                    
                    await send(.delegate(.showTournament(model: result.data)))
                }
                
            case .showTeamStandings:
                let season = state.baseSchedule.displayModel.season
                
                return .run { send in
                    let keywordInfo = KeywordInfo(
                        keyword: "KBO 순위",
                        weight: 100,
                        keywords: [Keyword(keyword: "순위", id: "standings", priority: 1)],
                        entities: [
                            EntityInfo(
                                entityId: Constants.Ids.kbo,
                                entityName: "KBO",
                                category: "baseball",
                                entityType: "league",
                                leagueId: Constants.Ids.kbo,
                                teamId: nil,
                                playerId: nil
                            )
                        ]
                    )
                    
                    let result = try await searchClient.fetchDataByKeyword(keyword: keywordInfo, season: season)
                    
                    await send(.delegate(.showTeamStandings(model: result.data)))
                }
                
            case .refreshGames:
                guard let games = state.filteredGames[state.baseSchedule.selectedDayIndex] else {
                    return .none
                }
                
                let entity = state.baseSchedule.displayModel.entityInfo.first ?? EntityInfo(
                    entityId: 90101,
                    entityName: "KBO",
                    category: "baseball",
                    entityType: "league",
                    leagueId: 90101,
                    teamId: nil,
                    playerId: nil
                )
                let season = state.baseSchedule.displayModel.season
                let day = state.baseSchedule.selectedDay?.day
                let selectedYearMonth = state.baseSchedule.selectedYearMonth
                let splittedYearMonth = selectedYearMonth.split(separator: "/")
                let yearMonth = splittedYearMonth[0] + splittedYearMonth[1]
                
                return .run { send in
                    do {
                        let hasLive = games.contains { game in
                            game.gameStatus == Constants.GameStatus.KBO.live
                        }
                        
                        if hasLive {
                            let result = try await searchClient.fetchLeagueSchedule(
                                entity: entity,
                                season: season,
                                yearMonth: String(yearMonth),
                                day: day
                            )
                            
                            if case .kboLeagueSchedule(_, let displayModel) = result.data {
                                await send(.updateDisplayModelGames(displayModel.games))
                            }
                        }
                    } catch {
                    }
                }
                
            case .updateDisplayDataState(let fetchState):
                state.baseSchedule.displayDataState = fetchState
                
                return .none
                
            case .setDisplayModel(let displayModel):
                state.baseSchedule.displayModel = displayModel
                
                return .none
                
            case .updateFilteredGames:
                let displayModel = state.baseSchedule.displayModel
                
                if displayModel.scheduleType == .teamFlat {
                    state.filteredGames = [0: displayModel.games]
                } else {
                    var newFilteredGames = state.filteredGames
                    newFilteredGames[state.baseSchedule.selectedDayIndex] = displayModel.games.filter { game in
                        CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: state.baseSchedule.selectedDayIndex + 1)
                    }
                    
                    state.filteredGames = newFilteredGames
                }
                
                return .none
                
            case .updateDisplayModelGames(let games):
                let gamesById = Dictionary(uniqueKeysWithValues: games.map { ($0.itemKey, $0) })

                state.baseSchedule.displayModel.games = state.baseSchedule.displayModel.games.map { gamesById[$0.itemKey] ?? $0 }
                
                return .send(.updateFilteredGames)
                
            case .baseSchedule(_):
                return .none
                
            case .delegate:
                return .none
            } // switch action
        }
    }
}
