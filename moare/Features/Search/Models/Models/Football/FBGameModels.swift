//
//  FootballGame.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/10/24.
//

import Foundation

struct FBGame: Decodable, Equatable {
    let fixture: FBGameFixture
    let league: FBLeague
    let teams: FBGameTeams
    let goals: FBHomeAwayIntStats
    let score: FBGameScore
    let lineups: [FBGameLineups]
    let statistics: [FBGameStats]
    let players: [FBGamePlayers]
}

struct FBGameFixture: Decodable, Equatable {
    private let _id: Int?
    private let _referee: String?
    private let _timezone: String?
    private let _date: String?
    private let _timestamp: Int?
    let periods: FBGamePeriods
    let venue: FBVenue
    let status: FBGameStatus

    var id: Int {
        return _id ?? 0
    }
    var referee: String {
        return _referee ?? ""
    }
    var timezone: String {
        return _timezone ?? ""
    }
    var date: String {
        return _date ?? ""
    }
    var timestamp: Int {
        return _timestamp ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _referee = "referee"
        case _timezone = "timezone"
        case _date = "date"
        case _timestamp = "timestamp"
        case periods, venue, status
    }
}

struct FBGamePeriods: Decodable, Equatable {
    private let _first: Int?
    private let _second: Int?
    
    var first: Int {
        return _first ?? 0
    }
    var second: Int {
        return _second ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _first = "first"
        case _second = "second"
    }
}

struct FBGameStatus: Decodable, Equatable {
    private let _long: String?
    private let _short: String?
    private let _elapsed: Int?
    private let _extra: Int?
    
    var long: String {
        return _long ?? ""
    }
    var short: String {
        return _short ?? ""
    }
    var elapsed: Int {
        return _elapsed ?? 0
    }
    var extra: Int {
        return _extra ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _long = "long"
        case _short = "short"
        case _elapsed = "elapsed"
        case _extra = "extra"
    }
}

struct FBGameTeams: Decodable, Equatable {
    let home: FBTeamInfo
    let away: FBTeamInfo
}

struct FBGameScore: Decodable, Equatable {
    let halftime: FBHomeAwayIntStats
    let fulltime: FBHomeAwayIntStats
    let extratime: FBHomeAwayIntStats
    let penalty: FBHomeAwayIntStats
}

struct FBGameLineups: Decodable, Equatable {
    let team: FBTeamInfo
    let coach: FBPerson
    private let _formation: String?
    let startXI: [FBGameStartXI]
    let substitutes: [FBGameStartXI]
    
    var formation: String {
        return _formation ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case team, coach, startXI, substitutes
        case _formation = "formation"
    }
}

struct FBGameColors: Decodable, Equatable {
    let player: FBGameColorDetail
    let goalkeeper: FBGameColorDetail
}

struct FBGameColorDetail: Decodable, Equatable {
    private let _primary: String?
    private let _number: String?
    private let _border: String?

    var primary: String {
        return _primary ?? ""
    }
    var number: String {
        return _number ?? ""
    }
    var border: String {
        return _border ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case _primary = "primary"
        case _number = "number"
        case _border = "border"
    }
}

struct FBGameStartXI: Decodable, Equatable {
    let player: FBGamePlayer
}

struct FBGamePlayer: Decodable, Equatable {
    private let _id: Int?
    private let _name: String?
    private let _number: Int?
    private let _pos: String?
    private let _grid: String?

    var id: Int {
        return _id ?? 0
    }
    var name: String {
        return _name ?? ""
    }
    var number: Int {
        return _number ?? 0
    }
    var pos: String {
        return _pos ?? ""
    }
    var grid: String {
        return _grid ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _number = "number"
        case _pos = "pos"
        case _grid = "grid"
    }
}

struct FBGameStats: Decodable, Equatable {
    let team: FBTeamInfo
    let statistics: [FBGameTeamStats]
}

struct FBGameTeamStats: Decodable, Equatable {
    private let _type: String?
    let value: StatValue
    
    var type: String {
        return _type ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case _type = "type"
        case value
    }
    
//    static func == (lhs: FootballGameTeamStats, rhs: FootballGameTeamStats) -> Bool {
//        guard lhs.type == rhs.type else { return false }
//        
//        if let lhsValue = lhs.value as? String, let rhsValue = rhs.value as? String {
//            return lhsValue == rhsValue
//        } else if let lhsValue = lhs.value as? Int, let rhsValue = rhs.value as? Int {
//            return lhsValue == rhsValue
//        } else if lhs.value == nil && rhs.value == nil {
//            return true
//        }
//        return false
//    }
}

struct FBGamePlayers: Decodable, Equatable {
    let team: FBTeamInfo
    let players: [FBGamePlayerStats]
}

struct FBGamePlayerStats: Decodable, Equatable {
    let player: FBPerson
    let statistics: [FBGamePlayerStatsDetail]
}

struct FBGamePlayerStatsDetail: Decodable, Equatable {
    let games: FBGamePlayerStatsGames
    private let _offsides: Int?
    let shots: FBPlayerStatsShots
    let goals: FBPlayerStatsGoals
    let passes: FBGamePlayerStatsPasses
    let tackles: FBPlayerStatsTackles
    let duels: FBPlayerStatsDuels
    let dribbles: FBPlayerStatsDribbles
    let fouls: FBPlayerStatsFouls
    let cards: FBPlayerStatsCards
    let penalty: FBPlayerStatsPenalty

    var offsides: Int {
        return _offsides ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case games, shots, goals, passes, tackles, duels, dribbles, fouls, cards, penalty
        case _offsides = "offsides"
    }
    
    init(
        games: FBGamePlayerStatsGames = FBGamePlayerStatsGames(),
        offsides: Int = 0,
        shots: FBPlayerStatsShots = FBPlayerStatsShots(),
        goals: FBPlayerStatsGoals = FBPlayerStatsGoals(),
        passes: FBGamePlayerStatsPasses = FBGamePlayerStatsPasses(),
        tackles: FBPlayerStatsTackles = FBPlayerStatsTackles(),
        duels: FBPlayerStatsDuels = FBPlayerStatsDuels(),
        dribbles: FBPlayerStatsDribbles = FBPlayerStatsDribbles(),
        fouls: FBPlayerStatsFouls = FBPlayerStatsFouls(),
        cards: FBPlayerStatsCards = FBPlayerStatsCards(),
        penalty: FBPlayerStatsPenalty = FBPlayerStatsPenalty()
    ) {
        self.games = games
        self._offsides = offsides
        self.shots = shots
        self.goals = goals
        self.passes = passes
        self.tackles = tackles
        self.duels = duels
        self.dribbles = dribbles
        self.fouls = fouls
        self.cards = cards
        self.penalty = penalty
    }
}

struct FBGamePlayerStatsPasses: Decodable, Equatable {
    private let _total: Int?
    private let _key: Int?
    private let _accuracy: String?
    
    var total: Int {
        return _total ?? 0
    }
    var key: Int {
        return _key ?? 0
    }
    var accuracy: String {
        return _accuracy ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case _total = "total"
        case _key = "key"
        case _accuracy = "accuracy"
    }
    
    init(total: Int = 0, key: Int = 0, accuracy: String = "") {
        self._total = total
        self._key = key
        self._accuracy = accuracy
    }
}

struct FBGamePlayerStatsGames: Decodable, Equatable {
    private let _minutes: Int?
    private let _number: Int?
    private let _position: String?
    private let _rating: String?
    private let _captain: Bool?
    private let _substitute: Bool?

    var minutes: Int {
        return _minutes ?? 0
    }
    var number: Int {
        return _number ?? 0
    }
    var position: String {
        return _position ?? ""
    }
    var rating: String {
        return _rating ?? "0"
    }
    var captain: Bool {
        return _captain ?? false
    }
    var substitute: Bool {
        return _substitute ?? false
    }
    
    private enum CodingKeys: String, CodingKey {
        case _minutes = "minutes"
        case _number = "number"
        case _position = "position"
        case _rating = "rating"
        case _captain = "captain"
        case _substitute = "substitute"
    }
    
    init(
        minutes: Int = 0,
        number: Int = 0,
        position: String = "",
        rating: String = "0",
        captain: Bool = false,
        substitute: Bool = false
    ) {
        self._minutes = minutes
        self._number = number
        self._position = position
        self._rating = rating
        self._captain = captain
        self._substitute = substitute
    }
}

enum StatValue: Decodable, Equatable {
    case intValue(Int)
    case doubleValue(Double)
    case stringValue(String)
    case boolValue(Bool)
    case none

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .intValue(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .doubleValue(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .stringValue(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .boolValue(boolValue)
        } else {
            self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .intValue(let intValue):
            try container.encode(intValue)
        case .doubleValue(let doubleValue):
            try container.encode(doubleValue)
        case .stringValue(let stringValue):
            try container.encode(stringValue)
        case .boolValue(let boolValue):
            try container.encode(boolValue)
        case .none:
            try container.encodeNil()
        }
    }
}
