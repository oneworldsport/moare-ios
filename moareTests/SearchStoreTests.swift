//
//  SearchStoreTests.swift
//  moare
//
//  Created by Mohwa Yoon on 5/17/26.
//

import Testing
import ComposableArchitecture
@testable import moare
import Foundation

@MainActor
@Suite("SearchStore Tests")
struct SearchStoreTests {
    
    @Test("firstOpen 액션은 firstOpened를 true로 변경한다")
    func firstOpen() async {
        let store = TestStore(initialState: SearchStore.State()) {
            SearchStore()
        }
        
        await store.send(.firstOpen) {
            $0.firstOpened = true
        }
    }
    
    @Test("updateTextField는 query를 변경한다")
    func updateTextFieldWithoutAutoComplete() async {
        let store = TestStore(initialState: SearchStore.State()) {
            SearchStore()
        }
        
        await store.send(.updateTextField("NBA", false)) {
            $0.query = "NBA"
        }
    }
    
    @Test("빈 검색어를 입력하면 자동완성 리스트를 비운다")
    func updateTextFieldEmptyClearsAutoCompleteList() async {
        var initialState = SearchStore.State()
        initialState.query = "NBA"
        initialState.autoCompleteList = ["NBA 일정", "NBA 순위"]
        
        let store = TestStore(initialState: initialState) {
            SearchStore()
        }
        
        await store.send(.updateTextField("")) {
            $0.query = ""
            $0.autoCompleteList = []
        }
    }
    
    @Test("initTrendingKeywords는 트렌드 검색어 상태를 초기화한다")
    func initTrendingKeywords() async {
        let store = TestStore(initialState: SearchStore.State()) {
            SearchStore()
        }
        
        await store.send(.initTrendingKeywords(["NBA 일정"])) {
            $0.trendingKeywordList = ["NBA 일정"]
        }
    }
    
    @Test("getLeagueKeywords 성공 시 leagueKeywords를 업데이트한다")
    func getLeagueKeywordsSuccess() async {
        let clock = TestClock()
        
        let expected = LeagueKeywords(
            live: [
                KeywordInfo(
                    keyword: "NBA",
                    keywords: nil,
                    entities: []
                )
            ],
            recent: [
                KeywordInfo(
                    keyword: "MLB",
                    keywords: nil,
                    entities: []
                )
            ]
        )
        
        let store = TestStore(initialState: SearchStore.State()) {
            SearchStore()
        } withDependencies: {
            $0.continuousClock = clock
            $0.keywordsClient.fetchLeagueKeywords = {
                expected
            }
        }
        
        await store.send(.getLeagueKeywords)
        
        await clock.advance(by: .seconds(1.8))
        
//        await store.receive(.getLeagueKeywordsSuccess(expected)) {
//            $0.leagueKeywords = expected
//        }
        await store.receive(\.getLeagueKeywordsSuccess) {
            $0.leagueKeywords = expected
        }
    }
    
    @Test("getLeagueKeywords 실패 시 leagueKeywords를 업데이트하지 않는다")
    func getLeagueKeywordsFailure() async {
        enum TestError: Error {
            case failed
        }

        let store = TestStore(initialState: SearchStore.State()) {
            SearchStore()
        } withDependencies: {
            $0.keywordsClient.fetchLeagueKeywords = {
                throw TestError.failed
            }
        }

        await store.send(.getLeagueKeywords)
    }
    
    @Test("query 변경 시 자동완성 결과를 갱신한다")
    func updateAutocomplete() async {
        var initialState = SearchStore.State()
        initialState.query = "손"
        
        let store = TestStore(initialState: initialState) {
            SearchStore()
        } withDependencies: {
            $0.autoCompleteClient.search = { query in
                #expect(query == "손")
                return ["손흥민", "손흥민 경기"]
            }
        }

        await store.send(.updateAutoCompleteList)

//        await store.receive(.updateAutoCompleteListResponse(["손흥민", "손흥민 골"])) {
//            $0.autoCompleteList = ["손흥민", "손흥민 골"]
//        }
        await store.receive(\.updateAutoCompleteListResponse) {
            $0.autoCompleteList = ["손흥민", "손흥민 경기"]
        }
    }
    
    @Test("performSearch query 검색 실패 시 searchDataState를 failure로 변경한다")
    func performSearchQueryFailure() async {
        var initialState = SearchStore.State()
        initialState.query = "NBA"

        let store = TestStore(initialState: initialState) {
            SearchStore()
        } withDependencies: {
            $0.searchClient.fetchDataByQuery = { query in
                #expect(query == "NBA")
                throw NSError(domain: "TestError", code: 1)
            }

            $0.searchClient.fetchDataByKeyword = { _, _ in
                Issue.record("query 검색에서는 fetchDataByKeyword가 호출되면 안 됨")
                throw NSError(domain: "Unexpected", code: 1)
            }
        }

        await store.send(.performSearch(searchType: .query, aniDuration: 0)) {
            $0.searchState = true
        }

//        await store.receive(.updateSearchDataState(.failure("검색 결과가 없습니다."))) {
//            $0.searchDataState = .failure("검색 결과가 없습니다.")
//        }
        
        await store.receive(\.updateSearchDataState) {
            $0.searchDataState = .fetching
        }
        
        await store.receive(\.updateSearchDataState) {
            $0.searchDataState = .failure("검색 결과가 없습니다.")
        }
    }
    
    @Test("performSearch query 검색 성공 시 검색 결과 화면으로 push한다")
    func performSearchQuerySuccess() async {
        let mockDataModel = try! makeMockDataModel(fileName: "nba_league_schedule")
        
        var initialState = SearchStore.State()
        initialState.query = "NBA"
        
        let store = TestStore(initialState: initialState) {
            SearchStore()
        } withDependencies: {
            $0.searchClient.fetchDataByQuery = { query in
                #expect(query == "NBA")
                return mockDataModel
            }
            
            $0.searchClient.fetchDataByKeyword = { _, _ in
                Issue.record("query 검색에서는 fetchDataByKeyword가 호출되면 안 됨")
                return mockDataModel
            }
        }
        
        await store.send(.performSearch(searchType: .query, aniDuration: 0)) {
            $0.searchState = true
        }
        
        await store.receive(\.updateSearchDataState) {
            $0.searchDataState = .success
        }
        
        await store.receive(\.searchResultsReceived) {
            $0.resultVisibleState = true
        }
        
//        await store.receive(.delegate(.push(model: mockDataModel.data)))
        await store.receive(\.delegate)
    }
    
    @Test("performSearch trendingKeyword 검색은 trendingKeywordsClient에서 KeywordInfo를 찾아 검색한다")
    func performSearchTrendingKeywordSuccess() async {
        let mockKeyword = KeywordInfo(
            keyword: "NBA 일정",
            weight: 100,
            keywords: [],
            entities: []
        )

        let mockDataModel = try! makeMockDataModel(fileName: "nba_league_schedule")

        var initialState = SearchStore.State()
        initialState.query = "NBA 일정"

        let store = TestStore(initialState: initialState) {
            SearchStore()
        } withDependencies: {
            $0.searchClient.fetchDataByQuery = { _ in
                Issue.record("trendingKeyword 검색에서는 fetchDataByQuery가 호출되면 안 됨")
                return mockDataModel
            }
            
            $0.trendingKeywordsClient.keywordInfo = { keyword in
                #expect(keyword == "NBA 일정")
                return mockKeyword
            }
            
            $0.searchClient.fetchDataByKeyword = { keywordInfo, season in
                #expect(keywordInfo.keyword == "NBA 일정")
                #expect(season == nil)
                return mockDataModel
            }
        }

        await store.send(.performSearch(searchType: .trendingKeyword, aniDuration: 0)) {
            $0.searchState = true
        }
        
        await store.receive(\.updateSearchDataState) {
            $0.searchDataState = .success
        }
        
        await store.receive(\.searchResultsReceived) {
            $0.resultVisibleState = true
        }
        
//        await store.receive(.delegate(.push(model: mockDataModel.data)))
        await store.receive(\.delegate)
    }
    
    @Test("performSearch autoComplete 검색은 autoCompleteClient에서 KeywordInfo를 찾아 검색한다")
    func performSearchAutoCompleteSuccess() async {
        let mockKeyword = KeywordInfo(
            keyword: "NBA 일정",
            weight: 100,
            keywords: [],
            entities: []
        )

        let mockDataModel = try! makeMockDataModel(fileName: "nba_league_schedule")

        var initialState = SearchStore.State()
        initialState.query = "NBA 일정"

        let store = TestStore(initialState: initialState) {
            SearchStore()
        } withDependencies: {
            $0.searchClient.fetchDataByQuery = { _ in
                Issue.record("trendingKeyword 검색에서는 fetchDataByQuery가 호출되면 안 됨")
                return mockDataModel
            }
            
            $0.autoCompleteClient.keywordInfo = { keyword in
                #expect(keyword == "NBA 일정")
                return mockKeyword
            }
            
            $0.searchClient.fetchDataByKeyword = { keywordInfo, season in
                #expect(keywordInfo.keyword == "NBA 일정")
                #expect(keywordInfo.weight == nil)
                #expect(season == nil)
                return mockDataModel
            }
        }

        await store.send(.performSearch(searchType: .autoComplete, aniDuration: 0)) {
            $0.searchState = true
        }

        await store.receive(\.updateSearchDataState) {
            $0.searchDataState = .success
        }
        
        await store.receive(\.searchResultsReceived) {
            $0.resultVisibleState = true
        }
        
//        await store.receive(.delegate(.push(model: mockDataModel.data)))
        await store.receive(\.delegate)
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
    
    private final class BundleToken {}
}
