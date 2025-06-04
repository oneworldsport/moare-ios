//
//  KBOTeamModels.swift
//  moare
//
//  Created by Mohwa Yoon on 6/2/25.
//

import Foundation

struct KBOTeam: Decodable, Equatable {
    let team: KBOTeamInfo
    let venue: KBOTeamVenue
    let statistics: [KBOTeamStats]
}

struct KBOTeamInfo: Decodable, Equatable {
    private let _city: String?
    private let _coach: String?
    private let _id: Int?
    private let _teamCode: String?
    private let _teamName: String?
    private let _yearFounded: Int?

    var city: String { _city ?? "" }
    var coach: String { _coach ?? "" }
    var id: Int { _id ?? 0 }
    var teamCode: String { _teamCode ?? "" }
    var teamName: String { _teamName ?? "" }
    var yearFounded: Int { _yearFounded ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _city = "city"
        case _coach = "coach"
        case _id = "id"
        case _teamCode = "teamCode"
        case _teamName = "teamName"
        case _yearFounded = "yearFounded"
    }
}

struct KBOTeamVenue: Decodable, Equatable {
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

struct KBOTeamStats: Decodable, Equatable {
    let defenseData: KBOTeamDefenseData
    let hitterData: KBOTeamHitterData
    let pitcherData: KBOTeamPitcherData
    let rankData: KBOTeamRankData
    let runnerData: KBOTeamRunnerData
    private let _season: Int?
    private let _seasonType: String?
    
    var season: Int { _season ?? 0 }
    var seasonType: String { _seasonType ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case defenseData, hitterData, pitcherData, rankData, runnerData
        case _season = "season"
        case _seasonType = "seasonType"
    }
}

struct KBOTeamDefenseData: Decodable, Equatable {
    private let _a: String?
    private let _cs: String?
    private let _csPercent: String?
    private let _dp: String?
    private let _e: String?
    private let _fpct: String?
    private let _g: String?
    private let _pb: String?
    private let _pko: String?
    private let _po: String?
    private let _sb: String?
    private let _rank: String?
    private let _teamName: String?

    var a: String { _a ?? "" }           // 어시스트
    var cs: String { _cs ?? "" }         // 도루 실패
    var csPercent: String { _csPercent ?? "" } // 도루 저지율
    var dp: String { _dp ?? "" }         // 병살
    var e: String { _e ?? "" }           // 실책
    var fpct: String { _fpct ?? "" }     // 수비율
    var g: String { _g ?? "" }           // 경기
    var pb: String { _pb ?? "" }         // 포일
    var pko: String { _pko ?? "" }       // 견제사
    var po: String { _po ?? "" }         // 풋아웃
    var sb: String { _sb ?? "" }         // 도루 허용
    var rank: String { _rank ?? "" }
    var teamName: String { _teamName ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _a = "a"
        case _cs = "cs"
        case _csPercent = "cs%"
        case _dp = "dp"
        case _e = "e"
        case _fpct = "fpct"
        case _g = "g"
        case _pb = "pb"
        case _pko = "pko"
        case _po = "po"
        case _sb = "sb"
        case _rank = "rank"
        case _teamName = "teamName"
    }
}

struct KBOTeamHitterData: Decodable, Equatable {
    private let _double: String?
    private let _triple: String?
    private let _ab: String?
    private let _avg: String?
    private let _bb: String?
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
    private let _sf: String?
    private let _slg: String?
    private let _so: String?
    private let _tb: String?
    private let _rank: String?
    private let _teamName: String?

    var double: String { _double ?? "" } // 2루타
    var triple: String { _triple ?? "" } // 3루타
    var ab: String { _ab ?? "" } // 타수
    var avg: String { _avg ?? "" } // 타율
    var bb: String { _bb ?? "" } // 볼넷
    var g: String { _g ?? "" } // 경기수
    var gdp: String { _gdp ?? "" } // 병살타
    var h: String { _h ?? "" } // 안타
    var hbp: String { _hbp ?? "" } // 사구
    var hr: String { _hr ?? "" } // 홈런
    var ibb: String { _ibb ?? "" } // 고의4구
    var mh: String { _mh ?? "" } // 멀티히트
    var obp: String { _obp ?? "" } // 출루율
    var ops: String { _ops ?? "" } // 출루율 + 장타율
    var pa: String { _pa ?? "" } // 타석
    var phBa: String { _phBa ?? "" } // 대타타율
    var r: String { _r ?? "" } // 득점
    var rbi: String { _rbi ?? "" } // 타점
    var risp: String { _risp ?? "" } // 득점권타율
    var sac: String { _sac ?? "" } // 희생번트
    var sf: String { _sf ?? "" } // 희생플라이
    var slg: String { _slg ?? "" } // 장타율
    var so: String { _so ?? "" } // 삼진
    var tb: String { _tb ?? "" } // 루타
    var rank: String { _rank ?? "" }
    var teamName: String { _teamName ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _double = "2b"
        case _triple = "3b"
        case _ab = "ab"
        case _avg = "avg"
        case _bb = "bb"
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
        case _sf = "sf"
        case _slg = "slg"
        case _so = "so"
        case _tb = "tb"
        case _rank = "rank"
        case _teamName = "teamName"
    }
}

struct KBOTeamPitcherData: Decodable, Equatable {
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
    private let _hbp: String?
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
    private let _rank: String?
    private let _teamName: String?

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
    var hbp: String { _hbp ?? "" }
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
    var rank: String { _rank ?? "" }
    var teamName: String { _teamName ?? "" }

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
        case _hbp = "hbp"
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
        case _rank = "rank"
        case _teamName = "teamName"
    }
}

struct KBOTeamRunnerData: Decodable, Equatable {
    private let _cs: String?
    private let _g: String?
    private let _oob: String?
    private let _pko: String?
    private let _sb: String?
    private let _sbPercent: String?
    private let _sba: String?
    private let _rank: String?
    private let _teamName: String?

    var cs: String { _cs ?? "" }
    var g: String { _g ?? "" }
    var oob: String { _oob ?? "" }
    var pko: String { _pko ?? "" }
    var sb: String { _sb ?? "" }
    var sbPercent: String { _sbPercent ?? "" }
    var sba: String { _sba ?? "" }
    var rank: String { _rank ?? "" }
    var teamName: String { _teamName ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _cs = "cs"
        case _g = "g"
        case _oob = "oob"
        case _pko = "pko"
        case _sb = "sb"
        case _sbPercent = "sb%"
        case _sba = "sba"
        case _rank = "rank"
        case _teamName = "teamName"
    }
}

struct KBOTeamRankData: Decodable, Equatable {
    private let _awayrecord: String?
    private let _draws: String?
    private let _gb: String?
    private let _gp: String?
    private let _homerecord: String?
    private let _last10game: String?
    private let _losses: String?
    private let _streak: String?
    private let _winpct: String?
    private let _wins: String?
    private let _rank: String?
    private let _teamName: String?

    var awayrecord: String { _awayrecord ?? "" }
    var draws: String { _draws ?? "" }
    var gb: String { _gb ?? "" }
    var gp: String { _gp ?? "" }
    var homerecord: String { _homerecord ?? "" }
    var last10game: String { _last10game ?? "" }
    var losses: String { _losses ?? "" }
    var streak: String { _streak ?? "" }
    var winpct: String { _winpct ?? "" }
    var wins: String { _wins ?? "" }
    var rank: String { _rank ?? "" }
    var teamName: String { _teamName ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _awayrecord = "awayrecord"
        case _draws = "draws"
        case _gb = "gb"
        case _gp = "gp"
        case _homerecord = "homerecord"
        case _last10game = "last10game"
        case _losses = "losses"
        case _streak = "streak"
        case _winpct = "winpct"
        case _wins = "wins"
        case _rank = "rank"
        case _teamName = "teamName"
    }
}
