//
//  GameForSchedule.swift
//  moare
//
//  Created by Mohwa Yoon on 5/31/25.
//

struct GameForSchedule<T: Decodable & Equatable>: Decodable, Equatable {
    private let _itemKey: String?
    private let _homeTeamId: Int?
    private let _awayTeamId: Int?
    private let _homeTeamScore: Int?
    private let _awayTeamScore: Int?
    private let _gameStatus: String?
    let isHomeTopSeed: Bool?
    let gameInfo: T?

    var itemKey: String { _itemKey ?? "" }
    var homeTeamId: Int { _homeTeamId ?? 0 }
    var awayTeamId: Int { _awayTeamId ?? 0 }
    var homeTeamScore: Int { _homeTeamScore ?? 0 }
    var awayTeamScore: Int { _awayTeamScore ?? 0 }
    var gameStatus: String { _gameStatus ?? "" }
    
    var gameId: String { String(_itemKey?.split(separator: "#").last ?? "") }
    var date: String { String(_itemKey?.split(separator: "#").first ?? "") + "+09:00" } // NOTE: KST 표준 시간 표시 추가

    private enum CodingKeys: String, CodingKey {
        case _itemKey = "itemKey"
        case _homeTeamId = "homeTeamId"
        case _awayTeamId = "awayTeamId"
        case _homeTeamScore = "homeTeamScore"
        case _awayTeamScore = "awayTeamScore"
        case _gameStatus = "gameStatus"
        case isHomeTopSeed, gameInfo
    }
    
    init(
        itemKey: String? = nil,
        homeTeamId: Int? = nil,
        awayTeamId: Int? = nil,
        homeTeamScore: Int? = nil,
        awayTeamScore: Int? = nil,
        gameStatus: String? = nil,
        isHomeTopSeed: Bool? = nil,
        gameInfo: T? = nil
    ) {
        self._itemKey = itemKey
        self._homeTeamId = homeTeamId
        self._awayTeamId = awayTeamId
        self._homeTeamScore = homeTeamScore
        self._awayTeamScore = awayTeamScore
        self._gameStatus = gameStatus
        self.isHomeTopSeed = isHomeTopSeed
        self.gameInfo = gameInfo
    }
}

