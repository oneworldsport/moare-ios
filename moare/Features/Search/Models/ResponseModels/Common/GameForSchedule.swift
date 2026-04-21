//
//  GameForSchedule.swift
//  moare
//
//  Created by Mohwa Yoon on 5/31/25.
//

import SwiftUI

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
    
    // NOTE: nil 값이 필요한 프로퍼티는 따로 optional getter를 추가. private을 제거하고 _property를 그대로 사용하는건 비추.
    // TODO: 다른곳도 해당 방식으로 리팩토링 필요
    var homeTeamIdOrNil: Int? { _homeTeamId }
    var awayTeamIdOrNil: Int? { _awayTeamId }
    
    var gameId: String { String(_itemKey?.split(separator: "#").last ?? "") }
    var date: String { String(_itemKey?.split(separator: "#").first ?? "") + "+09:00" } // NOTE: KST 표준 시간 표시 추가
    var parsedDate: Date? {
        CalendarUtil.isoFormatter.date(from: date)
    }

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

