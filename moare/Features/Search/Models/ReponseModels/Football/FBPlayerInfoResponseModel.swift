//
//  FootballPlayerInfoResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/4/24.
//

import Foundation

struct FBPlayerInfoResponseModel: Decodable, Equatable {
    let info: FBPlayer?
    let lastGame: FBGame?
    let nextGame: FBGame?
}
