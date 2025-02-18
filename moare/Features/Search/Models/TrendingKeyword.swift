//
//  TrendingKeyword.swift
//  moare
//
//  Created by Mohwa Yoon on 2/18/25.
//

import Foundation

struct TrendingKeyword: Codable {
    let keyword: String
    let keywords: [Keyword]
    let entities: [EntityInfo]
}
