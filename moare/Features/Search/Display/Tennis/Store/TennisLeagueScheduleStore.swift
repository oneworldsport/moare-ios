//
//  TennisLeagueScheduleStore.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct TennisLeagueScheduleStore {
    typealias BaseSchedule = BaseScheduleStore<TennisLeagueScheduleDisplayModel>
    
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        var baseSchedule: BaseSchedule.State
        
        var filteredGames: [Int: [TennisGameForSchedule]] = [:]
        var gameResultOpenedStateList: [String: Bool] = [:]
        
        init(displayModel: TennisLeagueScheduleDisplayModel) {
            self.baseSchedule = BaseSchedule.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseSchedule(BaseSchedule.Action)
        
        case toggleAllResult
        case updateResultOpenedState(gameId: String, isOpened: Bool)
        case selectGame(game: TennisGameForSchedule)
        case showTournament
        case refreshGames
        
        case setDays(isInit: Bool = false)
        case fetchGames
        
        case updateDisplayDataState(fetchState: ApiFetchState)
        case setDisplayModel(displayModel: TennisLeagueScheduleDisplayModel)
        case updateDisplayModelGames([TennisGameForSchedule])
        
        case updateFilteredGames
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showGameStats(model: SportDecodableModel)
        case showTournament(model: SportDecodableModel)
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
                
                // select default yearMonth
                state.baseSchedule.yearMonthList = displayModel.yearMonthList
                
                // 
                var selectedIndex: Int? {
                    displayModel.sortedRelatedLeagues?.firstIndex(of: displayModel.leagueId)
                }
                
                state.baseSchedule.selectedRelatedLeagueIndex = selectedIndex ?? 0
                
                switch displayModel.scheduleType {
                case .league:
                    if let date = displayModel.games.first?.date {
                        return .send(.baseSchedule(.setDefaultYearMonth(date: date)))
                    }
                    
                    return .send(.setDays(isInit: true))
                    
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
                    default :
                        return .none
                    }
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
                        
                        gameResultOpenedStateList.merge((games).reduce(into: [:]) { $0[$1.gameId] = state.baseSchedule.isAllResultOpened }) { _, new in new }
                        
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
                            entityId: Constants.Ids.ausOpenMSingle,
                            entityName: "호주오픈",
                            category: "tennis",
                            entityType: "league",
                            leagueId: Constants.Ids.ausOpenMSingle,
                            teamId: nil,
                            playerId: nil
                        )
                        
                        let result = try await searchClient.fetchLeagueSchedule(entity: entity, season: displayModel.season, yearMonth: String(yearMonth))
                        
                        if case let .tennisLeagueSchedule(_, displayModel) = result.data {
                            await send(.setDisplayModel(displayModel: displayModel))
                            await send(.setDays())
                        }
                    } catch {
                        await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                        print("\(error)")
                    }
                }
                
            case let .selectGame(game):
                let displayModel = state.baseSchedule.displayModel
                let leagueKrName = displayModel.relatedLeaguesKrname[state.baseSchedule.selectedRelatedLeagueIndex]
                let roundName = game.gameInfo?.roundInfo?.name ?? ""
                
                return .run { send in
                    do {
                        let result = try await searchClient.fetchById(
                            season: displayModel.season,
                            category: "tennis",
                            date: game.date,
                            dataType: "tennis_game_stats",
                            leagueId: displayModel.leagueId,
                            id: game.gameId
                        )
                        
                        if case .tennisGameStats(let responseModel, var gameStatsDisplayModel) = result.data {
                            // TennisGameStatsView에서 title에 보여줄 데이터 추가
                            gameStatsDisplayModel.leagueKrName = leagueKrName
                            gameStatsDisplayModel.roundName = roundName
                            let updated: SportDecodableModel = .tennisGameStats(responseModel, gameStatsDisplayModel)
                            
                            await send(.delegate(.showGameStats(model: updated)))
                            await send(.updateResultOpenedState(gameId: game.gameId, isOpened: true))
                        }
                    } catch {
                        print("\(error)")
                    }
                }
                
            case .showTournament:
                let leagueId = state.baseSchedule.displayModel.leagueId
                
                return .run { send in
                    let leagueName = StringConstants.Tennis.leagueNameStr(leagueId: leagueId)
                    let keywordInfo = KeywordInfo(
                        keyword: "\(leagueName) 대진표",
                        weight: 100,
                        keywords: [Keyword(keyword: "대진표", id: "tournament", priority: 2)],
                        entities: [
                            EntityInfo(
                                entityId: leagueId,
                                entityName: leagueName,
                                category: "tennis",
                                entityType: "league",
                                leagueId: leagueId,
                                teamId: nil,
                                playerId: nil
                            )
                        ]
                    )
                    
                    let result = try await searchClient.fetchDataByKeyword(keyword: keywordInfo)
                    
                    await send(.delegate(.showTournament(model: result.data)))
                }
                
            case .refreshGames:
                guard let games = state.filteredGames[state.baseSchedule.selectedDayIndex] else {
                    return .none
                }
                
                let entity = state.baseSchedule.displayModel.entityInfo.first ?? EntityInfo(
                    entityId: Constants.Ids.ausOpenMSingle,
                    entityName: "호주오픈",
                    category: "tennis",
                    entityType: "league",
                    leagueId: Constants.Ids.ausOpenMSingle,
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
                            Constants.GameStatus.Tennis.liveList.contains(Int(game.gameStatus) ?? 0)
                        }
                        
                        if hasLive {
                            let result = try await searchClient.fetchLeagueSchedule(
                                entity: entity,
                                season: season,
                                yearMonth: String(yearMonth),
                                day: day
                            )
                            
                            if case .tennisLeagueSchedule(_, let displayModel) = result.data {
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
                    newFilteredGames[state.baseSchedule.selectedDayIndex] = state.baseSchedule.displayModel.games.filter { game in
                        CalendarUtil.isSameDate(stringDate: game.date, selectedYearMonth: state.baseSchedule.selectedYearMonth, selectedDay: state.baseSchedule.selectedDayIndex + 1)
                    }
                    
                    state.filteredGames = newFilteredGames
                }
                
                return .none
                
            case .updateDisplayModelGames(let games):
                let gamesById = Dictionary(uniqueKeysWithValues: games.map { ($0.gameId, $0) })

                state.baseSchedule.displayModel.games = state.baseSchedule.displayModel.games.map { gamesById[$0.gameId] ?? $0 }
                
                return .send(.updateFilteredGames)
                
            case .baseSchedule(.selectRelatedLeague(let index)):
                let displayModel = state.baseSchedule.displayModel
                
                return .run { send in
                    if let leagueId = displayModel.sortedRelatedLeagues?[index] {
                        await send(.updateDisplayDataState(fetchState: .fetching), animation: AnimationConstants.AnimationType.defaultAnimation)
                        
                        do {
                            let leagueName = StringConstants.Tennis.leagueNameStr(leagueId: leagueId)
                            let entity = EntityInfo(
                                entityId: leagueId,
                                entityName: leagueName,
                                category: "tennis",
                                entityType: "league",
                                leagueId: leagueId,
                                teamId: nil,
                                playerId: nil
                            )
                            
                            let result = try await searchClient.fetchLeagueSchedule(entity: entity, season: displayModel.season, yearMonth: nil)
                            
                            if case let .tennisLeagueSchedule(_, displayModel) = result.data {
                                await send(.setDisplayModel(displayModel: displayModel))
                                await send(.baseSchedule(.initData))
                            }
                        } catch {
                            await send(.updateDisplayDataState(fetchState: .failure("데이터를 불러오는데 실패하였습니다.")), animation: AnimationConstants.AnimationType.defaultAnimation)
                            print("\(error)")
                        }
                    }
                }
                
            case .baseSchedule:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
