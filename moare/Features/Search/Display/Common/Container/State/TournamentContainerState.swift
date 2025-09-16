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
    let gameListDic: [String: [[GameForSchedule<T>]]]
}

struct TournamentDrawContainerState<T: Decodable & Equatable> {
    let leagueId: Int
    let gameListDic: [String: [[GameForSchedule<T>]]]
    let teamNameDic: [String: String]
}

//struct TournamentDrawGameState {
//    let homeTeamId: Int
//    let awayTeamId: Int
//    let homeTeamScore: Int
//    let awayTeamScore: Int
//    let gameStatus: String
//    let date: String
//}
