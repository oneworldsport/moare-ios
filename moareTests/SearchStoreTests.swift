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
        let keyword = KeywordInfo(
            keyword: "NBA 일정",
            weight: 100,
            keywords: nil,
            entities: []
        )
        
        let store = TestStore(initialState: SearchStore.State()) {
            SearchStore()
        }
        
        await store.send(.initTrendingKeywords([keyword])) {
            $0.trendingKeywords["NBA 일정"] = keyword
            $0.trendingKeywordList = ["NBA 일정"]
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
