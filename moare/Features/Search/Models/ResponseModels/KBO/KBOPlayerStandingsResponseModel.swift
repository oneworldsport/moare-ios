//
//  KBOPlayerStandingsResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct KBOPlayerStandingsResponseModel: Decodable, Equatable {
    let standings: [KBOPlayer]
}
