//
//  FootballPlayer.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/10/24.
//

import Foundation

struct NBAPlayer: Decodable, Equatable {
    let player: NBAPlayerInfo
    var statistics: [NBAPlayerStats] = []
}

struct NBAPlayerInfo: Decodable, Equatable {
    private let _birthdate: String?
    private let _country: String?
    private let _displayFirstLast: String?
    private let _dleagueFlag: String?
    private let _draftNumber: String?
    private let _draftRound: String?
    private let _draftYear: String?
    private let _firstName: String?
    private let _fromYear: Int?
    private let _gamesPlayedCurrentSeasonFlag: String?
    private let _gamesPlayedFlag: String?
    private let _height: String?
    private let _jersey: String?
    private let _lastAffiliation: String?
    private let _lastName: String?
    private let _nbaFlag: String?
    private let _personId: Int?
    private let _position: String?
    private let _rosterStatus: String?
    private let _school: String?
    private let _seasonExp: Int?
    private let _teamAbbreviation: String?
    private let _teamCity: String?
    private let _teamCode: String?
    private let _teamId: Int?
    private let _teamName: String?
    private let _toYear: Int?
    private let _weight: String?

    var birthdate: String { _birthdate ?? "" }
    var country: String { _country ?? "" }
    var displayFirstLast: String { _displayFirstLast ?? "" }
    var dleagueFlag: String { _dleagueFlag ?? "" }
    var draftNumber: String { _draftNumber ?? "" }
    var draftRound: String { _draftRound ?? "" }
    var draftYear: String { _draftYear ?? "" }
    var firstName: String { _firstName ?? "" }
    var fromYear: Int { _fromYear ?? 0 }
    var gamesPlayedCurrentSeasonFlag: String { _gamesPlayedCurrentSeasonFlag ?? "" }
    var gamesPlayedFlag: String { _gamesPlayedFlag ?? "" }
    var height: String { _height ?? "" }
    var jersey: String { _jersey ?? "" }
    var lastAffiliation: String { _lastAffiliation ?? "" }
    var lastName: String { _lastName ?? "" }
    var nbaFlag: String { _nbaFlag ?? "" }
    var personId: Int { _personId ?? 0 }
    var position: String { _position ?? "" }
    var rosterStatus: String { _rosterStatus ?? "" }
    var school: String { _school ?? "" }
    var seasonExp: Int { _seasonExp ?? 0 }
    var teamAbbreviation: String { _teamAbbreviation ?? "" }
    var teamCity: String { _teamCity ?? "" }
    var teamCode: String { _teamCode ?? "" }
    var teamId: Int { _teamId ?? 0 }
    var teamName: String { _teamName ?? "" }
    var toYear: Int { _toYear ?? 0 }
    var weight: String { _weight ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _birthdate = "birthdate"
        case _country = "country"
        case _displayFirstLast = "displayFirstLast"
        case _dleagueFlag = "dleagueFlag"
        case _draftNumber = "draftNumber"
        case _draftRound = "draftRound"
        case _draftYear = "draftYear"
        case _firstName = "firstName"
        case _fromYear = "fromYear"
        case _gamesPlayedCurrentSeasonFlag = "gamesPlayedCurrentSeasonFlag"
        case _gamesPlayedFlag = "gamesPlayedFlag"
        case _height = "height"
        case _jersey = "jersey"
        case _lastAffiliation = "lastAffiliation"
        case _lastName = "lastName"
        case _nbaFlag = "nbaFlag"
        case _personId = "personId"
        case _position = "position"
        case _rosterStatus = "rosterstatus"
        case _school = "school"
        case _seasonExp = "seasonExp"
        case _teamAbbreviation = "teamAbbreviation"
        case _teamCity = "teamCity"
        case _teamCode = "teamCode"
        case _teamId = "teamId"
        case _teamName = "teamName"
        case _toYear = "toYear"
        case _weight = "weight"
    }
}

struct NBAPlayerStats: Decodable, Equatable {
    private let _ast: Int?
    private let _blk: Int?
    private let _blka: Int?
    private let _dd2: Int?
    private let _dreb: Int?
    private let _fg3a: Int?
    private let _fg3m: Int?
    private let _fg3Pct: Double?
    private let _fga: Int?
    private let _fgm: Int?
    private let _fgPct: Double?
    private let _fta: Int?
    private let _ftm: Int?
    private let _ftPct: Double?
    private let _gp: Int?
    private let _groupValue: String?
    private let _l: Int?
    private let _maxGameDate: String?
    private let _min: Double?
    private let _oreb: Int?
    private let _pf: Int?
    private let _pfd: Int?
    private let _plusMinus: Int?
    private let _pts: Int?
    private let _reb: Int?
    private let _seasonType: String?
    private let _stl: Int?
    private let _td3: Int?
    private let _teamAbbreviation: String?
    private let _teamId: Int?
    private let _tov: Int?
    private let _w: Int?
    private let _wPct: Double?
    private let _teamGp: Int?

    var ast: Int { _ast ?? 0 }
    var blk: Int { _blk ?? 0 }
    var blka: Int { _blka ?? 0 }
    var dd2: Int { _dd2 ?? 0 }
    var dreb: Int { _dreb ?? 0 }
    var fg3a: Int { _fg3a ?? 0 }
    var fg3m: Int { _fg3m ?? 0 }
    var fg3Pct: Double { _fg3Pct ?? 0.0 }
    var fga: Int { _fga ?? 0 }
    var fgm: Int { _fgm ?? 0 }
    var fgPct: Double { _fgPct ?? 0.0 }
    var fta: Int { _fta ?? 0 }
    var ftm: Int { _ftm ?? 0 }
    var ftPct: Double { _ftPct ?? 0.0 }
    var gp: Int { _gp ?? 0 }
    var groupValue: String { _groupValue ?? "" }
    var losses: Int { _l ?? 0 }
    var maxGameDate: String { _maxGameDate ?? "" }
    var min: Int { Int((_min ?? 0.0).rounded(to: 0)) }
    var oreb: Int { _oreb ?? 0 }
    var pf: Int { _pf ?? 0 }
    var pfd: Int { _pfd ?? 0 }
    var plusMinus: Int { _plusMinus ?? 0 }
    var pts: Int { _pts ?? 0 }
    var reb: Int { _reb ?? 0 }
    var seasonType: String { _seasonType ?? "" }
    var stl: Int { _stl ?? 0 }
    var td3: Int { _td3 ?? 0 }
    var teamAbbreviation: String { _teamAbbreviation ?? "" }
    var teamId: Int { _teamId ?? 0 }
    var tov: Int { _tov ?? 0 }
    var wins: Int { _w ?? 0 }
    var winsPct: Double { _wPct ?? 0.0 }
    var teamGp: Int { _teamGp ?? 0 }

    // Per Game Stats
    var ptsPG: Double { gp != 0 ? (Double(pts) / Double(gp)).rounded(to: 1) : 0.0 }
    var astPG: Double { gp != 0 ? (Double(ast) / Double(gp)).rounded(to: 1) : 0.0 }
    var rebPG: Double { gp != 0 ? (Double(reb) / Double(gp)).rounded(to: 1) : 0.0 }
    var drebPG: Double { gp != 0 ? (Double(dreb) / Double(gp)).rounded(to: 1) : 0.0 }
    var orebPG: Double { gp != 0 ? (Double(oreb) / Double(gp)).rounded(to: 1) : 0.0 }
    var blkPG: Double { gp != 0 ? (Double(blk) / Double(gp)).rounded(to: 1) : 0.0 }
    var blkaPG: Double { gp != 0 ? (Double(blka) / Double(gp)).rounded(to: 1) : 0.0 }
    var stlPG: Double { gp != 0 ? (Double(stl) / Double(gp)).rounded(to: 1) : 0.0 }
    var tovPG: Double { gp != 0 ? (Double(tov) / Double(gp)).rounded(to: 1) : 0.0 }
    var fg3aPG: Double { gp != 0 ? (Double(fg3a) / Double(gp)).rounded(to: 1) : 0.0 }
    var fg3mPG: Double { gp != 0 ? (Double(fg3m) / Double(gp)).rounded(to: 1) : 0.0 }
    var fgaPG: Double { gp != 0 ? (Double(fga) / Double(gp)).rounded(to: 1) : 0.0 }
    var fgmPG: Double { gp != 0 ? (Double(fgm) / Double(gp)).rounded(to: 1) : 0.0 }
    var ftaPG: Double { gp != 0 ? (Double(fta) / Double(gp)).rounded(to: 1) : 0.0 }
    var ftmPG: Double { gp != 0 ? (Double(ftm) / Double(gp)).rounded(to: 1) : 0.0 }
    var pfPG: Double { gp != 0 ? (Double(pf) / Double(gp)).rounded(to: 1) : 0.0 }
    var pfdPG: Double { gp != 0 ? (Double(pfd) / Double(gp)).rounded(to: 1) : 0.0 }
    var minPG: String { gp != 0 ? CalendarUtil.formatMinutesToHourMinute(min) : "0:0" }
    var plusMinusPG: Double { gp != 0 ? (Double(plusMinus) / Double(gp)).rounded(to: 1) : 0.0 }

    private enum CodingKeys: String, CodingKey {
        case _ast = "ast"
        case _blk = "blk"
        case _blka = "blka"
        case _dd2 = "dd2"
        case _dreb = "dreb"
        case _fg3a = "fg3a"
        case _fg3m = "fg3m"
        case _fg3Pct = "fg3Pct"
        case _fga = "fga"
        case _fgm = "fgm"
        case _fgPct = "fgPct"
        case _fta = "fta"
        case _ftm = "ftm"
        case _ftPct = "ftPct"
        case _gp = "gp"
        case _groupValue = "groupValue"
        case _l = "l"
        case _maxGameDate = "maxGameDate"
        case _min = "min"
        case _oreb = "oreb"
        case _pf = "pf"
        case _pfd = "pfd"
        case _plusMinus = "plusMinus"
        case _pts = "pts"
        case _reb = "reb"
        case _seasonType = "seasonType"
        case _stl = "stl"
        case _td3 = "td3"
        case _teamAbbreviation = "teamAbbreviation"
        case _teamId = "teamId"
        case _tov = "tov"
        case _w = "w"
        case _wPct = "wPct"
        case _teamGp = "teamGp"
    }
}

