//
//  TennisGameModels.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

// NOTE: homeTeam은 1, awayTeam은 2로 표시되는 필드들이 있음. ex) winnerCode, scoring, serving
struct TennisGame: Decodable, Equatable {
    let gameInfo: TennisGameInfo
    let pointByPoint: [TennisPointByPoint]?
    let statistics: [TennisGameStats]?
}

struct TennisGameInfo: Decodable, Equatable {
    let status: TennisGameStatus?
    let homeTeam: TennisGameTeam?
    let awayTeam: TennisGameTeam?
    let homeScore: TennisGameScore?
    let awayScore: TennisGameScore?
    let roundInfo: TennisGameRoundInfo?
    let venue: TennisGameVenue?
    let tournament: TennisGameTournament?
    let season: TennisGameSeason?
    let time: TennisGameTime?
    private let _id: Int?
    private let _gameDate: String?
    private let _winnerCode: Int?
    private let _defaultPeriodCount: Int?
    private let _groundType: String?
    
    var id: Int { _id ?? 0 }
    var gameDate: String { _gameDate ?? "" }
    var winnerCode: Int { _winnerCode ?? -1 }
    var defaultPeriodCount: Int { _defaultPeriodCount ?? 3 }
    var groundType: String { _groundType ?? "" }
    
    var isGameFinished: Bool { winnerCode != -1 } // CHECK: status로 판단하는게 맞을려나?
    var isHomeWinner: Bool { winnerCode == 1 }
    
    private enum CodingKeys: String, CodingKey {
        case status, homeTeam, awayTeam, homeScore, awayScore, roundInfo, venue, tournament, season, time
        case _id = "id"
        case _gameDate = "gameDate"
        case _winnerCode = "winnerCode"
        case _defaultPeriodCount = "defaultPeriodCount"
        case _groundType = "groundType"
    }
}

struct TennisGameStatus: Decodable, Equatable {
    private let _code: Int?
    private let _description: String?
    private let _type: String?
    
    var code: Int { _code ?? 0 }
    var description: String { _description ?? "" }
    var type: String { _type ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case _code = "code"
        case _description = "description"
        case _type = "type"
    }
}

struct TennisGameTeam: Decodable, Equatable {
    let country: TennisCountry?
    private let _fullName: String?
    private let _shortName: String?
    private let _gender: String?
    private let _id: Int?
    private let _name: String?
    private let _nameCode: String?
    private let _national: Bool?
    private let _slug: String?
    
    var fullName: String { _fullName ?? "" }
    var shortName: String { _shortName ?? "" }
    var gender: String { _gender ?? "M" }
    var id: Int { _id ?? 0 }
    var name: String { _name ?? "" }
    var nameCode: String { _nameCode ?? "" }
    var national: Bool { _national ?? false }
    var slug: String { _slug ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case country
        case _fullName = "fullName"
        case _shortName = "shortName"
        case _gender = "gender"
        case _id = "id"
        case _name = "name"
        case _nameCode = "nameCode"
        case _national = "national"
        case _slug = "slug"
    }
}

struct TennisGameScore: Decodable, Equatable {
    private let _current: Int?
    private let _display: Int?
    private let _normaltime: Int?
    let period1: Int? // NOTE: nil 값이 필요한 프로퍼티는 _ 네이밍 사용없이 그냥 사용.
    let period2: Int?
    let period3: Int?
    let period4: Int?
    let period5: Int?
    let period1TieBreak: Int?
    let period2TieBreak: Int?
    let period3TieBreak: Int?
    let period4TieBreak: Int?
    let period5TieBreak: Int?
    private let _point: String?
    
    var current: Int { _current ?? 0 }
    var display: Int { _display ?? 0 }
    var normaltime: Int { _normaltime ?? 0 }
    var point: String { _point ?? "" }
    
    var periods: [Int?] { [period1, period2, period3, period4, period5] }
    var periodsTieBreak: [Int?] { [period1TieBreak, period2TieBreak, period3TieBreak, period4TieBreak, period5TieBreak] }
    
    private enum CodingKeys: String, CodingKey {
        case period1, period2, period3, period4, period5, period1TieBreak, period2TieBreak, period3TieBreak, period4TieBreak, period5TieBreak
        case _current = "current"
        case _display = "display"
        case _normaltime = "normaltime"
        case _point = "point"
    }
}

struct TennisGameRoundInfo: Decodable, Equatable {
    private let _name: String?
    private let _round: Int?
    private let _slug: String?
    
    var name: String { _name ?? "" }
    var round: Int { _round ?? 0 }
    var slug: String { _slug ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case _name = "name"
        case _round = "round"
        case _slug = "slug"
    }
}

struct TennisGameVenue: Decodable, Equatable {
    let city: TennisName?
    let country: TennisCountry?
    let stadium: TennisName?
    private let _hidden: Bool?
    private let _id: Int?
    private let _name: String?
    private let _slug: String?
    
    var hidden: Bool { _hidden ?? true }
    var id: Int { _id ?? 0 }
    var name: String { _name ?? "" }
    var slug: String { _slug ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case city, country, stadium
        case _hidden = "hidden"
        case _id = "id"
        case _name = "name"
        case _slug = "slug"
    }
}

struct TennisGameTournament: Decodable, Equatable {
    let category: TennisTournamentCategory?
    let uniqueTournament: TennisUniqueTournament?
    private let _id: Int?
    private let _competitionType: Int?
    private let _startTimestamp: Int?
    private let _endTimestamp: Int?
    private let _isGroup: Bool?
    private let _name: String?
    private let _slug: String?
    
    var id: Int { _id ?? 0 }
    var competitionType: Int { _competitionType ?? 0 }
    var startTimestamp: Int { _startTimestamp ?? 0 }
    var endTimestamp: Int { _endTimestamp ?? 0 }
    var isGroup: Bool { _isGroup ?? false }
    var name: String { _name ?? "" }
    var slug: String { _slug ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case category, uniqueTournament
        case _id = "id"
        case _competitionType = "competitionType"
        case _startTimestamp = "startTimestamp"
        case _endTimestamp = "endTimestamp"
        case _isGroup = "isGroup"
        case _name = "name"
        case _slug = "slug"
    }
}

struct TennisTournamentCategory: Decodable, Equatable {
    let country: TennisCountry?
    private let _id: Int?
    private let _flag: String?
    private let _name: String?
    private let _slug: String?
    
    var id: Int { _id ?? 0 }
    var flag: String { _flag ?? "" }
    var name: String { _name ?? "" }
    var slug: String { _slug ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case country
        case _id = "id"
        case _flag = "flag"
        case _name = "name"
        case _slug = "slug"
    }
}

struct TennisUniqueTournament: Decodable, Equatable {
    let category: TennisTournamentCategory?
    private let _id: Int?
    private let _displayInverseHomeAwayTeams: Bool?
    private let _hasRounds: Bool?
    private let _name: String?
    private let _slug: String?
    private let _tennisPoints: Int?
    
    var id: Int { _id ?? 0 }
    var displayInverseHomeAwayTeams: Bool { _displayInverseHomeAwayTeams ?? false }
    var hasRounds: Bool { _hasRounds ?? true }
    var name: String { _name ?? "" }
    var slug: String { _slug ?? "" }
    var tennisPoints: Int { _tennisPoints ?? 0 }
    
    private enum CodingKeys: String, CodingKey {
        case category
        case _id = "id"
        case _displayInverseHomeAwayTeams = "displayInverseHomeAwayTeams"
        case _hasRounds = "hasRounds"
        case _name = "name"
        case _slug = "slug"
        case _tennisPoints = "tennisPoints"
    }
}

struct TennisGameSeason: Decodable, Equatable {
    private let _id: Int?
    private let _name: String?
    private let _year: String?
    
    var id: Int { _id ?? 0 }
    var name: String { _name ?? "" }
    var year: String { _year ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _year = "year"
    }
}

struct TennisGameTime: Decodable, Equatable {
    private let _currentPeriodStartTimestamp: Int?
    let period1: Int?
    let period2: Int?
    let period3: Int?
    let period4: Int?
    let period5: Int?
    
    var currentPeriodStartTimestamp: Int { _currentPeriodStartTimestamp ?? 0 }
    
    private enum CodingKeys: String, CodingKey {
        case period1, period2, period3, period4, period5
        case _currentPeriodStartTimestamp = "currentPeriodStartTimestamp"
    }
}

struct TennisPointByPoint: Decodable, Equatable {
    let games: [TennisPointByPointGame]?
    private let _set: Int?
    
    var set: Int { _set ?? 0 }
    
    private enum CodingKeys: String, CodingKey {
        case games
        case _set = "set"
    }
}

struct TennisPointByPointGame: Decodable, Equatable {
    let points: [TennisGamePoint]?
    let score: TennisPointByPointGameScore?
    private let _game: Int?
    
    var game: Int { _game ?? 0 }
    
    private enum CodingKeys: String, CodingKey {
        case points, score
        case _game = "game"
    }
}

struct TennisGamePoint: Decodable, Equatable {
    private let _homePoint: String?
    private let _homePointType: Int?
    private let _awayPoint: String?
    private let _awayPointType: Int?
    private let _pointDescription: Int? // 1: Ace(에이스), 2: Double fault(더블 폴트)
    
    var homePoint: String { _homePoint ?? "0" }
    var homePointType: Int { _homePointType ?? 0 }
    var awayPoint: String { _awayPoint ?? "0" }
    var awayPointType: Int { _awayPointType ?? 0 }
    var pointDescription: Int { _pointDescription ?? 0 }
    
    private enum CodingKeys: String, CodingKey {
        case _homePoint = "homePoint"
        case _homePointType = "homePointType"
        case _awayPoint = "awayPoint"
        case _awayPointType = "awayPointType"
        case _pointDescription = "pointDescription"
    }
}

struct TennisPointByPointGameScore: Decodable, Equatable {
    private let _homeScore: Int?
    private let _awayScore: Int?
    private let _scoring: Int? // 아직 게임이 안끝났으면 -1
    private let _serving: Int?
    
    var homeScore: Int { _homeScore ?? 0 }
    var awayScore: Int { _awayScore ?? 0 }
    var scoring: Int { _scoring ?? 0 }
    var serving: Int { _serving ?? 0 }
    
    var isHomeWinner: Bool { scoring == 1 }
    var isAwayWinner: Bool { scoring == 2 }
    var isGameFinished: Bool { scoring != -1 }
    var isHomeServing: Bool { serving == 1 }
    var isTieBreak: Bool {
        if isGameFinished {
            homeScore == 7 || awayScore == 7
        } else {
            homeScore == 6 && awayScore == 6
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case _homeScore = "homeScore"
        case _awayScore = "awayScore"
        case _scoring = "scoring"
        case _serving = "serving"
    }
}

struct TennisGameStats: Decodable, Equatable {
    let statisticsItems: [TennisGameStatsItem]?
    private let _groupName: String?
    
    var groupName: String { _groupName ?? "" }
    
    func itemsForDisplay() -> [TennisGameStatsItem] {
        guard let items = statisticsItems else {
            return []
        }
        
        return StringConstants.Tennis.playerStatKeyList.compactMap { key in
            items.first { $0.key == key }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case statisticsItems
        case _groupName = "groupName"
    }
}

struct TennisGameStatsItem: Decodable, Equatable {
    private let _key: String?
    private let _name: String?
    private let _home: String?
    private let _homeValue: Int?
    private let _homeTotal: Int?
    private let _away: String?
    private let _awayValue: Int?
    private let _awayTotal: Int?
    private let _compareCode: Int?
    private let _renderType: Int?
    private let _statisticsType: String?
    private let _valueType: String?
    
    var key: String { _key ?? "" }
    var name: String { _name ?? "" }
    var home: String { _home ?? "" }
    var homeValue: Int { _homeValue ?? 0 }
    var homeTotal: Int { _homeTotal ?? 0 }
    var away: String { _away ?? "" }
    var awayValue: Int { _awayValue ?? 0 }
    var awayTotal: Int { _awayTotal ?? 0 }
    var compareCode: Int { _compareCode ?? 0 }
    var renderType: Int { _renderType ?? 0 }
    var statisticsType: String { _statisticsType ?? "" }
    var valueType: String { _valueType ?? "" }
    
    var krname: String { StringConstants.Tennis.playerStatKrnameMap[key] ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case _key = "key"
        case _name = "name"
        case _home = "home"
        case _homeValue = "homeValue"
        case _homeTotal = "homeTotal"
        case _away = "away"
        case _awayValue = "awayValue"
        case _awayTotal = "awayTotal"
        case _compareCode = "compareCode"
        case _renderType = "renderType"
        case _statisticsType = "statisticsType"
        case _valueType = "valueType"
    }
}

struct TennisGameInfoForSchedule: Decodable, Equatable {
    let roundInfo: TennisGameRoundInfo?
    let homeTeam: TennisGameTeam?
    let awayTeam: TennisGameTeam?
    private let _winnerCode: Int?
    
    var winnerCode: Int { _winnerCode ?? -1 }
    var isGameFinished: Bool { winnerCode != -1 }
    var isHomeWinner: Bool { winnerCode == 1 }
    
    private enum CodingKeys: String, CodingKey {
        case roundInfo, homeTeam, awayTeam
        case _winnerCode = "winnerCode"
    }
    
    init(
        roundInfo: TennisGameRoundInfo?,
        homeTeam: TennisGameTeam?,
        awayTeam: TennisGameTeam?,
        winnerCode: Int?
    ) {
        self.roundInfo = roundInfo
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self._winnerCode = winnerCode
    }
}

typealias TennisGameForSchedule = GameForSchedule<TennisGameInfoForSchedule>
