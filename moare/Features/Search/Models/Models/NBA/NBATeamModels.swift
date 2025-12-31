//
//  FootballTeam.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/10/24.
//

import Foundation

struct NBATeam: Decodable, Equatable {
    let team: NBATeamInfo
    let venue: NBAVenue
    let statistics: [NBATeamStats]
}

struct NBATeamInfo: Decodable, Equatable {
    private let _abbreviation: String?
    private let _city: String?
    private let _confRank: Int?
    private let _divRank: Int?
    private let _fullName: String?
    private let _id: Int?
    private let _l: Int?
    private let _maxYear: String?
    private let _minYear: String?
    private let _nickname: String?
    private let _pct: Double?
    private let _seasonYear: String?
    private let _state: String?
    private let _teamCode: String?
    private let _teamConference: String?
    private let _teamDivision: String?
    private let _w: Int?
    private let _yearFounded: Int?

    var abbreviation: String { _abbreviation ?? "" }
    var city: String { _city ?? "" }
    var confRank: Int { _confRank ?? 0 }
    var divRank: Int { _divRank ?? 0 }
    var fullName: String { _fullName ?? "" }
    var id: Int { _id ?? 0 }
    var losses: Int { _l ?? 0 }
    var maxYear: String { _maxYear ?? "" }
    var minYear: String { _minYear ?? "" }
    var nickname: String { _nickname ?? "" }
    var pct: Double { _pct ?? 0.0 }
    var seasonYear: String { _seasonYear ?? "" }
    var state: String { _state ?? "" }
    var teamCode: String { _teamCode ?? "" }
    var teamConference: String { _teamConference ?? "" }
    var teamDivision: String { _teamDivision ?? "" }
    var wins: Int { _w ?? 0 }
    var yearFounded: Int { _yearFounded ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _abbreviation = "abbreviation"
        case _city = "city"
        case _confRank = "confRank"
        case _divRank = "divRank"
        case _fullName = "fullName"
        case _id = "id"
        case _l = "l"
        case _maxYear = "maxYear"
        case _minYear = "minYear"
        case _nickname = "nickname"
        case _pct = "pct"
        case _seasonYear = "seasonYear"
        case _state = "state"
        case _teamCode = "teamCode"
        case _teamConference = "teamConference"
        case _teamDivision = "teamDivision"
        case _w = "w"
        case _yearFounded = "yearFounded"
    }
}

struct NBAVenue: Decodable, Equatable {
    private let _capacity: Int?
    private let _name: String?
    private let _opened: Int?

    var capacity: Int { _capacity ?? 0 }
    var name: String { _name ?? "" }
    var opened: Int { _opened ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _capacity = "capacity"
        case _name = "name"
        case _opened = "opened"
    }
}

struct NBATeamStats: Decodable, Equatable {
    private let _ast: Int?
    private let _blk: Int?
    private let _blka: Int?
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
    private let _min: Double?
    private let _oreb: Int?
    private let _pf: Int?
    private let _pfd: Int?
    private let _plusMinus: Int?
    private let _pts: Int?
    private let _reb: Int?
    private let _seasonType: String?
    private let _stl: Int?
    private let _tov: Int?
    private let _w: Int?
    private let _wPct: Double?
    private let _playoffRank: Int?
    private let _strCurrentStreak: String?
    private let _home: String?
    private let _road: String?
    private let _l10: String?

    var ast: Int { _ast ?? 0 }
    var blk: Int { _blk ?? 0 }
    var blka: Int { _blka ?? 0 }
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
    var min: Int { Int((_min ?? 0.0).rounded(to: 0)) }
    var oreb: Int { _oreb ?? 0 }
    var pf: Int { _pf ?? 0 }
    var pfd: Int { _pfd ?? 0 }
    var plusMinus: Int { _plusMinus ?? 0 }
    var pts: Int { _pts ?? 0 }
    var reb: Int { _reb ?? 0 }
    var seasonType: String { _seasonType ?? "" }
    var stl: Int { _stl ?? 0 }
    var tov: Int { _tov ?? 0 }
    var wins: Int { _w ?? 0 }
    var winsPct: Double { _wPct ?? 0.0 }
    
    var playoffRank: Int { _playoffRank ?? 0 }
    var strCurrentStreak: String { _strCurrentStreak ?? "" }
    var home: String { _home ?? "" }
    var road: String { _road ?? "" }
    var l10: String { _l10 ?? "" }
    
    var displayRank = 0 // team standings 화면에서 순위 표시에 쓰이는 값
    var krCurrentStreak: String {
        guard let raw = _strCurrentStreak?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty
        else { return "" }
        
        let upper = raw.uppercased()
        guard let first = upper.first else { return "" }
        
        let digits = upper.dropFirst().filter { $0.isNumber }
        guard !digits.isEmpty else { return raw }
        
        switch first {
        case "W": return "\(String(digits))승"
        case "L": return "\(String(digits))패"
        default:  return raw
        }
    }
    var krHome: String { recordToKr(_home) }
    var krRoad: String { recordToKr(_road) }
    var krL10: String { recordToKr(_l10) }

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
    var minPG: String { gp != 0 ? CalendarUtil.formatMinutesToHourMinute(min: min) : "0:0" }
    var plusMinusPG: Double { gp != 0 ? (Double(plusMinus) / Double(gp)).rounded(to: 1) : 0.0 }
    
    // String with 3 decimal places
    var winsPctStr: String {
        String(format: "%.3f", winsPct)
    }
    var fgPctStr: String {
        String(format: "%.3f", fgPct)
    }
    var ftPctStr: String {
        String(format: "%.3f", ftPct)
    }
    var fg3PctStr: String {
        String(format: "%.3f", fg3Pct)
    }

    private enum CodingKeys: String, CodingKey {
        case _ast = "ast"
        case _blk = "blk"
        case _blka = "blka"
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
        case _min = "min"
        case _oreb = "oreb"
        case _pf = "pf"
        case _pfd = "pfd"
        case _plusMinus = "plusMinus"
        case _pts = "pts"
        case _reb = "reb"
        case _seasonType = "seasonType"
        case _stl = "stl"
        case _tov = "tov"
        case _w = "w"
        case _wPct = "wPct"
        case _playoffRank = "playoffRank"
        case _strCurrentStreak = "strCurrentStreak"
        case _home = "home"
        case _road = "road"
        case _l10 = "l10"
    }
    
    private func recordToKr(_ value: String?) -> String {
        guard let raw = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return "" }

        // 예: "5-5"
        let parts = raw.split(separator: "-", omittingEmptySubsequences: true)
        guard parts.count == 2 else { return raw } // 형식 이상하면 원본 반환

        let win = parts[0].trimmingCharacters(in: .whitespaces)
        let lose = parts[1].trimmingCharacters(in: .whitespaces)
        return "\(win)승\(lose)패"
    }
    
    /// 정렬/비교용: 승률 + 승수
    func parseRecord(_ value: String?) -> (winPct: Double, wins: Int) {
        guard let raw = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return (0, 0) }

        // 예: "5-5"
        let parts = raw.split(separator: "-", omittingEmptySubsequences: true)
        guard parts.count == 2,
              let w = Int(parts[0].trimmingCharacters(in: .whitespaces)),
              let l = Int(parts[1].trimmingCharacters(in: .whitespaces)) else { return (0, 0) }

        let games = w + l
        let pct = games == 0 ? 0 : Double(w) / Double(games)
        return (pct, w)
    }
}
