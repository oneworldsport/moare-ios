//
//  MLBTeamModels.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBTeam: Decodable, Equatable {
    let team: MLBTeamInfo
    let venue: MLBNameObj
    let statistics: [MLBTeamStats]
}

struct MLBTeamInfo: Decodable, Equatable {
    private let _abbreviation: String?
    private let _active: Bool?
    private let _allStarStatus: String?
    private let _clubName: String?
    let division: MLBNameObj
    private let _fileCode: String?
    private let _firstYearOfPlay: String?
    private let _franchiseName: String?
    private let _id: Int?
    let league: MLBNameObj
    private let _link: String?
    private let _locationName: String?
    private let _name: String?
    private let _season: Int?
    private let _shortName: String?
    private let _teamCode: String?
    private let _teamName: String?

    var abbreviation: String { _abbreviation ?? "" }
    var active: Bool { _active ?? false }
    var allStarStatus: String { _allStarStatus ?? "" }
    var clubName: String { _clubName ?? "" }
    var fileCode: String { _fileCode ?? "" }
    var firstYearOfPlay: String { _firstYearOfPlay ?? "" }
    var franchiseName: String { _franchiseName ?? "" }
    var id: Int { _id ?? 0 }
    var link: String { _link ?? "" }
    var locationName: String { _locationName ?? "" }
    var name: String { _name ?? "" }
    var season: Int { _season ?? 0 }
    var shortName: String { _shortName ?? "" }
    var teamCode: String { _teamCode ?? "" }
    var teamName: String { _teamName ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _abbreviation = "abbreviation"
        case _active = "active"
        case _allStarStatus = "allStarStatus"
        case _clubName = "clubName"
        case division
        case _fileCode = "fileCode"
        case _firstYearOfPlay = "firstYearOfPlay"
        case _franchiseName = "franchiseName"
        case _id = "id"
        case league
        case _link = "link"
        case _locationName = "locationName"
        case _name = "name"
        case _season = "season"
        case _shortName = "shortName"
        case _teamCode = "teamCode"
        case _teamName = "teamName"
    }
}

struct MLBTeamStats: Decodable, Equatable {
    let catching: MLBTeamCatchingStats?
    let fielding: MLBTeamFieldingStats?
    let hitting: MLBTeamHittingStats?
    let pitching: MLBTeamPitchingStats?
    let recordData: MLBTeamRecordData?
}

struct MLBTeamCatchingStats: Decodable, Equatable {
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

struct MLBTeamFieldingStats: Decodable, Equatable {
    private let _assists: Int?
    private let _catchersInterference: Int?
    private let _caughtStealing: Int?
    private let _chances: Int?
    private let _doublePlays: Int?
    private let _errors: Int?
    private let _fielding: String?
    private let _games: Int?
    private let _gamesPlayed: Int?
    private let _gamesStarted: Int?
    private let _innings: String?
    private let _passedBall: Int?
    private let _pickoffs: Int?
    private let _putOuts: Int?
    private let _rangeFactorPer9Inn: String?
    private let _rangeFactorPerGame: String?
    private let _stolenBasePercentage: String?
    private let _stolenBases: Int?
    private let _throwingErrors: Int?
    private let _triplePlays: Int?
    private let _wildPitches: Int?

    var assists: Int { _assists ?? 0 }
    var catchersInterference: Int { _catchersInterference ?? 0 }
    var caughtStealing: Int { _caughtStealing ?? 0 }
    var chances: Int { _chances ?? 0 }
    var doublePlays: Int { _doublePlays ?? 0 }
    var errors: Int { _errors ?? 0 }
    var fielding: String { _fielding ?? "" }
    var games: Int { _games ?? 0 }
    var gamesPlayed: Int { _gamesPlayed ?? 0 }
    var gamesStarted: Int { _gamesStarted ?? 0 }
    var innings: String { _innings ?? "" }
    var passedBall: Int { _passedBall ?? 0 }
    var pickoffs: Int { _pickoffs ?? 0 }
    var putOuts: Int { _putOuts ?? 0 }
    var rangeFactorPer9Inn: String { _rangeFactorPer9Inn ?? "" }
    var rangeFactorPerGame: String { _rangeFactorPerGame ?? "" }
    var stolenBasePercentage: String { _stolenBasePercentage ?? "" }
    var stolenBases: Int { _stolenBases ?? 0 }
    var throwingErrors: Int { _throwingErrors ?? 0 }
    var triplePlays: Int { _triplePlays ?? 0 }
    var wildPitches: Int { _wildPitches ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _assists = "assists"
        case _catchersInterference = "catchersInterference"
        case _caughtStealing = "caughtStealing"
        case _chances = "chances"
        case _doublePlays = "doublePlays"
        case _errors = "errors"
        case _fielding = "fielding"
        case _games = "games"
        case _gamesPlayed = "gamesPlayed"
        case _gamesStarted = "gamesStarted"
        case _innings = "innings"
        case _passedBall = "passedBall"
        case _pickoffs = "pickoffs"
        case _putOuts = "putOuts"
        case _rangeFactorPer9Inn = "rangeFactorPer9Inn"
        case _rangeFactorPerGame = "rangeFactorPerGame"
        case _stolenBasePercentage = "stolenBasePercentage"
        case _stolenBases = "stolenBases"
        case _throwingErrors = "throwingErrors"
        case _triplePlays = "triplePlays"
        case _wildPitches = "wildPitches"
    }
}

struct MLBTeamHittingStats: Decodable, Equatable {
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


struct MLBTeamPitchingStats: Decodable, Equatable {
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
        case _airOuts = "airOuts", _atBats = "atBats", _avg = "avg", _balks = "balks", _baseOnBalls = "baseOnBalls"
        case _battersFaced = "battersFaced", _blownSaves = "blownSaves", _catchersInterference = "catchersInterference"
        case _caughtStealing = "caughtStealing", _completeGames = "completeGames", _doubles = "doubles"
        case _earnedRuns = "earnedRuns", _era = "era", _gamesFinished = "gamesFinished", _gamesPitched = "gamesPitched"
        case _gamesPlayed = "gamesPlayed", _gamesStarted = "gamesStarted", _groundIntoDoublePlay = "groundIntoDoublePlay"
        case _groundOuts = "groundOuts", _groundOutsToAirouts = "groundOutsToAirouts", _hitBatsmen = "hitBatsmen"
        case _hitByPitch = "hitByPitch", _hits = "hits", _hitsPer9Inn = "hitsPer9Inn", _holds = "holds"
        case _homeRuns = "homeRuns", _homeRunsPer9 = "homeRunsPer9", _inningsPitched = "inningsPitched"
        case _intentionalWalks = "intentionalWalks", _losses = "losses", _numberOfPitches = "numberOfPitches"
        case _obp = "obp", _ops = "ops", _outs = "outs", _pickoffs = "pickoffs"
        case _pitchesPerInning = "pitchesPerInning", _runs = "runs", _runsScoredPer9 = "runsScoredPer9"
        case _sacBunts = "sacBunts", _sacFlies = "sacFlies", _saveOpportunities = "saveOpportunities"
        case _saves = "saves", _shutouts = "shutouts", _slg = "slg", _stolenBasePercentage = "stolenBasePercentage"
        case _stolenBases = "stolenBases", _strikeOuts = "strikeOuts", _strikeoutsPer9Inn = "strikeoutsPer9Inn"
        case _strikeoutWalkRatio = "strikeoutWalkRatio", _strikePercentage = "strikePercentage", _strikes = "strikes"
        case _totalBases = "totalBases", _triples = "triples", _walksPer9Inn = "walksPer9Inn"
        case _whip = "whip", _wildPitches = "wildPitches", _winPercentage = "winPercentage", _wins = "wins"
    }
}

struct MLBTeamRecordData: Decodable, Equatable {
    private let _conferenceGamesBack: String?
    private let _divisionGamesBack: String?
    private let _divisionRank: String?
    private let _gamesBack: String?
    private let _gamesPlayed: Int?
    private let _lastUpdated: String?
    private let _leagueGamesBack: String?
    private let _leagueRank: String?
    let leagueRecord: MLBGameTeamLeagueRecord
    private let _losses: Int?
    private let _runDifferential: Int?
    private let _runsAllowed: Int?
    private let _runsScored: Int?
    private let _season: String?
    private let _sportGamesBack: String?
    private let _sportRank: String?
    let streak: MLBTeamRecordStreak
    let team: MLBNameObj
    private let _wildCardGamesBack: String?
    private let _wildCardRank: String?
    private let _winningPercentage: String?
    private let _wins: Int?

    var conferenceGamesBack: String { _conferenceGamesBack ?? "-" }
    var divisionGamesBack: String { _divisionGamesBack ?? "-" }
    var divisionRank: String { _divisionRank ?? "" }
    var gamesBack: String { _gamesBack ?? "-" }
    var gamesPlayed: Int { _gamesPlayed ?? 0 }
    var lastUpdated: String { _lastUpdated ?? "" }
    var leagueGamesBack: String { _leagueGamesBack ?? "-" }
    var leagueRank: String { _leagueRank ?? "" }
    var losses: Int { _losses ?? 0 }
    var runDifferential: Int { _runDifferential ?? 0 }
    var runsAllowed: Int { _runsAllowed ?? 0 }
    var runsScored: Int { _runsScored ?? 0 }
    var season: String { _season ?? "" }
    var sportGamesBack: String { _sportGamesBack ?? "-" }
    var sportRank: String { _sportRank ?? "" }
    var wildCardGamesBack: String { _wildCardGamesBack ?? "-" }
    var wildCardRank: String { _wildCardRank ?? "" }
    var winningPercentage: String { _winningPercentage ?? "" }
    var wins: Int { _wins ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _conferenceGamesBack = "conferenceGamesBack"
        case _divisionGamesBack = "divisionGamesBack"
        case _divisionRank = "divisionRank"
        case _gamesBack = "gamesBack"
        case _gamesPlayed = "gamesPlayed"
        case _lastUpdated = "lastUpdated"
        case _leagueGamesBack = "leagueGamesBack"
        case _leagueRank = "leagueRank"
        case leagueRecord
        case _losses = "losses"
        case _runDifferential = "runDifferential"
        case _runsAllowed = "runsAllowed"
        case _runsScored = "runsScored"
        case _season = "season"
        case _sportGamesBack = "sportGamesBack"
        case _sportRank = "sportRank"
        case streak
        case team
        case _wildCardGamesBack = "wildCardGamesBack"
        case _wildCardRank = "wildCardRank"
        case _winningPercentage = "winningPercentage"
        case _wins = "wins"
    }
}

struct MLBTeamRecordStreak: Decodable, Equatable {
    private let _streakCode: String?
    private let _streakNumber: Int?
    private let _streakType: String?

    var streakCode: String { _streakCode ?? "" }
    var streakNumber: Int { _streakNumber ?? 0 }
    var streakType: String { _streakType ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _streakCode = "streakCode"
        case _streakNumber = "streakNumber"
        case _streakType = "streakType"
    }
}
