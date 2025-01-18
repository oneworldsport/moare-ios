//
//  AutoComplete.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/13/25.
//

import Foundation

struct AutoComplete: Decodable, Equatable {
    let word: String
    let weight: Int
}
