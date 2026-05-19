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
}
