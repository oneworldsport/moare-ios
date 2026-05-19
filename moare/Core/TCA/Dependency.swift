//
//  Dependency.swift
//  moare
//
//  Created by Mohwa Yoon on 4/15/25.
//

import ComposableArchitecture
import Collections

extension DependencyValues {
    var trendingKeywordsClient: TrendingKeywordsClient {
        get { self[TrendingKeywordsClient.self] }
        set { self[TrendingKeywordsClient.self] = newValue }
    }
    
    var autoCompleteClient: AutoCompleteClient {
        get { self[AutoCompleteClient.self] }
        set { self[AutoCompleteClient.self] = newValue }
    }
    
    var noticeListClient: NoticeListClient {
        get { self[NoticeListClient.self] }
        set { self[NoticeListClient.self] = newValue }
    }
    
    var tournamentTeamsClient: TournamentTeamsClient {
        get { self[TournamentTeamsClient.self] }
        set { self[TournamentTeamsClient.self] = newValue }
    }
    
    var translatedNameProvider: TranslatedNameProvider {
        get { self[TranslatedNameProviderKey.self] }
        set { self[TranslatedNameProviderKey.self] = newValue }
    }
    
    var searchClient: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
    
    var keywordsClient: KeywordsClient {
        get { self[KeywordsClient.self] }
        set { self[KeywordsClient.self] = newValue }
    }
}

struct TranslatedNameProviderKey: DependencyKey {
    static let liveValue = TranslatedNameProvider()
}

struct TrendingKeywordsClient {
    var load: @Sendable () async throws -> [String]
    var keywordInfo: @Sendable (_ keyword: String) async throws -> KeywordInfo?
}

extension TrendingKeywordsClient: DependencyKey {
    static let liveValue: Self = {
        let storage = TrendingKeywordsStorage()
        
        return Self(
            load: {
                try await storage.load()
            },
            keywordInfo: { keyword in
                try await storage.keywordInfo(keyword: keyword)
            }
        )
    }()
    
    static let testValue = Self(
        load: unimplemented("TrendingKeywordsClient.load"),
        keywordInfo: unimplemented("TrendingKeywordsClient.keywordInfo"),
    )
}

struct NoticeListClient {
    var wait: @Sendable () async throws -> [NoticeModel]
}

extension NoticeListClient: DependencyKey {
    static let liveValue = Self(
        wait: {
            try await AWSManager.shared.waitForNoticeList()
        }
    )
}

struct TournamentTeamsClient {
    var wait: @Sendable () async throws -> [String: [Int?]]
}

extension TournamentTeamsClient: DependencyKey {
    static let liveValue = Self(
        wait: {
            try await AWSManager.shared.waitForTournamentTeams()
        }
    )
}

struct AutoCompleteClient {
    var load: @Sendable () async throws -> Void
    var search: @Sendable (_ query: String) async throws -> [String]
    var keywordInfo: @Sendable (_ keyword: String) async throws -> KeywordInfo?
}

extension AutoCompleteClient: DependencyKey {
    static let liveValue: Self = {
        let storage = AutoCompleteStorage()
        
        return Self(
            load: {
                try await storage.load()
            },
            search: { query in
                try await storage.search(query: query)
            },
            keywordInfo: { keyword in
                try await storage.keywordInfo(keyword: keyword)
            }
        )
    }()
}

// TODO: class 이름 고민
class TranslatedNameProvider {
    private var dictionaryMap: [String: [String: String]] = [:]
    
    func setDictionary(category: String, nameMap: [String: String]) {
        dictionaryMap[category.lowercased()] = nameMap
    }
    
    func getDictionary(category: String) -> [String: String] {
        dictionaryMap[category.lowercased()] ?? [:]
    }
    
    func getName(category: String, name: String) -> String {
        dictionaryMap[category.lowercased()]?[name.lowercased()] ?? name
    }
}

private actor AutoCompleteStorage {
    private var trie: Trie?
    private var keywordInfos: [KeywordInfo] = []
    private var keywordInfoByKeyword: [String: KeywordInfo] = [:]

    func load() async throws {
        let trieTuple = try await AWSManager.shared.waitForTrieTuple()
        let trie = trieTuple.0
        let keywordInfos = trieTuple.1

        self.trie = trie
        self.keywordInfos = keywordInfos
        self.keywordInfoByKeyword = Dictionary(
            uniqueKeysWithValues: keywordInfos.map { ($0.keyword, $0) }
        )
    }

    func search(query: String) async throws -> [String] {
        if trie == nil {
            try await load()
        }

        return trie?.search(prefix: query) ?? []
    }

    func keywordInfo(keyword: String) async throws -> KeywordInfo? {
        if keywordInfoByKeyword.isEmpty {
            try await load()
        }

        return keywordInfoByKeyword[keyword]
    }
}

private actor TrendingKeywordsStorage {
    private var keywordInfoByKeyword: OrderedDictionary<String, KeywordInfo> = [:]

    func load() async throws -> [String] {
        let trendingKeywords = try await AWSManager.shared.waitForTrendingKeywords()
        let keywords = trendingKeywords.keywords
        
        // 중복 키워드는 덮어쓰기
        var dict = OrderedDictionary<String, KeywordInfo>()
        for info in keywords {
            dict[info.keyword] = info
        }
        keywordInfoByKeyword = dict
        
        // 중복 포함 + 순서 유지
        return keywords.map { $0.keyword }
    }

    func keywordInfo(keyword: String) async throws -> KeywordInfo? {
        if keywordInfoByKeyword.isEmpty {
            _ = try await load()
        }

        return keywordInfoByKeyword[keyword]
    }
}
