//
//  NBALeagueScheduleStoreTests.swift
//  moare
//
//  Created by Mohwa Yoon on 5/20/26.
//

import Testing
import ComposableArchitecture
@testable import moare
import Foundation

@MainActor
@Suite("NBALeagueScheduleStore Tests")
struct NBALeagueScheduleStoreTests {
    
    @Test("initData league 일정이면 첫 경기 날짜 기준으로 기본 yearMonth를 설정한다")
    func initDataLeagueType() async throws {
        let displayModel = try makeNBALeagueScheduleDisplayModel()
        let firstGame = try #require(displayModel.games.first)
        
        let defaultYearMonth = CalendarUtil.formatDate(
            date: firstGame.date,
            outputFormatType: .yearMonth
        )
        
        let defaultYearMonthIndex = try #require(
            displayModel.yearMonthList.firstIndex(of: defaultYearMonth)
        )


        let store = TestStore(initialState: NBALeagueScheduleStore.State(displayModel: displayModel)) {
            NBALeagueScheduleStore()
        } withDependencies: {
            $0.translatedNameProvider.getDictionary = { category in
//                #expect(category == Constants.Keys.nbaTeamDic)
                return [:]
            }
        }

        await store.send(.baseSchedule(.initData)) {
            $0.filteredGames = [:]
            $0.gameResultOpenedStateList = [:]
            $0.baseSchedule.yearMonthList = displayModel.yearMonthList
        }
        
        await store.receive(.baseSchedule(.setDefaultYearMonth(date: firstGame.date)))
        
        await store.receive(
            .baseSchedule(
                .selectYearMonth(
                    yearMonth: defaultYearMonth,
                    selectedIndex: defaultYearMonthIndex,
                    isInit: true
                )
            )
        ) {
            $0.baseSchedule.selectedYearMonth = defaultYearMonth
            $0.baseSchedule.selectedYearMonthIndex = defaultYearMonthIndex
            $0.baseSchedule.selectedMonth = Int(defaultYearMonth.components(separatedBy: "/").last ?? "0") ?? 0
        }
        
        store.exhaustivity = .off
        
        // NOTE: closure가 없으면 다음과 같은 의미 -> "이 액션을 받았고 state는 그대로여야 한다"
//        await store.receive(.setDays(isInit: true))
        
//        await store.receive(.baseSchedule(.initNameDictionary([:])))
//        await store.receive(.baseSchedule(.initNameDictionary([:]))) {
//            $0.baseSchedule.teamNameDictionary = [:]
//        }
        
//        await store.skipReceivedActions()
    }
    
    @Test("setDays는 선택된 월의 경기 날짜 목록과 필터링된 경기를 설정한다")
    func setDays() async throws {
        // TODO: games가 작은 mock데이터 만들어서 검증하게 개선해야함
        let displayModel = try makeNBALeagueScheduleDisplayModel()
        
        var initialState = NBALeagueScheduleStore.State(displayModel: displayModel)
        initialState.baseSchedule.selectedYearMonth = "25/06"
        
        let store = TestStore(initialState: initialState) {
            NBALeagueScheduleStore()
        }
        
        var expectedDays = CalendarUtil.getDaysInMonth(year: 2025, month: 6)
        var expectedFilteredGames: [Int: [NBAGameForSchedule]] = [:]
        var expectedGameResultOpenedStateList: [String: Bool] = [:]
        
        for index in expectedDays.indices {
            let day = expectedDays[index]
            
            let games = displayModel.games.filter { game in
                CalendarUtil.isSameDate(
                    stringDate: game.date,
                    selectedYearMonth: "25/06",
                    selectedDay: day.day
                )
            }
            
            expectedFilteredGames[index] = games
            
            if games.isEmpty {
                expectedDays[index].isDataEmpty = true
            }
            
            for game in games {
                expectedGameResultOpenedStateList[game.itemKey] = false
            }
        }
        
        let defaultDay = try #require(
            CalendarUtil.getDefaultDay(
                yearMonth: "25/06",
                dayList: expectedDays
            )
        )

        await store.send(.setDays(isInit: true)) {
            $0.gameResultOpenedStateList = expectedGameResultOpenedStateList
            $0.baseSchedule.days = expectedDays
            $0.baseSchedule.selectedDay = defaultDay.1
            $0.baseSchedule.selectedDayIndex = defaultDay.0
            $0.filteredGames = expectedFilteredGames
        }
        
        await store.receive(.updateDisplayDataState(fetchState: .success)) {
            $0.baseSchedule.displayDataState = .success
        }
    }
    
    @Test("updateResultOpenedState 호출 시 해당 game itemKey의 열림 상태를 변경한다")
    func updateResultOpenedState() async throws {
        let displayModel = try makeNBALeagueScheduleDisplayModel()
        let game = try #require(displayModel.games.first)

        let store = TestStore(initialState: NBALeagueScheduleStore.State(displayModel: displayModel)) {
            NBALeagueScheduleStore()
        }

        await store.send(.updateResultOpenedState(itemKey: game.itemKey, isOpened: true)) {
            $0.gameResultOpenedStateList[game.itemKey] = true
        }
    }
    
    @Test("toggleAllResult 호출 시 모든 경기 결과 열림 상태를 반전한다")
    func toggleAllResult() async throws {
        let displayModel = try makeNBALeagueScheduleDisplayModel()
        let games = Array(displayModel.games.prefix(2))

        var initialState = NBALeagueScheduleStore.State(displayModel: displayModel)
        initialState.gameResultOpenedStateList = games.reduce(into: [String: Bool]()) { dict, game in
            dict[game.itemKey] = false
        }

        let store = TestStore(initialState: initialState) {
            NBALeagueScheduleStore()
        }

        await store.send(.toggleAllResult) {
            $0.baseSchedule.isAllResultOpened = true
            $0.gameResultOpenedStateList = games.reduce(into: [String: Bool]()) { dict, game in
                dict[game.itemKey] = true
            }
        }
    }
    
    @Test("selectGame 성공 시 gameStats delegate를 보내고 해당 경기 결과를 open 상태로 변경한다")
    func selectGameSuccess() async throws {
        let displayModel = try makeNBALeagueScheduleDisplayModel()
        let game = try #require(displayModel.games.first)

        let gameStatsDataModel = try makeMockDataModel(fileName: "nba_game_stats")

        let store = TestStore(initialState: NBALeagueScheduleStore.State(displayModel: displayModel)) {
            NBALeagueScheduleStore()
        } withDependencies: {
            $0.searchClient.fetchById = { season, category, date, dataType, leagueId, id in
                #expect(season == displayModel.season)
                #expect(category == "basketball")
                #expect(date == game.date)
                #expect(dataType == "basketball_game_stats")
                #expect(leagueId == displayModel.leagueId)
                #expect(id == game.gameId)

                return gameStatsDataModel
            }
        }

        await store.send(.selectGame(game: game))

        await store.receive(\.delegate)

        await store.receive(\.updateResultOpenedState) {
            $0.gameResultOpenedStateList[game.itemKey] = true
        }
    }
    
    private func makeMockDataModel(fileName: String) throws -> DataModel {
        let url = try #require(
            Bundle(for: BundleToken.self).url(
                forResource: fileName,
                withExtension: "json"
            )
        )

        let data = try Data(contentsOf: url)
        let raw = try JSONDecoder().decode(RawDataModel.self, from: data)

        return try DataModel.from(raw: raw)
    }
    
    private func makeNBALeagueScheduleDisplayModel(
        fileName: String = "nba_league_schedule"
    ) throws -> NBALeagueScheduleDisplayModel {
        let dataModel = try makeMockDataModel(fileName: fileName)

        guard case let .nbaLeagueSchedule(_, displayModel) = dataModel.data else {
            Issue.record("mock json이 nbaLeagueSchedule 타입이 아님")
            throw TestError.invalidMockData
        }

        return displayModel
    }
    
    private final class BundleToken {}
    
    private enum TestError: Error {
        case invalidMockData
    }
}
