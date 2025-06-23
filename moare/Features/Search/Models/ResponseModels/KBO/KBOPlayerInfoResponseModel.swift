//
//  KBOPlayerInfoResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOPlayerInfoResponseModel: Decodable, Equatable {
    let info: KBOPlayer?
    let lastGame: KBOGame?
    let nextGame: KBOGame?
}
