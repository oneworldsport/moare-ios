//
//  KBOPlayerInfoResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBPlayerInfoResponseModel: Decodable, Equatable {
    let info: MLBPlayer?
    let lastGame: MLBGame?
    let nextGame: MLBGame?
}
