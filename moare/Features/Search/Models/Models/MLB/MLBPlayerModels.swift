//
//  MLBPlayerModels.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBPlayer: Decodable, Equatable {
    let player: MLBPlayerInfo
    let statistics: [MLBPlayerStats]
}

struct MLBPlayerInfo: Decodable, Equatable {
    private let _active: Bool?
    let batSide: MLBCodeObj
    private let _birthCity: String?
    private let _birthCountry: String?
    private let _birthDate: String?
    private let _birthStateProvince: String?
    private let _boxscoreName: String?
    private let _currentAge: Int?
    private let _draftYear: Int?
    private let _firstLastName: String?
    private let _firstName: String?
    private let _fullFMLName: String?
    private let _fullLFMName: String?
    private let _fullName: String?
    private let _height: String?
    private let _id: Int?
    private let _initLastName: String?
    private let _isPlayer: Bool?
    private let _isVerified: Bool?
    private let _lastFirstName: String?
    private let _lastInitName: String?
    private let _lastName: String?
    private let _link: String?
    private let _middleName: String?
    private let _mlbDebutDate: String?
    private let _nameFirstLast: String?
    let pitchHand: MLBCodeObj
    private let _primaryNumber: String?
    let primaryPosition: MLBAbbreviationCodeObj
    private let _strikeZoneBottom: Double?
    private let _strikeZoneTop: Double?
    private let _useLastName: String?
    private let _useName: String?
    private let _weight: Int?

    var active: Bool { _active ?? false }
    var birthCity: String { _birthCity ?? "" }
    var birthCountry: String { _birthCountry ?? "" }
    var birthDate: String { _birthDate ?? "" }
    var birthStateProvince: String { _birthStateProvince ?? "" }
    var boxscoreName: String { _boxscoreName ?? "" }
    var currentAge: Int { _currentAge ?? 0 }
    var draftYear: Int { _draftYear ?? 0 }
    var firstLastName: String { _firstLastName ?? "" }
    var firstName: String { _firstName ?? "" }
    var fullFMLName: String { _fullFMLName ?? "" }
    var fullLFMName: String { _fullLFMName ?? "" }
    var fullName: String { _fullName ?? "" }
    var height: String { _height ?? "" }
    var id: Int { _id ?? 0 }
    var initLastName: String { _initLastName ?? "" }
    var isPlayer: Bool { _isPlayer ?? false }
    var isVerified: Bool { _isVerified ?? false }
    var lastFirstName: String { _lastFirstName ?? "" }
    var lastInitName: String { _lastInitName ?? "" }
    var lastName: String { _lastName ?? "" }
    var link: String { _link ?? "" }
    var middleName: String { _middleName ?? "" }
    var mlbDebutDate: String { _mlbDebutDate ?? "" }
    var nameFirstLast: String { _nameFirstLast ?? "" }
    var primaryNumber: String { _primaryNumber ?? "" }
    var strikeZoneBottom: Double { _strikeZoneBottom ?? 0.0 }
    var strikeZoneTop: Double { _strikeZoneTop ?? 0.0 }
    var useLastName: String { _useLastName ?? "" }
    var useName: String { _useName ?? "" }
    var weight: Int { _weight ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _active = "active"
        case batSide
        case _birthCity = "birthCity"
        case _birthCountry = "birthCountry"
        case _birthDate = "birthDate"
        case _birthStateProvince = "birthStateProvince"
        case _boxscoreName = "boxscoreName"
        case _currentAge = "currentAge"
        case _draftYear = "draftYear"
        case _firstLastName = "firstLastName"
        case _firstName = "firstName"
        case _fullFMLName = "fullFMLName"
        case _fullLFMName = "fullLFMName"
        case _fullName = "fullName"
        case _height = "height"
        case _id = "id"
        case _initLastName = "initLastName"
        case _isPlayer = "isPlayer"
        case _isVerified = "isVerified"
        case _lastFirstName = "lastFirstName"
        case _lastInitName = "lastInitName"
        case _lastName = "lastName"
        case _link = "link"
        case _middleName = "middleName"
        case _mlbDebutDate = "mlbDebutDate"
        case _nameFirstLast = "nameFirstLast"
        case pitchHand
        case _primaryNumber = "primaryNumber"
        case primaryPosition
        case _strikeZoneBottom = "strikeZoneBottom"
        case _strikeZoneTop = "strikeZoneTop"
        case _useLastName = "useLastName"
        case _useName = "useName"
        case _weight = "weight"
    }
}

struct MLBPlayerStats: Decodable, Equatable {
    private let _type: String?
    let fielding: MLBPlayerFieldingData?
    let hitting: MLBPlayerHittingData?
    let pitching: MLBPlayerPitchingData?
    let catching: MLBPlayerCatchingData?

    var type: String { _type ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _type = "type"
        case fielding, hitting, pitching, catching
    }
}

struct MLBPlayerFieldingData: Decodable, Equatable {
    private let _gameType: String?
    let league: MLBNameObj
    let position: MLBPlayerPosition
    private let _season: String?
    let sport: MLBAbbreviationIdObj
    let stat: MLBPlayerFieldingStats
    let team: MLBNameObj

    var gameType: String { _gameType ?? "" }
    var season: String { _season ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _gameType = "gameType"
        case league, position, _season = "season", sport, stat, team
    }
}

struct MLBPlayerPosition: Decodable, Equatable {
    private let _abbreviation: String?
    private let _code: String?
    private let _name: String?
    private let _type: String?

    var abbreviation: String { _abbreviation ?? "" }
    var code: String { _code ?? "" }
    var name: String { _name ?? "" }
    var type: String { _type ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _abbreviation = "abbreviation"
        case _code = "code"
        case _name = "name"
        case _type = "type"
    }
}

struct MLBPlayerFieldingStats: Decodable, Equatable {
    private let _assists: Int?
    private let _chances: Int?
    private let _doublePlays: Int?
    private let _errors: Int?
    private let _fielding: String?
    private let _games: Int?
    private let _gamesPlayed: Int?
    private let _gamesStarted: Int?
    private let _innings: String?
    let position: MLBPlayerPosition
    private let _putOuts: Int?
    private let _rangeFactorPer9Inn: String?
    private let _rangeFactorPerGame: String?
    private let _throwingErrors: Int?
    private let _triplePlays: Int?

    var assists: Int { _assists ?? 0 }
    var chances: Int { _chances ?? 0 }
    var doublePlays: Int { _doublePlays ?? 0 }
    var errors: Int { _errors ?? 0 }
    var fielding: String { _fielding ?? "" }
    var games: Int { _games ?? 0 }
    var gamesPlayed: Int { _gamesPlayed ?? 0 }
    var gamesStarted: Int { _gamesStarted ?? 0 }
    var innings: String { _innings ?? "" }
    var putOuts: Int { _putOuts ?? 0 }
    var rangeFactorPer9Inn: String { _rangeFactorPer9Inn ?? "" }
    var rangeFactorPerGame: String { _rangeFactorPerGame ?? "" }
    var throwingErrors: Int { _throwingErrors ?? 0 }
    var triplePlays: Int { _triplePlays ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _assists = "assists"
        case _chances = "chances"
        case _doublePlays = "doublePlays"
        case _errors = "errors"
        case _fielding = "fielding"
        case _games = "games"
        case _gamesPlayed = "gamesPlayed"
        case _gamesStarted = "gamesStarted"
        case _innings = "innings"
        case position
        case _putOuts = "putOuts"
        case _rangeFactorPer9Inn = "rangeFactorPer9Inn"
        case _rangeFactorPerGame = "rangeFactorPerGame"
        case _throwingErrors = "throwingErrors"
        case _triplePlays = "triplePlays"
    }
}

struct MLBPlayerHittingData: Decodable, Equatable {
    private let _gameType: String?
    let league: MLBNameObj
    private let _season: String?
    let sport: MLBAbbreviationIdObj
    let stat: MLBPlayerHittingStats
    let team: MLBNameObj

    var gameType: String { _gameType ?? "" }
    var season: String { _season ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _gameType = "gameType"
        case league
        case _season = "season"
        case sport
        case stat
        case team
    }
}

struct MLBPlayerHittingStats: Decodable, Equatable {
    private let _airOuts: Int?
    private let _atBats: Int?
    private let _atBatsPerHomeRun: String?
    private let _avg: String?
    private let _babip: String?
    private let _baseOnBalls: Int?
    private let _catchersInterference: Int?
    private let _caughtStealing: Int?
    private let _doubles: Int?
    private let _gamesPlayed: Int?
    private let _groundIntoDoublePlay: Int?
    private let _groundOuts: Int?
    private let _groundOutsToAirouts: String?
    private let _hitByPitch: Int?
    private let _hits: Int?
    private let _homeRuns: Int?
    private let _intentionalWalks: Int?
    private let _leftOnBase: Int?
    private let _numberOfPitches: Int?
    private let _obp: String?
    private let _ops: String?
    private let _plateAppearances: Int?
    private let _rbi: Int?
    private let _runs: Int?
    private let _sacBunts: Int?
    private let _sacFlies: Int?
    private let _slg: String?
    private let _stolenBasePercentage: String?
    private let _stolenBases: Int?
    private let _strikeOuts: Int?
    private let _totalBases: Int?
    private let _triples: Int?

    var airOuts: Int { _airOuts ?? 0 }
    var atBats: Int { _atBats ?? 0 }
    var atBatsPerHomeRun: String { _atBatsPerHomeRun ?? "" }
    var avg: String { _avg ?? "" }
    var babip: String { _babip ?? "" }
    var baseOnBalls: Int { _baseOnBalls ?? 0 }
    var catchersInterference: Int { _catchersInterference ?? 0 }
    var caughtStealing: Int { _caughtStealing ?? 0 }
    var doubles: Int { _doubles ?? 0 }
    var gamesPlayed: Int { _gamesPlayed ?? 0 }
    var groundIntoDoublePlay: Int { _groundIntoDoublePlay ?? 0 }
    var groundOuts: Int { _groundOuts ?? 0 }
    var groundOutsToAirouts: String { _groundOutsToAirouts ?? "" }
    var hitByPitch: Int { _hitByPitch ?? 0 }
    var hits: Int { _hits ?? 0 }
    var homeRuns: Int { _homeRuns ?? 0 }
    var intentionalWalks: Int { _intentionalWalks ?? 0 }
    var leftOnBase: Int { _leftOnBase ?? 0 }
    var numberOfPitches: Int { _numberOfPitches ?? 0 }
    var obp: String { _obp ?? "" }
    var ops: String { _ops ?? "" }
    var plateAppearances: Int { _plateAppearances ?? 0 }
    var rbi: Int { _rbi ?? 0 }
    var runs: Int { _runs ?? 0 }
    var sacBunts: Int { _sacBunts ?? 0 }
    var sacFlies: Int { _sacFlies ?? 0 }
    var slg: String { _slg ?? "" }
    var stolenBasePercentage: String { _stolenBasePercentage ?? "" }
    var stolenBases: Int { _stolenBases ?? 0 }
    var strikeOuts: Int { _strikeOuts ?? 0 }
    var totalBases: Int { _totalBases ?? 0 }
    var triples: Int { _triples ?? 0 }
    
    // 타석당 평균 투구 수
    // numberOfPitches / plateAppearances

    private enum CodingKeys: String, CodingKey {
        case _airOuts = "airOuts"
        case _atBats = "atBats"
        case _atBatsPerHomeRun = "atBatsPerHomeRun"
        case _avg = "avg"
        case _babip = "babip"
        case _baseOnBalls = "baseOnBalls"
        case _catchersInterference = "catchersInterference"
        case _caughtStealing = "caughtStealing"
        case _doubles = "doubles"
        case _gamesPlayed = "gamesPlayed"
        case _groundIntoDoublePlay = "groundIntoDoublePlay"
        case _groundOuts = "groundOuts"
        case _groundOutsToAirouts = "groundOutsToAirouts"
        case _hitByPitch = "hitByPitch"
        case _hits = "hits"
        case _homeRuns = "homeRuns"
        case _intentionalWalks = "intentionalWalks"
        case _leftOnBase = "leftOnBase"
        case _numberOfPitches = "numberOfPitches"
        case _obp = "obp"
        case _ops = "ops"
        case _plateAppearances = "plateAppearances"
        case _rbi = "rbi"
        case _runs = "runs"
        case _sacBunts = "sacBunts"
        case _sacFlies = "sacFlies"
        case _slg = "slg"
        case _stolenBasePercentage = "stolenBasePercentage"
        case _stolenBases = "stolenBases"
        case _strikeOuts = "strikeOuts"
        case _totalBases = "totalBases"
        case _triples = "triples"
    }
}

struct MLBPlayerPitchingData: Decodable, Equatable {
    private let _gameType: String?
    let league: MLBNameObj
    private let _season: String?
    let sport: MLBAbbreviationIdObj
    let stat: MLBPlayerPitchingStats
    let team: MLBNameObj

    var gameType: String { _gameType ?? "" }
    var season: String { _season ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _gameType = "gameType"
        case league
        case _season = "season"
        case sport
        case stat
        case team
    }
}

struct MLBPlayerPitchingStats: Decodable, Equatable {
    private let _airOuts: Int?
    private let _atBats: Int?
    private let _avg: String?
    private let _balks: Int?
    private let _baseOnBalls: Int?
    private let _battersFaced: Int?
    private let _blownSaves: Int?
    private let _catchersInterference: Int?
    private let _caughtStealing: Int?
    private let _completeGames: Int?
    private let _doubles: Int?
    private let _earnedRuns: Int?
    private let _era: String?
    private let _gamesFinished: Int?
    private let _gamesPitched: Int?
    private let _gamesPlayed: Int?
    private let _gamesStarted: Int?
    private let _groundIntoDoublePlay: Int?
    private let _groundOuts: Int?
    private let _groundOutsToAirouts: String?
    private let _hitBatsmen: Int?
    private let _hitByPitch: Int?
    private let _hits: Int?
    private let _hitsPer9Inn: String?
    private let _holds: Int?
    private let _homeRuns: Int?
    private let _homeRunsPer9: String?
    private let _inheritedRunners: Int?
    private let _inheritedRunnersScored: Int?
    private let _inningsPitched: String?
    private let _intentionalWalks: Int?
    private let _losses: Int?
    private let _numberOfPitches: Int?
    private let _obp: String?
    private let _ops: String?
    private let _outs: Int?
    private let _pickoffs: Int?
    private let _pitchesPerInning: String?
    private let _runs: Int?
    private let _runsScoredPer9: String?
    private let _sacBunts: Int?
    private let _sacFlies: Int?
    private let _saveOpportunities: Int?
    private let _saves: Int?
    private let _shutouts: Int?
    private let _slg: String?
    private let _stolenBasePercentage: String?
    private let _stolenBases: Int?
    private let _strikeOuts: Int?
    private let _strikeoutsPer9Inn: String?
    private let _strikeoutWalkRatio: String?
    private let _strikePercentage: String?
    private let _strikes: Int?
    private let _totalBases: Int?
    private let _triples: Int?
    private let _walksPer9Inn: String?
    private let _whip: String?
    private let _wildPitches: Int?
    private let _winPercentage: String?
    private let _wins: Int?

    var airOuts: Int { _airOuts ?? 0 }
    var atBats: Int { _atBats ?? 0 }
    var avg: String { _avg ?? "" }
    var balks: Int { _balks ?? 0 }
    var baseOnBalls: Int { _baseOnBalls ?? 0 }
    var battersFaced: Int { _battersFaced ?? 0 }
    var blownSaves: Int { _blownSaves ?? 0 }
    var catchersInterference: Int { _catchersInterference ?? 0 }
    var caughtStealing: Int { _caughtStealing ?? 0 }
    var completeGames: Int { _completeGames ?? 0 }
    var doubles: Int { _doubles ?? 0 }
    var earnedRuns: Int { _earnedRuns ?? 0 }
    var era: String { _era ?? "" }
    var gamesFinished: Int { _gamesFinished ?? 0 }
    var gamesPitched: Int { _gamesPitched ?? 0 }
    var gamesPlayed: Int { _gamesPlayed ?? 0 }
    var gamesStarted: Int { _gamesStarted ?? 0 }
    var groundIntoDoublePlay: Int { _groundIntoDoublePlay ?? 0 }
    var groundOuts: Int { _groundOuts ?? 0 }
    var groundOutsToAirouts: String { _groundOutsToAirouts ?? "" }
    var hitBatsmen: Int { _hitBatsmen ?? 0 }
    var hitByPitch: Int { _hitByPitch ?? 0 }
    var hits: Int { _hits ?? 0 }
    var hitsPer9Inn: String { _hitsPer9Inn ?? "" }
    var holds: Int { _holds ?? 0 }
    var homeRuns: Int { _homeRuns ?? 0 }
    var homeRunsPer9: String { _homeRunsPer9 ?? "" }
    var inheritedRunners: Int { _inheritedRunners ?? 0 }
    var inheritedRunnersScored: Int { _inheritedRunnersScored ?? 0 }
    var inningsPitched: String { _inningsPitched ?? "" }
    var intentionalWalks: Int { _intentionalWalks ?? 0 }
    var losses: Int { _losses ?? 0 }
    var numberOfPitches: Int { _numberOfPitches ?? 0 }
    var obp: String { _obp ?? "" }
    var ops: String { _ops ?? "" }
    var outs: Int { _outs ?? 0 }
    var pickoffs: Int { _pickoffs ?? 0 }
    var pitchesPerInning: String { _pitchesPerInning ?? "" }
    var runs: Int { _runs ?? 0 }
    var runsScoredPer9: String { _runsScoredPer9 ?? "" }
    var sacBunts: Int { _sacBunts ?? 0 }
    var sacFlies: Int { _sacFlies ?? 0 }
    var saveOpportunities: Int { _saveOpportunities ?? 0 }
    var saves: Int { _saves ?? 0 }
    var shutouts: Int { _shutouts ?? 0 }
    var slg: String { _slg ?? "" }
    var stolenBasePercentage: String { _stolenBasePercentage ?? "" }
    var stolenBases: Int { _stolenBases ?? 0 }
    var strikeOuts: Int { _strikeOuts ?? 0 }
    var strikeoutsPer9Inn: String { _strikeoutsPer9Inn ?? "" }
    var strikeoutWalkRatio: String { _strikeoutWalkRatio ?? "" }
    var strikePercentage: String { _strikePercentage ?? "" }
    var strikes: Int { _strikes ?? 0 }
    var totalBases: Int { _totalBases ?? 0 }
    var triples: Int { _triples ?? 0 }
    var walksPer9Inn: String { _walksPer9Inn ?? "" }
    var whip: String { _whip ?? "" }
    var wildPitches: Int { _wildPitches ?? 0 }
    var winPercentage: String { _winPercentage ?? "" }
    var wins: Int { _wins ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _airOuts = "airOuts"
        case _atBats = "atBats"
        case _avg = "avg"
        case _balks = "balks"
        case _baseOnBalls = "baseOnBalls"
        case _battersFaced = "battersFaced"
        case _blownSaves = "blownSaves"
        case _catchersInterference = "catchersInterference"
        case _caughtStealing = "caughtStealing"
        case _completeGames = "completeGames"
        case _doubles = "doubles"
        case _earnedRuns = "earnedRuns"
        case _era = "era"
        case _gamesFinished = "gamesFinished"
        case _gamesPitched = "gamesPitched"
        case _gamesPlayed = "gamesPlayed"
        case _gamesStarted = "gamesStarted"
        case _groundIntoDoublePlay = "groundIntoDoublePlay"
        case _groundOuts = "groundOuts"
        case _groundOutsToAirouts = "groundOutsToAirouts"
        case _hitBatsmen = "hitBatsmen"
        case _hitByPitch = "hitByPitch"
        case _hits = "hits"
        case _hitsPer9Inn = "hitsPer9Inn"
        case _holds = "holds"
        case _homeRuns = "homeRuns"
        case _homeRunsPer9 = "homeRunsPer9"
        case _inheritedRunners = "inheritedRunners"
        case _inheritedRunnersScored = "inheritedRunnersScored"
        case _inningsPitched = "inningsPitched"
        case _intentionalWalks = "intentionalWalks"
        case _losses = "losses"
        case _numberOfPitches = "numberOfPitches"
        case _obp = "obp"
        case _ops = "ops"
        case _outs = "outs"
        case _pickoffs = "pickoffs"
        case _pitchesPerInning = "pitchesPerInning"
        case _runs = "runs"
        case _runsScoredPer9 = "runsScoredPer9"
        case _sacBunts = "sacBunts"
        case _sacFlies = "sacFlies"
        case _saveOpportunities = "saveOpportunities"
        case _saves = "saves"
        case _shutouts = "shutouts"
        case _slg = "slg"
        case _stolenBasePercentage = "stolenBasePercentage"
        case _stolenBases = "stolenBases"
        case _strikeOuts = "strikeOuts"
        case _strikeoutsPer9Inn = "strikeoutsPer9Inn"
        case _strikeoutWalkRatio = "strikeoutWalkRatio"
        case _strikePercentage = "strikePercentage"
        case _strikes = "strikes"
        case _totalBases = "totalBases"
        case _triples = "triples"
        case _walksPer9Inn = "walksPer9Inn"
        case _whip = "whip"
        case _wildPitches = "wildPitches"
        case _winPercentage = "winPercentage"
        case _wins = "wins"
    }
}

struct MLBPlayerCatchingData: Decodable, Equatable {
    private let _gameType: String?
    let league: MLBNameObj
    private let _season: String?
    let sport: MLBAbbreviationIdObj
    let stat: MLBPlayerCatchingStats
    let team: MLBNameObj

    var gameType: String { _gameType ?? "" }
    var season: String { _season ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _gameType = "gameType"
        case league
        case _season = "season"
        case sport
        case stat
        case team
    }
}

struct MLBPlayerCatchingStats: Decodable, Equatable {
    private let _atBats: Int?
    private let _avg: String?
    private let _baseOnBalls: Int?
    private let _battersFaced: Int?
    private let _catchersInterference: Int?
    private let _caughtStealing: Int?
    private let _earnedRuns: Int?
    private let _gamesPitched: Int?
    private let _gamesPlayed: Int?
    private let _hitBatsmen: Int?
    private let _hitByPitch: Int?
    private let _hits: Int?
    private let _homeRuns: Int?
    private let _intentionalWalks: Int?
    private let _obp: String?
    private let _ops: String?
    private let _passedBall: Int?
    private let _pickoffAttempts: Int?
    private let _pickoffs: Int?
    private let _runs: Int?
    private let _sacBunts: Int?
    private let _sacFlies: Int?
    private let _slg: String?
    private let _stolenBasePercentage: String?
    private let _stolenBases: Int?
    private let _strikeOuts: Int?
    private let _strikeoutWalkRatio: String?
    private let _totalBases: Int?
    private let _wildPitches: Int?

    var atBats: Int { _atBats ?? 0 }
    var avg: String { _avg ?? "" }
    var baseOnBalls: Int { _baseOnBalls ?? 0 }
    var battersFaced: Int { _battersFaced ?? 0 }
    var catchersInterference: Int { _catchersInterference ?? 0 }
    var caughtStealing: Int { _caughtStealing ?? 0 }
    var earnedRuns: Int { _earnedRuns ?? 0 }
    var gamesPitched: Int { _gamesPitched ?? 0 }
    var gamesPlayed: Int { _gamesPlayed ?? 0 }
    var hitBatsmen: Int { _hitBatsmen ?? 0 }
    var hitByPitch: Int { _hitByPitch ?? 0 }
    var hits: Int { _hits ?? 0 }
    var homeRuns: Int { _homeRuns ?? 0 }
    var intentionalWalks: Int { _intentionalWalks ?? 0 }
    var obp: String { _obp ?? "" }
    var ops: String { _ops ?? "" }
    var passedBall: Int { _passedBall ?? 0 }
    var pickoffAttempts: Int { _pickoffAttempts ?? 0 }
    var pickoffs: Int { _pickoffs ?? 0 }
    var runs: Int { _runs ?? 0 }
    var sacBunts: Int { _sacBunts ?? 0 }
    var sacFlies: Int { _sacFlies ?? 0 }
    var slg: String { _slg ?? "" }
    var stolenBasePercentage: String { _stolenBasePercentage ?? "" }
    var stolenBases: Int { _stolenBases ?? 0 }
    var strikeOuts: Int { _strikeOuts ?? 0 }
    var strikeoutWalkRatio: String { _strikeoutWalkRatio ?? "" }
    var totalBases: Int { _totalBases ?? 0 }
    var wildPitches: Int { _wildPitches ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _atBats = "atBats"
        case _avg = "avg"
        case _baseOnBalls = "baseOnBalls"
        case _battersFaced = "battersFaced"
        case _catchersInterference = "catchersInterference"
        case _caughtStealing = "caughtStealing"
        case _earnedRuns = "earnedRuns"
        case _gamesPitched = "gamesPitched"
        case _gamesPlayed = "gamesPlayed"
        case _hitBatsmen = "hitBatsmen"
        case _hitByPitch = "hitByPitch"
        case _hits = "hits"
        case _homeRuns = "homeRuns"
        case _intentionalWalks = "intentionalWalks"
        case _obp = "obp"
        case _ops = "ops"
        case _passedBall = "passedBall"
        case _pickoffAttempts = "pickoffAttempts"
        case _pickoffs = "pickoffs"
        case _runs = "runs"
        case _sacBunts = "sacBunts"
        case _sacFlies = "sacFlies"
        case _slg = "slg"
        case _stolenBasePercentage = "stolenBasePercentage"
        case _stolenBases = "stolenBases"
        case _strikeOuts = "strikeOuts"
        case _strikeoutWalkRatio = "strikeoutWalkRatio"
        case _totalBases = "totalBases"
        case _wildPitches = "wildPitches"
    }
}
