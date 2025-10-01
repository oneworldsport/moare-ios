//
//  Dependency.swift
//  moare
//
//  Created by Mohwa Yoon on 4/15/25.
//

import ComposableArchitecture

extension DependencyValues {
    var trendingKeywordsClient: TrendingKeywordsClient {
        get { self[TrendingKeywordsKey.self] }
        set { self[TrendingKeywordsKey.self] = newValue }
    }
    
    var trieTupleClient: TrieTupleClient {
        get { self[TrieTupleKey.self] }
        set { self[TrieTupleKey.self] = newValue }
    }
    
    var noticeListClient: NoticeListClient {
        get { self[NoticeListKey.self] }
        set { self[NoticeListKey.self] = newValue }
    }
    
    var tournamentTeamsClient: TournamentTeamsClient {
        get { self[TournamentTeamsKey.self] }
        set { self[TournamentTeamsKey.self] = newValue }
    }
    
    var translatedNameProvider: TranslatedNameProvider {
        get { self[TranslatedNameProviderKey.self] }
        set { self[TranslatedNameProviderKey.self] = newValue }
    }
}

private enum TrendingKeywordsKey: DependencyKey {
    static let liveValue = TrendingKeywordsClient(
        wait: {
            try await AWSManager.shared.waitForTrendingKeywords()
        }
    )
}

private enum TrieTupleKey: DependencyKey {
    static let liveValue = TrieTupleClient(
        wait: {
            try await AWSManager.shared.waitForTrieTuple()
        }
    )
}

private enum NoticeListKey: DependencyKey {
    static let liveValue = NoticeListClient(
        wait: {
            try await AWSManager.shared.waitForNoticeList()
        }
    )
}

private enum TournamentTeamsKey: DependencyKey {
    static let liveValue = TournamentTeamsClient(
        wait: {
            try await AWSManager.shared.waitForTournamentTeams()
        }
    )
}

struct TranslatedNameProviderKey: DependencyKey {
    static let liveValue = TranslatedNameProvider()
}

struct TrendingKeywordsClient {
    var wait: () async throws -> TrendingKeywords
}

struct NoticeListClient {
    var wait: () async throws -> [NoticeModel]
}

struct TrieTupleClient {
    var wait: () async throws -> (Trie, [KeywordInfo])
}

struct TournamentTeamsClient {
    var wait: () async throws -> [String: [Int?]]
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
