//
//  KBOPlayerStandingsResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBPlayerStandingsResponseModel: Decodable, Equatable {
    let standings: [MLBPlayer]
}
