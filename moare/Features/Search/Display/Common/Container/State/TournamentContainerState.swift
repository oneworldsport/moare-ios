//
//  TournamentContainerState.swift
//  moare
//
//  Created by Mohwa Yoon on 9/16/25.
//

//struct TournamentContainerState<T: Decodable & Equatable> {
//    let gameListDic: [String: [[GameForSchedule<T>]]]
//}

struct TournamentBracketContainerState<T: Decodable & Equatable> {
    let leagueId: Int
    let teamNameDic: [String: String]
    let gameListTuple: [(title: String, gameList: [[GameForSchedule<T>]?])]
    let isConference: Bool
    let isSeries: Bool
}

struct TournamentDrawContainerState<T: Decodable & Equatable> {
    let leagueId: Int
    let teamNameDic: [String: String]
    let gameListTuple: [(title: String, gameList: [[GameForSchedule<T>]])]
    let isSeries: Bool
}

struct TournamentContainerAction<T: Decodable & Equatable> {
    var selectSeries: (([GameForSchedule<T>]) -> Void)? = nil
}
