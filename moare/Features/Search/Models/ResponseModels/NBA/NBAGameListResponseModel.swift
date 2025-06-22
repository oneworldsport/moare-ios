//
//  NBAGameListResponseModel.swift
//  moare
//
//  Created by Mohwa Yoon on 5/31/25.
//

struct NBAGameListResponseModel: Decodable, Equatable {
    let scheduledMonths: [String]?
    let schedule: [NBAGame]
}
