//
//  KeywordInfo.swift
//  moare
//
//  Created by Mohwa Yoon on 2/18/25.
//

import Foundation

struct KeywordInfo: Codable, Equatable {
    let keyword: String
    var weight: Int? = nil
    let keywords: [Keyword]?
    let entities: [EntityInfo]
}

struct TrendingKeywords: Codable, Equatable {
    let date: String
    let keywords: [KeywordInfo]
}

struct LeagueKeywords: Codable, Equatable {
    let live: [KeywordInfo]
    let recent: [KeywordInfo]
}
