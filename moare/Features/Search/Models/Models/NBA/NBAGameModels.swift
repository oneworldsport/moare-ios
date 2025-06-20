//
//  FootballGame.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/10/24.
//

import Foundation

struct NBAGame: Decodable, Equatable {
    let boxScoreTraditional: NBABoxScoreTraditional?
    let gameInfo: NBAGameInfo?
    let gameSummary: NBAGameSummary?
    let inactivePlayers: [NBAPlayerForInactive]
    let lastMeeting: NBALastMeeting?
    let lineScore: [NBALineScore]
    let officials: [NBAOfficial]
    let otherStats: [NBAOtherStats]?
    let seasonSeries: NBASeasonSeries?
}

struct NBABoxScoreTraditional: Decodable, Equatable {
    let awayTeam: NBABoxScoreTeam
    let homeTeam: NBABoxScoreTeam
    private let _awayTeamId: Int?
    private let _gameId: String?
    private let _homeTeamId: Int?

    var awayTeamId: Int { _awayTeamId ?? 0 }
    var gameId: String { _gameId ?? "" }
    var homeTeamId: Int { _homeTeamId ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case awayTeam, homeTeam
        case _awayTeamId = "awayTeamId"
        case _gameId = "gameId"
        case _homeTeamId = "homeTeamId"
    }
}

struct NBABoxScoreTeam: Decodable, Equatable {
    let bench: NBAGameBoxScoreStats
    let players: [NBABoxScoreTeamPlayer]
    let starters: NBAGameBoxScoreStats
    let statistics: NBAGameBoxScoreStats
    private let _teamCity: String?
    private let _teamId: Int?
    private let _teamName: String?
    private let _teamSlug: String?
    private let _teamTricode: String?

    var teamCity: String { _teamCity ?? "" }
    var teamId: Int { _teamId ?? 0 }
    var teamName: String { _teamName ?? "" }
    var teamSlug: String { _teamSlug ?? "" }
    var teamTricode: String { _teamTricode ?? "" }

    private enum CodingKeys: String, CodingKey {
        case bench, players, starters, statistics
        case _teamCity = "teamCity"
        case _teamId = "teamId"
        case _teamName = "teamName"
        case _teamSlug = "teamSlug"
        case _teamTricode = "teamTricode"
    }
}

struct NBABoxScoreTeamPlayer: Decodable, Equatable {
    private let _comment: String?
    private let _familyName: String?
    private let _firstName: String?
    private let _jerseyNum: String?
    private let _nameI: String?
    private let _personId: Int?
    private let _playerSlug: String?
    private let _position: String?
    let statistics: NBAGameBoxScoreStats

    var comment: String { _comment ?? "" }
    var familyName: String { _familyName ?? "" }
    var firstName: String { _firstName ?? "" }
    var jerseyNum: String { _jerseyNum?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
    var nameI: String { _nameI ?? "" }
    var personId: Int { _personId ?? 0 }
    var playerSlug: String { _playerSlug ?? "" }
    var position: String { _position ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _comment = "comment"
        case _familyName = "familyName"
        case _firstName = "firstName"
        case _jerseyNum = "jerseyNum"
        case _nameI = "nameI"
        case _personId = "personId"
        case _playerSlug = "playerSlug"
        case _position = "position"
        case statistics
    }
}

struct NBAGameBoxScoreStats: Decodable, Equatable {
    private let _assists: Int?
    private let _blocks: Int?
    private let _fieldGoalsAttempted: Int?
    private let _fieldGoalsMade: Int?
    private var _fieldGoalsPercentage: Double?
    private let _foulsPersonal: Int?
    private let _freeThrowsAttempted: Int?
    private let _freeThrowsMade: Int?
    private var _freeThrowsPercentage: Double?
    private let _minutes: String?
    private var _plusMinusPoints: Int?
    private let _points: Int?
    private let _reboundsDefensive: Int?
    private let _reboundsOffensive: Int?
    private let _reboundsTotal: Int?
    private let _steals: Int?
    private let _threePointersAttempted: Int?
    private let _threePointersMade: Int?
    private var _threePointersPercentage: Double?
    private let _turnovers: Int?

    var assists: Int { _assists ?? 0 }
    var blocks: Int { _blocks ?? 0 }
    var fieldGoalsAttempted: Int { _fieldGoalsAttempted ?? 0 }
    var fieldGoalsMade: Int { _fieldGoalsMade ?? 0 }

    var fieldGoalsPercentage: Double {
        get { _fieldGoalsPercentage ?? 0.0 }
        set { _fieldGoalsPercentage = newValue }
    }

    var foulsPersonal: Int { _foulsPersonal ?? 0 }
    var freeThrowsAttempted: Int { _freeThrowsAttempted ?? 0 }
    var freeThrowsMade: Int { _freeThrowsMade ?? 0 }

    var freeThrowsPercentage: Double {
        get { _freeThrowsPercentage ?? 0.0 }
        set { _freeThrowsPercentage = newValue }
    }

    var minutes: String { _minutes?.isEmpty == false ? _minutes! : "0:0" }

    var plusMinusPoints: Int {
        get { _plusMinusPoints ?? 0 }
        set { _plusMinusPoints = newValue }
    }

    var points: Int { _points ?? 0 }
    var reboundsDefensive: Int { _reboundsDefensive ?? 0 }
    var reboundsOffensive: Int { _reboundsOffensive ?? 0 }
    var reboundsTotal: Int { _reboundsTotal ?? 0 }
    var steals: Int { _steals ?? 0 }
    var threePointersAttempted: Int { _threePointersAttempted ?? 0 }
    var threePointersMade: Int { _threePointersMade ?? 0 }

    var threePointersPercentage: Double {
        get { _threePointersPercentage ?? 0.0 }
        set { _threePointersPercentage = newValue }
    }

    var turnovers: Int { _turnovers ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _assists = "assists"
        case _blocks = "blocks"
        case _fieldGoalsAttempted = "fieldGoalsAttempted"
        case _fieldGoalsMade = "fieldGoalsMade"
        case _fieldGoalsPercentage = "fieldGoalsPercentage"
        case _foulsPersonal = "foulsPersonal"
        case _freeThrowsAttempted = "freeThrowsAttempted"
        case _freeThrowsMade = "freeThrowsMade"
        case _freeThrowsPercentage = "freeThrowsPercentage"
        case _minutes = "minutes"
        case _plusMinusPoints = "plusMinusPoints"
        case _points = "points"
        case _reboundsDefensive = "reboundsDefensive"
        case _reboundsOffensive = "reboundsOffensive"
        case _reboundsTotal = "reboundsTotal"
        case _steals = "steals"
        case _threePointersAttempted = "threePointersAttempted"
        case _threePointersMade = "threePointersMade"
        case _threePointersPercentage = "threePointersPercentage"
        case _turnovers = "turnovers"
    }
    
    init(assists: Int? = nil,
         blocks: Int? = nil,
         fieldGoalsAttempted: Int? = nil,
         fieldGoalsMade: Int? = nil,
         fieldGoalsPercentage: Double? = nil,
         foulsPersonal: Int? = nil,
         freeThrowsAttempted: Int? = nil,
         freeThrowsMade: Int? = nil,
         freeThrowsPercentage: Double? = nil,
         minutes: String? = nil,
         plusMinusPoints: Int? = nil,
         points: Int? = nil,
         reboundsDefensive: Int? = nil,
         reboundsOffensive: Int? = nil,
         reboundsTotal: Int? = nil,
         steals: Int? = nil,
         threePointersAttempted: Int? = nil,
         threePointersMade: Int? = nil,
         threePointersPercentage: Double? = nil,
         turnovers: Int? = nil
    ) {
        self._assists = assists
        self._blocks = blocks
        self._fieldGoalsAttempted = fieldGoalsAttempted
        self._fieldGoalsMade = fieldGoalsMade
        self._fieldGoalsPercentage = fieldGoalsPercentage
        self._foulsPersonal = foulsPersonal
        self._freeThrowsAttempted = freeThrowsAttempted
        self._freeThrowsMade = freeThrowsMade
        self._freeThrowsPercentage = freeThrowsPercentage
        self._minutes = minutes
        self._plusMinusPoints = plusMinusPoints
        self._points = points
        self._reboundsDefensive = reboundsDefensive
        self._reboundsOffensive = reboundsOffensive
        self._reboundsTotal = reboundsTotal
        self._steals = steals
        self._threePointersAttempted = threePointersAttempted
        self._threePointersMade = threePointersMade
        self._threePointersPercentage = threePointersPercentage
        self._turnovers = turnovers
    }
}

struct NBAGameInfo: Decodable, Equatable {
    private let _attendance: Int?
    private let _gameTime: String?

    var attendance: Int { _attendance ?? 0 }
    var gameTime: String { _gameTime ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _attendance = "attendance"
        case _gameTime = "gameTime"
    }
}

struct NBAGameSummary: Decodable, Equatable {
    private let _gameId: String?
    private let _date: String?
    private let _weekNumber: Int?
    private let _weekName: String?
    private let _seriesGameNumber: String?
    private let _gameLabel: String?
    private let _gameSubLabel: String?
    private let _seriesText: String?
    private let _gameCode: String?
    private let _gameStatusId: Int?
    private let _gameStatusText: String?
    private let _homeTeamId: Int?
    private let _livePeriod: Int?
    private let _season: String?
    private let _visitorTeamId: Int?
    private let _whStatus: Int?

    var gameId: String { _gameId ?? "" }
    var date: String { _date ?? "" }
    var weekNumber: Int { _weekNumber ?? 0 }
    var weekName: String { _weekName ?? "" }
    var seriesGameNumber: String { _seriesGameNumber ?? "" }
    var gameLabel: String { _gameLabel ?? "" }
    var gameSubLabel: String { _gameSubLabel ?? "" }
    var seriesText: String { _seriesText ?? "" }
    var gameCode: String { _gameCode ?? "" }
    var gameStatusId: Int { _gameStatusId ?? 0 }
    var gameStatusText: String { _gameStatusText ?? "" }
    var homeTeamId: Int { _homeTeamId ?? 0 }
    var livePeriod: Int { _livePeriod ?? 0 }
    var season: String { _season ?? "" }
    var visitorTeamId: Int { _visitorTeamId ?? 0 }
    var whStatus: Int { _whStatus ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _gameId = "gameId"
        case _date = "date"
        case _weekNumber = "weekNumber"
        case _weekName = "weekName"
        case _seriesGameNumber = "seriesGameNumber"
        case _gameLabel = "gameLabel"
        case _gameSubLabel = "gameSubLabel"
        case _seriesText = "seriesText"
        case _gameCode = "gamecode"
        case _gameStatusId = "gameStatusId"
        case _gameStatusText = "gameStatusText"
        case _homeTeamId = "homeTeamId"
        case _livePeriod = "livePeriod"
        case _season = "season"
        case _visitorTeamId = "visitorTeamId"
        case _whStatus = "whStatus"
    }
}

struct NBAPlayerForInactive: Decodable, Equatable {
    private let _firstName: String?
    private let _jerseyNum: String?
    private let _lastName: String?
    private let _playerId: Int?
    private let _teamAbbreviation: String?
    private let _teamCity: String?
    private let _teamId: Int?
    private let _teamName: String?

    var firstName: String { _firstName ?? "" }
    var jerseyNum: String { _jerseyNum?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
    var lastName: String { _lastName ?? "" }
    var playerId: Int { _playerId ?? 0 }
    var teamAbbreviation: String { _teamAbbreviation ?? "" }
    var teamCity: String { _teamCity ?? "" }
    var teamId: Int { _teamId ?? 0 }
    var teamName: String { _teamName ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _firstName = "firstName"
        case _jerseyNum = "jerseyNum"
        case _lastName = "lastName"
        case _playerId = "playerId"
        case _teamAbbreviation = "teamAbbreviation"
        case _teamCity = "teamCity"
        case _teamId = "teamId"
        case _teamName = "teamName"
    }
}

struct NBALastMeeting: Decodable, Equatable {
    private let _lastGameDateEst: String?
    private let _lastGameHomeTeamAbbreviation: String?
    private let _lastGameHomeTeamCity: String?
    private let _lastGameHomeTeamId: Int?
    private let _lastGameHomeTeamName: String?
    private let _lastGameHomeTeamPoints: Int?
    private let _lastGameId: String?
    private let _lastGameVisitorTeamCity: String?
    private let _lastGameVisitorTeamCity1: String?
    private let _lastGameVisitorTeamId: Int?
    private let _lastGameVisitorTeamName: String?
    private let _lastGameVisitorTeamPoints: Int?

    var lastGameDateEst: String { _lastGameDateEst ?? "" }
    var lastGameHomeTeamAbbreviation: String { _lastGameHomeTeamAbbreviation ?? "" }
    var lastGameHomeTeamCity: String { _lastGameHomeTeamCity ?? "" }
    var lastGameHomeTeamId: Int { _lastGameHomeTeamId ?? 0 }
    var lastGameHomeTeamName: String { _lastGameHomeTeamName ?? "" }
    var lastGameHomeTeamPoints: Int { _lastGameHomeTeamPoints ?? 0 }
    var lastGameId: String { _lastGameId ?? "" }
    var lastGameVisitorTeamCity: String { _lastGameVisitorTeamCity ?? "" }
    var lastGameVisitorTeamCity1: String { _lastGameVisitorTeamCity1 ?? "" }
    var lastGameVisitorTeamId: Int { _lastGameVisitorTeamId ?? 0 }
    var lastGameVisitorTeamName: String { _lastGameVisitorTeamName ?? "" }
    var lastGameVisitorTeamPoints: Int { _lastGameVisitorTeamPoints ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _lastGameDateEst = "lastGameDateEst"
        case _lastGameHomeTeamAbbreviation = "lastGameHomeTeamAbbreviation"
        case _lastGameHomeTeamCity = "lastGameHomeTeamCity"
        case _lastGameHomeTeamId = "lastGameHomeTeamId"
        case _lastGameHomeTeamName = "lastGameHomeTeamName"
        case _lastGameHomeTeamPoints = "lastGameHomeTeamPoints"
        case _lastGameId = "lastGameId"
        case _lastGameVisitorTeamCity = "lastGameVisitorTeamCity"
        case _lastGameVisitorTeamCity1 = "lastGameVisitorTeamCity1"
        case _lastGameVisitorTeamId = "lastGameVisitorTeamId"
        case _lastGameVisitorTeamName = "lastGameVisitorTeamName"
        case _lastGameVisitorTeamPoints = "lastGameVisitorTeamPoints"
    }
}

struct NBALineScore: Decodable, Equatable {
    private let _pts: Int?
    private let _ptsOt1: Int?
    private let _ptsOt2: Int?
    private let _ptsOt3: Int?
    private let _ptsOt4: Int?
    private let _ptsOt5: Int?
    private let _ptsOt6: Int?
    private let _ptsOt7: Int?
    private let _ptsOt8: Int?
    private let _ptsOt9: Int?
    private let _ptsOt10: Int?
    private let _ptsQtr1: Int?
    private let _ptsQtr2: Int?
    private let _ptsQtr3: Int?
    private let _ptsQtr4: Int?
    private let _teamAbbreviation: String?
    private let _teamCityName: String?
    private let _teamId: Int?
    private let _teamNickname: String?
    private let _teamWinsLosses: String?

    var pts: Int? { _pts }
    var ptsOt1: Int? { _ptsOt1 }
    var ptsOt2: Int? { _ptsOt2 }
    var ptsOt3: Int? { _ptsOt3 }
    var ptsOt4: Int? { _ptsOt4 }
    var ptsOt5: Int? { _ptsOt5 }
    var ptsOt6: Int? { _ptsOt6 }
    var ptsOt7: Int? { _ptsOt7 }
    var ptsOt8: Int? { _ptsOt8 }
    var ptsOt9: Int? { _ptsOt9 }
    var ptsOt10: Int? { _ptsOt10 }
    var ptsQtr1: Int? { _ptsQtr1 }
    var ptsQtr2: Int? { _ptsQtr2 }
    var ptsQtr3: Int? { _ptsQtr3 }
    var ptsQtr4: Int? { _ptsQtr4 }
    var teamAbbreviation: String { _teamAbbreviation ?? "" }
    var teamCityName: String { _teamCityName ?? "" }
    var teamId: Int { _teamId ?? 0 }
    var teamNickname: String { _teamNickname ?? "" }
    var teamWinsLosses: String { _teamWinsLosses ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _pts = "pts"
        case _ptsOt1 = "ptsOt1"
        case _ptsOt2 = "ptsOt2"
        case _ptsOt3 = "ptsOt3"
        case _ptsOt4 = "ptsOt4"
        case _ptsOt5 = "ptsOt5"
        case _ptsOt6 = "ptsOt6"
        case _ptsOt7 = "ptsOt7"
        case _ptsOt8 = "ptsOt8"
        case _ptsOt9 = "ptsOt9"
        case _ptsOt10 = "ptsOt10"
        case _ptsQtr1 = "ptsQtr1"
        case _ptsQtr2 = "ptsQtr2"
        case _ptsQtr3 = "ptsQtr3"
        case _ptsQtr4 = "ptsQtr4"
        case _teamAbbreviation = "teamAbbreviation"
        case _teamCityName = "teamCityName"
        case _teamId = "teamId"
        case _teamNickname = "teamNickname"
        case _teamWinsLosses = "teamWinsLosses"
    }
}

struct NBAOfficial: Decodable, Equatable {
    private let _firstName: String?
    private let _jerseyNum: String?
    private let _lastName: String?
    private let _officialId: Int?

    var firstName: String { _firstName ?? "" }
    var jerseyNum: String { _jerseyNum?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
    var lastName: String { _lastName ?? "" }
    var officialId: Int { _officialId ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _firstName = "firstName"
        case _jerseyNum = "jerseyNum"
        case _lastName = "lastName"
        case _officialId = "officialId"
    }
}

struct NBAOtherStats: Decodable, Equatable {
    private let _largestLead: Int?
    private let _leadChanges: Int?
    private let _ptsFb: Int?
    private let _ptsOffTo: Int?
    private let _ptsPaint: Int?
    private let _pts2ndChance: Int?
    private let _teamAbbreviation: String?
    private let _teamCity: String?
    private let _teamId: Int?
    private let _teamRebounds: Int?
    private let _teamTurnovers: Int?
    private let _timesTied: Int?
    private let _totalTurnovers: Int?

    var largestLead: Int { _largestLead ?? 0 }
    var leadChanges: Int { _leadChanges ?? 0 }
    var ptsFb: Int { _ptsFb ?? 0 }
    var ptsOffTo: Int { _ptsOffTo ?? 0 }
    var ptsPaint: Int { _ptsPaint ?? 0 }
    var pts2ndChance: Int { _pts2ndChance ?? 0 }
    var teamAbbreviation: String { _teamAbbreviation ?? "" }
    var teamCity: String { _teamCity ?? "" }
    var teamId: Int { _teamId ?? 0 }
    var teamRebounds: Int { _teamRebounds ?? 0 }
    var teamTurnovers: Int { _teamTurnovers ?? 0 }
    var timesTied: Int { _timesTied ?? 0 }
    var totalTurnovers: Int { _totalTurnovers ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _largestLead = "largestLead"
        case _leadChanges = "leadChanges"
        case _ptsFb = "ptsFb"
        case _ptsOffTo = "ptsOffTo"
        case _ptsPaint = "ptsPaint"
        case _pts2ndChance = "pts2ndChance"
        case _teamAbbreviation = "teamAbbreviation"
        case _teamCity = "teamCity"
        case _teamId = "teamId"
        case _teamRebounds = "teamRebounds"
        case _teamTurnovers = "teamTurnovers"
        case _timesTied = "timesTied"
        case _totalTurnovers = "totalTurnovers"
    }
}

struct NBASeasonSeries: Decodable, Equatable {
    private let _homeTeamId: Int?
    private let _homeTeamLosses: Int?
    private let _homeTeamWins: Int?
    private let _seriesLeader: String?
    private let _visitorTeamId: Int?

    var homeTeamId: Int { _homeTeamId ?? 0 }
    var homeTeamLosses: Int { _homeTeamLosses ?? 0 }
    var homeTeamWins: Int { _homeTeamWins ?? 0 }
    var seriesLeader: String { _seriesLeader ?? "" }
    var visitorTeamId: Int { _visitorTeamId ?? 0 }

    private enum CodingKeys: String, CodingKey {
        case _homeTeamId = "homeTeamId"
        case _homeTeamLosses = "homeTeamLosses"
        case _homeTeamWins = "homeTeamWins"
        case _seriesLeader = "seriesLeader"
        case _visitorTeamId = "visitorTeamId"
    }
}

typealias NBAGameForSchedule = GameForSchedule<NBAGameSummary>

