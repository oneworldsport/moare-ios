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

struct TranslatedNameProviderKey: DependencyKey {
    static let liveValue = TranslatedNameProvider()
}

struct TrendingKeywordsClient {
    var wait: () async throws -> TrendingKeywords
}

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
