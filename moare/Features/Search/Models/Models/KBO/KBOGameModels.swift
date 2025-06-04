//
//  KBOGameModels.swift
//  moare
//
//  Created by Mohwa Yoon on 6/2/25.
//

import Foundation

struct KBOGame: Decodable, Equatable {
    let gameInfo: KBOGameInfo?
    let lineScore: KBOGameLineScoreInfo
    let lineup: KBOGameLineupInfo
}

struct KBOGameInfo: Decodable, Equatable {
    private let _awayTeamId: String?
    private let _date: String?
    private let _gameId: String?
    private let _homeTeamId: String?
    private let _remark: String?

    var awayTeamId: String { _awayTeamId ?? "" }
    var date: String { _date ?? "" }
    var gameId: String { _gameId ?? "" }
    var homeTeamId: String { _homeTeamId ?? "" }
    var remark: String { _remark ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _awayTeamId = "awayTeamId"
        case _date = "date"
        case _gameId = "gameId"
        case _homeTeamId = "homeTeamId"
        case _remark = "remark"
    }
}

struct KBOGameLineScoreInfo: Decodable, Equatable {
    let away: KBOGameLineScore
    let home: KBOGameLineScore
}

struct KBOGameLineScore: Decodable, Equatable {
    private let _inning1: String?
    private let _inning2: String?
    private let _inning3: String?
    private let _inning4: String?
    private let _inning5: String?
    private let _inning6: String?
    private let _inning7: String?
    private let _inning8: String?
    private let _inning9: String?
    private let _inning10: String?
    private let _inning11: String?
    private let _inning12: String?
    private let _inning13: String?
    private let _inning14: String?
    private let _inning15: String?
    private let _b: String?
    private let _e: String?
    private let _h: String?
    private let _r: String?
    private let _teamName: String?

    var inning1: String { _inning1 ?? "" }
    var inning2: String { _inning2 ?? "" }
    var inning3: String { _inning3 ?? "" }
    var inning4: String { _inning4 ?? "" }
    var inning5: String { _inning5 ?? "" }
    var inning6: String { _inning6 ?? "" }
    var inning7: String { _inning7 ?? "" }
    var inning8: String { _inning8 ?? "" }
    var inning9: String { _inning9 ?? "" }
    var inning10: String { _inning10 ?? "" }
    var inning11: String { _inning11 ?? "" }
    var inning12: String { _inning12 ?? "" }
    var inning13: String { _inning13 ?? "" }
    var inning14: String { _inning14 ?? "" }
    var inning15: String { _inning15 ?? "" }
    var b: String { _b ?? "" }
    var e: String { _e ?? "" }
    var h: String { _h ?? "" }
    var r: String { _r ?? "" }
    var teamName: String { _teamName ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _inning1 = "1"
        case _inning2 = "2"
        case _inning3 = "3"
        case _inning4 = "4"
        case _inning5 = "5"
        case _inning6 = "6"
        case _inning7 = "7"
        case _inning8 = "8"
        case _inning9 = "9"
        case _inning10 = "10"
        case _inning11 = "11"
        case _inning12 = "12"
        case _inning13 = "13"
        case _inning14 = "14"
        case _inning15 = "15"
        case _b = "b"
        case _e = "e"
        case _h = "h"
        case _r = "r"
        case _teamName = "teamName"
    }
}

struct KBOGameLineupInfo: Decodable, Equatable {
    let away: KBOGameLineup
    let home: KBOGameLineup
}

struct KBOGameLineup: Decodable, Equatable {
    let hitters: [KBOGameHitterStats]
    let pitchers: [KBOGamePitcherStats]
}

struct KBOGameHitterStats: Decodable, Equatable {
    private let _ab: String?
    private let _bb: String?
    private let _e: String?
    private let _gdp: String?
    private let _h: String?
    private let _hr: String?
    private let _playerName: String?
    private let _r: String?
    private let _rbi: String?
    private let _sb: String?
    private let _sf: String?
    private let _so: String?

    var ab: String { _ab ?? "" }         // 타수
    var bb: String { _bb ?? "" }         // 볼넷
    var e: String { _e ?? "" }           // 실책
    var gdp: String { _gdp ?? "" }       // 병살타
    var h: String { _h ?? "" }           // 안타
    var hr: String { _hr ?? "" }         // 홈런
    var playerName: String { _playerName ?? "" }
    var r: String { _r ?? "" }           // 득점
    var rbi: String { _rbi ?? "" }       // 타점
    var sb: String { _sb ?? "" }         // 도루
    var sf: String { _sf ?? "" }         // 희생플라이
    var so: String { _so ?? "" }         // 삼진

    private enum CodingKeys: String, CodingKey {
        case _ab = "ab"
        case _bb = "bb"
        case _e = "e"
        case _gdp = "gdp"
        case _h = "h"
        case _hr = "hr"
        case _playerName = "playerName"
        case _r = "r"
        case _rbi = "rbi"
        case _sb = "sb"
        case _sf = "sf"
        case _so = "so"
    }
}

struct KBOGamePitcherStats: Decodable, Equatable {
    private let _ab: String?
    private let _bb: String?
    private let _er: String?
    private let _h: String?
    private let _hr: String?
    private let _ip: String?
    private let _np: String?
    private let _playerName: String?
    private let _r: String?
    private let _sf: String?
    private let _so: String?
    private let _tbf: String?

    var ab: String { _ab ?? "" }           // 타수
    var bb: String { _bb ?? "" }           // 볼넷
    var er: String { _er ?? "" }           // 자책
    var h: String { _h ?? "" }             // 피안타
    var hr: String { _hr ?? "" }           // 피홈런
    var ip: String { _ip ?? "" }           // 이닝
    var np: String { _np ?? "" }           // 투구수
    var playerName: String { _playerName ?? "" }
    var r: String { _r ?? "" }             // 실점
    var sf: String { _sf ?? "" }           // 희생타
    var so: String { _so ?? "" }           // 삼진
    var tbf: String { _tbf ?? "" }         // 타자수

    private enum CodingKeys: String, CodingKey {
        case _ab = "ab"
        case _bb = "bb"
        case _er = "er"
        case _h = "h"
        case _hr = "hr"
        case _ip = "ip"
        case _np = "np"
        case _playerName = "playerName"
        case _r = "r"
        case _sf = "sf"
        case _so = "so"
        case _tbf = "tbf"
    }
}
