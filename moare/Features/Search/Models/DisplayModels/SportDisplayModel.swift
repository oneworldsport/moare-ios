//
//  SportDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 5/22/25.
//

protocol SportDisplayModel: Equatable {
    var leagueId: Int { get }
    var keywords: [Keyword] { get }
    var entityInfo: [EntityInfo] { get }
    var season: Int { get }
}

// TODO: 나중에 현재 파일 이름을 변경하던가 or 아래 protocol을 다른곳으로 이동 
protocol Rankable {
    var displayRank: Int { get set }
}
