//
//  KBOGameModels.swift
//  moare
//
//  Created by Mohwa Yoon on 6/2/25.
//

import Foundation

struct KBOGame: Decodable, Equatable {
    let gameInfo: KBOGameInfo?
    let lineScore: KBOGameLineScoreInfo?
    let lineup: KBOGameLineupInfo?
}

struct KBOGameInfo: Decodable, Equatable {
    private let _awayTeamId: Int?
    private let _date: String?
    private let _gameId: String?
    private let _homeTeamId: Int?
    private let _remark: String?
    private let _gameStatus: String?

    var awayTeamId: Int { _awayTeamId ?? 0 }
    var date: String { _date ?? "" }
    var gameId: String { _gameId ?? "" }
    var homeTeamId: Int { _homeTeamId ?? 0 }
    var remark: String { _remark ?? "" }
    var gameStatus: String { _gameStatus ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _awayTeamId = "awayTeamId"
        case _date = "date"
        case _gameId = "gameId"
        case _homeTeamId = "homeTeamId"
        case _remark = "remark"
        case _gameStatus = "gameStatus"
    }
}

struct KBOGameLineScoreInfo: Decodable, Equatable {
    let away: KBOGameLineScore
    let home: KBOGameLineScore
    private let _currentInning: String?
    
    var currentInning: String { _currentInning ?? "" }

    private enum CodingKeys: String, CodingKey {
        case away, home
        case _currentInning = "currentInning"
    }
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
    var b: String { _b ?? "" }
    var e: String { _e ?? "" }
    var h: String { _h ?? "" }
    var r: String { _r ?? "" }
    var teamName: String { _teamName ?? "" }
    var innings: [String] {
        [
            inning1, inning2, inning3, inning4, inning5,
            inning6, inning7, inning8, inning9, inning10,
            inning11, inning12
        ]
    }

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
    private let _id: Int?
    private let _ab: String?
    private let _bb: String?
    private let _e: String?
    private let _gdp: String?
    private let _h: String?
    private let _hr: String?
    private let _name: String?
    private let _r: String?
    private let _rbi: String?
    private let _sb: String?
    private let _sf: String?
    private let _so: String?
    private let _avg: String?
    private let _battingNumber: Int?
    private let _position: String?
    let inningStats: [KBOGameHitterInningStat]?

    var id: Int { _id ?? 0 }
    var ab: String { _ab ?? "0" }         // 타수
    var bb: String { _bb ?? "0" }         // 볼넷
    var e: String { _e ?? "0" }           // 실책
    var gdp: String { _gdp ?? "0" }       // 병살타
    var h: String { _h ?? "0" }           // 안타
    var hr: String { _hr ?? "0" }         // 홈런
    var name: String { _name ?? "" }
    var r: String { _r ?? "0" }           // 득점
    var rbi: String { _rbi ?? "0" }       // 타점
    var sb: String { _sb ?? "0" }         // 도루
    var sf: String { _sf ?? "0" }         // 희생플라이
    var so: String { _so ?? "0" }         // 삼진
    var avg: String { _avg ?? "0.000" }       // 타율
    var battingNumber: Int { _battingNumber ?? 0 }
    var position: String { _position ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _ab = "ab"
        case _bb = "bb"
        case _e = "e"
        case _gdp = "gdp"
        case _h = "h"
        case _hr = "hr"
        case _name = "name"
        case _r = "r"
        case _rbi = "rbi"
        case _sb = "sb"
        case _sf = "sf"
        case _so = "so"
        case _avg = "avg"
        case _battingNumber = "batting_number"
        case _position = "position"
        case inningStats = "inningStats"
    }
}

struct KBOGameHitterInningStat: Decodable, Equatable {
    private let _num: Int?
    private let _info: String?

    var num: Int { _num ?? 0 }
    var info: String { _info ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _num = "num"
        case _info = "info"
    }
}

struct KBOGamePitcherStats: Decodable, Equatable {
    private let _id: Int?
    private let _ab: String?
    private let _bb: String?
    private let _er: String?
    private let _h: String?
    private let _hr: String?
    private let _ip: String?
    private let _np: String?
    private let _name: String?
    private let _r: String?
    private let _so: String?
    private let _tbf: String?
    private let _appearance: String?
    private let _result: String?
    private let _w: String?
    private let _l: String?
    private let _sv: String?
    private let _era: String?

    var id: Int { _id ?? 0 }
    var ab: String { _ab ?? "0" }           // 타수
    var bb: String { _bb ?? "0" }           // 볼넷
    var er: String { _er ?? "0" }           // 자책
    var h: String { _h ?? "0" }             // 피안타
    var hr: String { _hr ?? "0" }           // 피홈런
    var ip: String { _ip ?? "0.0" }           // 이닝
    var np: String { _np ?? "0" }           // 투구수
    var name: String { _name ?? "" }
    var r: String { _r ?? "0" }             // 실점
    var so: String { _so ?? "0" }           // 삼진
    var tbf: String { _tbf ?? "0" }         // 타자수
    var appearance: String { _appearance ?? "" } // 등판
    var result: String { _result ?? "" } // 결과
    var w: String { _w ?? "0" } // 승
    var l: String { _l ?? "0" } // 패
    var sv: String { _sv ?? "0" } // 세이브
    var era: String { _era ?? "0.0" } // 평균자책점

    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _ab = "ab"
        case _bb = "bb"
        case _er = "er"
        case _h = "h"
        case _hr = "hr"
        case _ip = "ip"
        case _np = "np"
        case _name = "name"
        case _r = "r"
        case _so = "so"
        case _tbf = "tbf"
        case _appearance = "appearance"
        case _result = "result"
        case _w = "w"
        case _l = "l"
        case _sv = "sv"
        case _era = "era"
    }
}

struct KBOGameInfoForSchedule: Decodable, Equatable {
    private let _currentInning: String?

    var currentInning: String { _currentInning ?? StringConstants.gameLiveStr }

    private enum CodingKeys: String, CodingKey {
        case _currentInning = "currentInning"
    }
    
    init(
        currentInning: String?
    ) {
        self._currentInning = currentInning
    }
}

typealias KBOGameForSchedule = GameForSchedule<KBOGameInfoForSchedule>
