//
//  MLBGameModels.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBGame: Decodable, Equatable {
    let boxscore: MLBGameBoxScore?
    let decisions: MLBGameDecisions?
    let game: MLBGameData
    let gameInfo: MLBGameInfo
    let linescore: MLBGameLineScore
    let moundVisits: MLBGameMoundVisits
    let probablePitchers: MLBGameProbablePitchers
    let review: MLBGameReview
    let status: MLBGameStatus
    let teams: MLBGameTeams
    let weather: MLBGameWeather
}

struct MLBGameBoxScore: Decodable, Equatable {
    let info: [MLBLabelObj]?
    let officials: [MLBGameBoxScoreOfficial]
    let teams: MLBGameBoxscoreTeams
}

struct MLBGameBoxScoreOfficial: Decodable, Equatable {
    let official: MLBFullNameObj
    private let _officialType: String?
    
    var officialTyle: String { _officialType ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case official
        case _officialType = "officialType"
    }
}

struct MLBGameBoxscoreTeams: Decodable, Equatable {
    let away: MLBGameBoxscoreTeamData
    let home: MLBGameBoxscoreTeamData
}

struct MLBGameBoxscoreTeamData: Decodable, Equatable {
    private let _batters: [Int]?
    private let _battingOrder: [Int]?
    private let _bench: [Int]?
    private let _bullpen: [Int]?
    private let _info: [MLBGameBoxscoreTeamInfo]?
    private let _pitchers: [Int]?
    private let _players: [String: MLBGameBoxscoreTeamPlayer]?
    let team: MLBGameBoxsocreTeamInfo?
//    let teamStats: MLBGameBoxscoreStats? // NOTE: EXC_BAD_ACCESS 발생

    var batters: [Int] { _batters ?? [] }
    var battingOrder: [Int] { _battingOrder ?? [] }
    var bench: [Int] { _bench ?? [] }
    var bullpen: [Int] { _bullpen ?? [] }
    var info: [MLBGameBoxscoreTeamInfo] { _info ?? [] }
    var pitchers: [Int] { _pitchers ?? [] }
    var players: [String: MLBGameBoxscoreTeamPlayer] { _players ?? [:] }

    private enum CodingKeys: String, CodingKey {
        case _batters = "batters"
        case _battingOrder = "battingOrder"
        case _bench = "bench"
        case _bullpen = "bullpen"
        case _info = "info"
        case _pitchers = "pitchers"
        case _players = "players"
//        case team, teamStats
        case team
    }
}

struct MLBGameBoxscoreTeamInfo: Decodable, Equatable {
    private let _fieldList: [MLBLabelObj]?
    private let _title: String?

    var fieldList: [MLBLabelObj] { _fieldList ?? [] }
    var title: String { _title ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _fieldList = "fieldList"
        case _title = "title"
    }
}

struct MLBGameBoxscoreTeamPlayer: Decodable, Equatable {
    let gameStatus: MLBGameBoxscorePlayerStatus?
    private let _jerseyNumber: String?
    private let _parentTeamId: Int?
    let person: MLBFullNameObj?
    let position: MLBAbbreviationCodeObj?
    let seasonStats: MLBGameBoxscoreStats?
    let stats: MLBGameBoxscoreStats?
    let status: MLBCodeObj?
    private let _battingOrder: String?
    private let _allPositions: [MLBAbbreviationCodeObj]?

    var jerseyNumber: String { _jerseyNumber ?? "" }
    var parentTeamId: Int { _parentTeamId ?? 0 }
    var battingOrder: String { _battingOrder ?? "" }
    var allPositions: [MLBAbbreviationCodeObj] { _allPositions ?? [] }

    private enum CodingKeys: String, CodingKey {
        case gameStatus, person, position, seasonStats, stats, status
        case _jerseyNumber = "jerseyNumber"
        case _parentTeamId = "parentTeamId"
        case _battingOrder = "battingOrder"
        case _allPositions = "allPositions"
    }
}

struct MLBGameBoxscorePlayerStatus: Decodable, Equatable {
    private let _isCurrentBatter: Bool?
    private let _isCurrentPitcher: Bool?
    private let _isOnBench: Bool?
    private let _isSubstitute: Bool?

    var isCurrentBatter: Bool { _isCurrentBatter ?? false }
    var isCurrentPitcher: Bool { _isCurrentPitcher ?? false }
    var isOnBench: Bool { _isOnBench ?? false }
    var isSubstitute: Bool { _isSubstitute ?? false }

    private enum CodingKeys: String, CodingKey {
        case _isCurrentBatter = "isCurrentBatter"
        case _isCurrentPitcher = "isCurrentPitcher"
        case _isOnBench = "isOnBench"
        case _isSubstitute = "isSubstitute"
    }
}

struct MLBGameBoxscoreStats: Decodable, Equatable {
    let batting: MLBPlayerHittingStats?
//    let fielding: MLBPlayerFieldingStats?
    let pitching: MLBPlayerPitchingStats?
}

struct MLBGameBoxsocreTeamInfo: Decodable, Equatable {
    private let _allStarStatus: String?
    private let _id: Int?
    private let _link: String?
    private let _name: String?
    let springLeague: MLBAbbreviationIdObj?

    var allStarStatus: String { _allStarStatus ?? "" }
    var id: Int { _id ?? 0 }
    var link: String { _link ?? "" }
    var name: String { _name ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _allStarStatus = "allStarStatus"
        case _id = "id"
        case _link = "link"
        case _name = "name"
        case springLeague
    }
}

struct MLBGameDecisions: Decodable, Equatable {
    let loser: MLBFullNameObj
    let save: MLBFullNameObj?
    let winner: MLBFullNameObj
}

struct MLBGameData: Decodable, Equatable {
    private let _calendarEventID: String?
    private let _doubleHeader: String?
    private let _gamedayType: String?
    private let _gameNumber: Int?
    private let _id: String?
    private let _pk: Int?
    private let _season: String?
    private let _seasonDisplay: String?
    private let _tiebreaker: String?
    private let _type: String?

    var calendarEventID: String { _calendarEventID ?? "" }
    var doubleHeader: String { _doubleHeader ?? "" }
    var gamedayType: String { _gamedayType ?? "" }
    var gameNumber: Int { _gameNumber ?? 0 }
    var id: String { _id ?? "" }
    var pk: Int { _pk ?? 0 }
    var season: String { _season ?? "" }
    var seasonDisplay: String { _seasonDisplay ?? "" }
    var tiebreaker: String { _tiebreaker ?? "" }
    var type: String { _type ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _calendarEventID = "calendarEventID"
        case _doubleHeader = "doubleHeader"
        case _gamedayType = "gamedayType"
        case _gameNumber = "gameNumber"
        case _id = "id"
        case _pk = "pk"
        case _season = "season"
        case _seasonDisplay = "seasonDisplay"
        case _tiebreaker = "tiebreaker"
        case _type = "type"
    }
}

struct MLBGameInfo: Decodable, Equatable {
    private let _attendance: Int?
    private let _firstPitch: String?
    private let _gameDurationMinutes: Int?
    private let _gameDate: String?

    var attendance: Int { _attendance ?? 0 }
    var firstPitch: String { _firstPitch ?? "" }
    var gameDurationMinutes: Int { _gameDurationMinutes ?? 0 }
    var gameDate: String { _gameDate ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _attendance = "attendance"
        case _firstPitch = "firstPitch"
        case _gameDurationMinutes = "gameDurationMinutes"
        case _gameDate = "gameDate"
    }
}

struct MLBGameLineScore: Decodable, Equatable {
    private let _balls: Int?
    private let _currentInning: Int?
    private let _currentInningOrdinal: String?
    let defense: MLBGameLineScoreDefense?
    private let _inningHalf: String?
    let innings: [MLBGameLineScoreInning]
    private let _inningState: String?
    private let _isTopInning: Bool?
    let offense: MLBGameLineScoreDefense?
    private let _outs: Int?
    private let _scheduledInnings: Int?
    private let _strikes: Int?
    let teams: MLBGameLineScoreTeams

    var balls: Int { _balls ?? 0 }
    var currentInning: Int { _currentInning ?? 0 }
    var currentInningOrdinal: String { _currentInningOrdinal ?? "" }
    var inningHalf: String { _inningHalf ?? "" }
    var inningState: String { _inningState ?? "" }
    var isTopInning: Bool { _isTopInning ?? false }
    var outs: Int { _outs ?? 0 }
    var scheduledInnings: Int { _scheduledInnings ?? 0 }
    var strikes: Int { _strikes ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _balls = "balls"
        case _currentInning = "currentInning"
        case _currentInningOrdinal = "currentInningOrdinal"
        case defense
        case _inningHalf = "inningHalf"
        case innings
        case _inningState = "inningState"
        case _isTopInning = "isTopInning"
        case offense
        case _outs = "outs"
        case _scheduledInnings = "scheduledInnings"
        case _strikes = "strikes"
        case teams
    }
}

struct MLBGameLineScoreDefense: Decodable, Equatable {
    let batter: MLBFullNameObj?
    private let _battingOrder: Int?
    let onDeck: MLBFullNameObj?
    let inHole: MLBFullNameObj?
    let pitcher: MLBFullNameObj?
    let team: MLBNameObj
    let catcher: MLBFullNameObj?
    let center: MLBFullNameObj?
    let first: MLBFullNameObj?
    let left: MLBFullNameObj?
    let right: MLBFullNameObj?
    let second: MLBFullNameObj?
    let shortstop: MLBFullNameObj?
    let third: MLBFullNameObj?

    var battingOrder: Int { _battingOrder ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case batter
        case _battingOrder = "battingOrder"
        case onDeck
        case inHole
        case pitcher
        case team
        case catcher
        case center
        case first
        case left
        case right
        case second
        case shortstop
        case third
    }
}

struct MLBGameLineScoreInning: Decodable, Equatable {
    let away: MLBGameLineScoreStats
    let home: MLBGameLineScoreStats
    private let _num: Int?
    private let _ordinalNum: String?

    var num: Int { _num ?? 0 }
    var ordinalNum: String { _ordinalNum ?? "" }

    private enum CodingKeys: String, CodingKey {
        case away
        case home
        case _num = "num"
        case _ordinalNum = "ordinalNum"
    }
}

struct MLBGameLineScoreStats: Decodable, Equatable {
    private let _errors: Int?
    private let _hits: Int?
    private let _leftOnBase: Int?
    private let _runs: Int?

    var errors: Int { _errors ?? 0 }
    var hits: Int { _hits ?? 0 }
    var leftOnBase: Int { _leftOnBase ?? 0 }
    var runs: Int { _runs ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _errors = "errors"
        case _hits = "hits"
        case _leftOnBase = "leftOnBase"
        case _runs = "runs"
    }
}

struct MLBGameLineScoreTeams: Decodable, Equatable {
    let away: MLBGameLineScoreStats
    let home: MLBGameLineScoreStats
}

struct MLBGameMoundVisits: Decodable, Equatable {
    let away: MLBGameRemainingUsed
    let home: MLBGameRemainingUsed
}

struct MLBGameRemainingUsed: Decodable, Equatable {
    private let _remaining: Int?
    private let _used: Int?

    var remaining: Int { _remaining ?? 0 }
    var used: Int { _used ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _remaining = "remaining"
        case _used = "used"
    }
}

struct MLBGameProbablePitchers: Decodable, Equatable {
    let away: MLBFullNameObj?
    let home: MLBFullNameObj?
}

struct MLBGameReview: Decodable, Equatable {
    let away: MLBGameRemainingUsed
    let home: MLBGameRemainingUsed
    private let _hasChallenges: Bool?

    var hasChallenges: Bool { _hasChallenges ?? false }

    private enum CodingKeys: String, CodingKey {
        case away, home
        case _hasChallenges = "hasChallenges"
    }
}

struct MLBGameStatus: Decodable, Equatable {
    private let _abstractGameCode: String?
    private let _abstractGameState: String?
    private let _codedGameState: String?
    private let _detailedState: String?
    private let _startTimeTBD: Bool?
    private let _statusCode: String?

    var abstractGameCode: String { _abstractGameCode ?? "" }
    var abstractGameState: String { _abstractGameState ?? "" }
    var codedGameState: String { _codedGameState ?? "" }
    var detailedState: String { _detailedState ?? "" }
    var startTimeTBD: Bool { _startTimeTBD ?? false }
    var statusCode: String { _statusCode ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _abstractGameCode = "abstractGameCode"
        case _abstractGameState = "abstractGameState"
        case _codedGameState = "codedGameState"
        case _detailedState = "detailedState"
        case _startTimeTBD = "startTimeTBD"
        case _statusCode = "statusCode"
    }
}

struct MLBGameTeams: Decodable, Equatable {
    let away: MLBGameTeamDetail
    let home: MLBGameTeamDetail
}

struct MLBGameTeamDetail: Decodable, Equatable {
    private let _abbreviation: String?
    private let _allStarStatus: String?
    private let _clubName: String?
    let division: MLBNameObj
    private let _franchiseName: String?
    private let _id: Int?
    let league: MLBNameObj
    private let _locationName: String?
    private let _name: String?
    let record: MLBGameTeamRecord?
    private let _season: Int?
    private let _shortName: String?
    private let _teamCode: String?
    private let _teamName: String?

    var abbreviation: String { _abbreviation ?? "" }
    var allStarStatus: String { _allStarStatus ?? "" }
    var clubName: String { _clubName ?? "" }
    var franchiseName: String { _franchiseName ?? "" }
    var id: Int { _id ?? 0 }
    var locationName: String { _locationName ?? "" }
    var name: String { _name ?? "" }
    var season: Int { _season ?? 0 }
    var shortName: String { _shortName ?? "" }
    var teamCode: String { _teamCode ?? "" }
    var teamName: String { _teamName ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _abbreviation = "abbreviation"
        case _allStarStatus = "allStarStatus"
        case _clubName = "clubName"
        case division
        case _franchiseName = "franchiseName"
        case _id = "id"
        case league
        case _locationName = "locationName"
        case _name = "name"
        case record
        case _season = "season"
        case _shortName = "shortName"
        case _teamCode = "teamCode"
        case _teamName = "teamName"
    }
}

struct MLBGameTeamRecord: Decodable, Equatable {
    private let _conferenceGamesBack: String?
    private let _divisionGamesBack: String?
    private let _divisionLeader: Bool?
    private let _gamesPlayed: Int?
    private let _leagueGamesBack: String?
    let leagueRecord: MLBGameTeamLeagueRecord
    private let _losses: Int?
    // private let _records: [String: String]?
    private let _sportGamesBack: String?
    private let _springLeagueGamesBack: String?
    private let _wildCardGamesBack: String?
    private let _winningPercentage: String?
    private let _wins: Int?

    var conferenceGamesBack: String { _conferenceGamesBack ?? "-" }
    var divisionGamesBack: String { _divisionGamesBack ?? "-" }
    var divisionLeader: Bool { _divisionLeader ?? false }
    var gamesPlayed: Int { _gamesPlayed ?? 0 }
    var leagueGamesBack: String { _leagueGamesBack ?? "-" }
    var losses: Int { _losses ?? 0 }
    // var records: [String: String] { _records ?? [:] }
    var sportGamesBack: String { _sportGamesBack ?? "-" }
    var springLeagueGamesBack: String { _springLeagueGamesBack ?? "-" }
    var wildCardGamesBack: String { _wildCardGamesBack ?? "-" }
    var winningPercentage: String { _winningPercentage ?? "" }
    var wins: Int { _wins ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _conferenceGamesBack = "conferenceGamesBack"
        case _divisionGamesBack = "divisionGamesBack"
        case _divisionLeader = "divisionLeader"
        case _gamesPlayed = "gamesPlayed"
        case _leagueGamesBack = "leagueGamesBack"
        case leagueRecord
        case _losses = "losses"
        // case _records = "records"
        case _sportGamesBack = "sportGamesBack"
        case _springLeagueGamesBack = "springLeagueGamesBack"
        case _wildCardGamesBack = "wildCardGamesBack"
        case _winningPercentage = "winningPercentage"
        case _wins = "wins"
    }
}

struct MLBGameTeamLeagueRecord: Decodable, Equatable {
    private let _losses: Int?
    private let _pct: String?
    private let _ties: Int?
    private let _wins: Int?

    var losses: Int { _losses ?? 0 }
    var pct: String { _pct ?? "" }
    var ties: Int { _ties ?? 0 }
    var wins: Int { _wins ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _losses = "losses"
        case _pct = "pct"
        case _ties = "ties"
        case _wins = "wins"
    }
}

struct MLBGameWeather: Decodable, Equatable {
    private let _condition: String?
    private let _temp: String?
    private let _wind: String?

    var condition: String { _condition ?? "" }
    var temp: String { _temp ?? "" }
    var wind: String { _wind ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _condition = "condition"
        case _temp = "temp"
        case _wind = "wind"
    }
}

struct MLBGameInfoForSchedule: Decodable, Equatable {
    private let _currentInning: Int?

    var currentInning: Int {
        return _currentInning ?? 0
    }

    private enum CodingKeys: String, CodingKey {
        case _currentInning = "currentInning"
    }
    
    init(
        currentInning: Int?
    ) {
        self._currentInning = currentInning
    }
}

typealias MLBGameForSchedule = GameForSchedule<MLBGameInfoForSchedule>
