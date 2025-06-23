//
//  KBOPlayerModels.swift
//  moare
//
//  Created by Mohwa Yoon on 6/2/25.
//

import Foundation

struct KBOPlayer: Decodable, Equatable {
    let player: KBOPlayerInfo
    let statistics: [KBOPlayerStats]
}


struct KBOPlayerInfo: Decodable, Equatable {
    private let _birthdate: String?
    private let _career: String?
    private let _draftRound: String?
    private let _fromYear: String?
    private let _height: String?
    private let _id: Int?
    private let _jersey: String?
    private let _name: String?
    private let _position: String?
    private let _salary: String?
    private let _signingBonus: String?
    private let _teamId: Int?
    private let _weight: String?

    var birthdate: String { _birthdate ?? "" }
    var career: String { _career ?? "" }
    var draftRound: String { _draftRound ?? "" }
    var fromYear: String { _fromYear ?? "" }
    var height: String { _height ?? "" }
    var id: Int { _id ?? 0 }
    var jersey: String { _jersey ?? "" }
    var name: String { _name ?? "" }
    var position: String { _position ?? "" }
    var salary: String { _salary ?? "" }
    var signingBonus: String { _signingBonus ?? "" }
    var teamId: Int { _teamId ?? 0 }
    var weight: String { _weight ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _birthdate = "birthdate"
        case _career = "career"
        case _draftRound = "draftRound"
        case _fromYear = "fromYear"
        case _height = "height"
        case _id = "id"
        case _jersey = "jersey"
        case _name = "name"
        case _position = "position"
        case _salary = "salary"
        case _signingBonus = "signingBonus"
        case _teamId = "teamId"
        case _weight = "weight"
    }
}

struct KBOPlayerStats: Decodable, Equatable {
    let hitter: KBOPlayerHitterStats?
    let pitcher: KBOPlayerPitcherStats?
    private let _season: Int?
    private let _seasonType: String?

    var season: Int { _season ?? 0 }
    var seasonType: String { _seasonType ?? "" }

    private enum CodingKeys: String, CodingKey {
        case hitter, pitcher
        case _season = "season"
        case _seasonType = "seasonType"
    }
}

struct KBOPlayerHitterStats: Decodable, Equatable {
    private let _double: String?
    private let _triple: String?
    private let _ab: String?
    private let _avg: String?
    private let _bb: String?
    private let _cs: String?
    private let _e: String?
    private let _g: String?
    private let _gdp: String?
    private let _h: String?
    private let _hbp: String?
    private let _hr: String?
    private let _ibb: String?
    private let _mh: String?
    private let _obp: String?
    private let _ops: String?
    private let _pa: String?
    private let _phBa: String?
    private let _r: String?
    private let _rbi: String?
    private let _risp: String?
    private let _sac: String?
    private let _sb: String?
    private let _sbPercent: String?
    private let _sf: String?
    private let _slg: String?
    private let _so: String?
    private let _tb: String?

    var double: String { _double ?? "" }
    var triple: String { _triple ?? "" }
    var ab: String { _ab ?? "" }
    var avg: String { _avg ?? "" }
    var bb: String { _bb ?? "" }
    var cs: String { _cs ?? "" }
    var e: String { _e ?? "" }
    var g: String { _g ?? "" }
    var gdp: String { _gdp ?? "" }
    var h: String { _h ?? "" }
    var hbp: String { _hbp ?? "" }
    var hr: String { _hr ?? "" }
    var ibb: String { _ibb ?? "" }
    var mh: String { _mh ?? "" }
    var obp: String { _obp ?? "" }
    var ops: String { _ops ?? "" }
    var pa: String { _pa ?? "" }
    var phBa: String { _phBa ?? "" }
    var r: String { _r ?? "" }
    var rbi: String { _rbi ?? "" }
    var risp: String { _risp ?? "" }
    var sac: String { _sac ?? "" }
    var sb: String { _sb ?? "" }
    var sbPercent: String { _sbPercent ?? "" }
    var sf: String { _sf ?? "" }
    var slg: String { _slg ?? "" }
    var so: String { _so ?? "" }
    var tb: String { _tb ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _double = "2b"
        case _triple = "3b"
        case _ab = "ab"
        case _avg = "avg"
        case _bb = "bb"
        case _cs = "cs"
        case _e = "e"
        case _g = "g"
        case _gdp = "gdp"
        case _h = "h"
        case _hbp = "hbp"
        case _hr = "hr"
        case _ibb = "ibb"
        case _mh = "mh"
        case _obp = "obp"
        case _ops = "ops"
        case _pa = "pa"
        case _phBa = "ph-ba"
        case _r = "r"
        case _rbi = "rbi"
        case _risp = "risp"
        case _sac = "sac"
        case _sb = "sb"
        case _sbPercent = "sb%"
        case _sf = "sf"
        case _slg = "slg"
        case _so = "so"
        case _tb = "tb"
    }
}

struct KBOPlayerPitcherStats: Decodable, Equatable {
    private let _double: String?
    private let _triple: String?
    private let _avg: String?
    private let _bb: String?
    private let _bk: String?
    private let _bsv: String?
    private let _cg: String?
    private let _er: String?
    private let _era: String?
    private let _g: String?
    private let _h: String?
    private let _hld: String?
    private let _hr: String?
    private let _ibb: String?
    private let _ip: String?
    private let _l: String?
    private let _np: String?
    private let _qs: String?
    private let _r: String?
    private let _sac: String?
    private let _sf: String?
    private let _sho: String?
    private let _so: String?
    private let _sv: String?
    private let _tbf: String?
    private let _w: String?
    private let _whip: String?
    private let _wp: String?
    private let _wpct: String?

    var double: String { _double ?? "" }
    var triple: String { _triple ?? "" }
    var avg: String { _avg ?? "" }
    var bb: String { _bb ?? "" }
    var bk: String { _bk ?? "" }
    var bsv: String { _bsv ?? "" }
    var cg: String { _cg ?? "" }
    var er: String { _er ?? "" }
    var era: String { _era ?? "" }
    var g: String { _g ?? "" }
    var h: String { _h ?? "" }
    var hld: String { _hld ?? "" }
    var hr: String { _hr ?? "" }
    var ibb: String { _ibb ?? "" }
    var ip: String { _ip ?? "" }
    var l: String { _l ?? "" }
    var np: String { _np ?? "" }
    var qs: String { _qs ?? "" }
    var r: String { _r ?? "" }
    var sac: String { _sac ?? "" }
    var sf: String { _sf ?? "" }
    var sho: String { _sho ?? "" }
    var so: String { _so ?? "" }
    var sv: String { _sv ?? "" }
    var tbf: String { _tbf ?? "" }
    var w: String { _w ?? "" }
    var whip: String { _whip ?? "" }
    var wp: String { _wp ?? "" }
    var wpct: String { _wpct ?? "" }

    // 경기당 볼넷
    
    // 경기당 평균 투구수
//    var npsPG: Double { Int(g) != 0 ? (Double(np) / Double(g)).rounded(to: 1) : 0.0 }
    
    // 경기당 평균 이닝수

    private enum CodingKeys: String, CodingKey {
        case _double = "2b"
        case _triple = "3b"
        case _avg = "avg"
        case _bb = "bb"
        case _bk = "bk"
        case _bsv = "bsv"
        case _cg = "cg"
        case _er = "er"
        case _era = "era"
        case _g = "g"
        case _h = "h"
        case _hld = "hld"
        case _hr = "hr"
        case _ibb = "ibb"
        case _ip = "ip"
        case _l = "l"
        case _np = "np"
        case _qs = "qs"
        case _r = "r"
        case _sac = "sac"
        case _sf = "sf"
        case _sho = "sho"
        case _so = "so"
        case _sv = "sv"
        case _tbf = "tbf"
        case _w = "w"
        case _whip = "whip"
        case _wp = "wp"
        case _wpct = "wpct"
    }
}
