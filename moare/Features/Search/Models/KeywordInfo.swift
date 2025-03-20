//
//  KeywordInfo.swift
//  moare
//
//  Created by Mohwa Yoon on 2/18/25.
//

import Foundation

struct KeywordInfo: Codable {
    let keyword: String
    var weight: Int? = nil
    let keywords: [Keyword]
    let entities: [EntityInfo]
}
