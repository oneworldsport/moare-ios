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
    // TODO: seedIdTupleList사용 안되므로 다른 사용하는곳 리팩토링 필요. DB에 isHomeTopSeed작업이 되어있어야함.
    var seedIdTupleList: [[(topSeedId: Int?, lowerSeedId: Int?)]] = [] // Bracket에 한 시리즈 아이템에서 위에 표시되는 팀과 아래 표시되는 팀 id 정보. gameListTuple의 gameList와 동일한 인덱스에 일치하는 정보가 있음.
    let isConference: Bool
    let isSeries: Bool
}

struct TournamentDrawContainerState<T: Decodable & Equatable> {
    let leagueId: Int
    let teamNameDic: [String: String]
    let gameListTuple: [(title: String, gameList: [[GameForSchedule<T>]?])]
    let isSeries: Bool
}

struct TournamentContainerAction<T: Decodable & Equatable> {
    var selectSeries: (([GameForSchedule<T>]) -> Void)? = nil
    var selectGame: ((GameForSchedule<T>) -> Void)? = nil
}
