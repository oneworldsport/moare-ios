//
//  NbaModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/11/24.
//

import Foundation

struct NBAPlayerInfoResponseModel: Decodable, Equatable {
    let info: NBAPlayer?
    let lastGame: NBAGame?
    let nextGame: NBAGame?
}
