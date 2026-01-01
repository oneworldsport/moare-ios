//
//  FootballTeam.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/10/24.
//

import Foundation

struct FBTeam: Decodable, Equatable {
    let team: FBTeamInfo
    let venue: FBVenue
    let statistics: [FBTeamStats]
}

struct FBTeamStats: Decodable, Equatable {
    let league: FBLeague
    let team: FBTeamInfo
    private let _form: String?
    let fixtures: FBTeamStatsFixtures
    let goals: FBTeamStatsGoals
    let biggest: FBTeamStatsBiggest?
    let cleanSheet: FBHomeAwayIntStats?
    let failedToScore: FBHomeAwayIntStats?
    let penalty: FBTeamStatsPenalty
    private let _rank: Int?
    private let _points: Int?
    
    var form: String { _form ?? "" }
    var rank: Int { _rank ?? 0 }
    var points: Int { _points ?? 0 }
    
    enum CodingKeys: String, CodingKey {
        case league, team, fixtures, goals, biggest, penalty
        case _form = "form"
        case _rank = "rank"
        case _points = "points"
        case cleanSheet = "clean_sheet"
        case failedToScore = "failed_to_score"
    }
}

struct FBTeamStatsFixtures: Decodable, Equatable {
    let played: FBHomeAwayIntStats
    let wins: FBHomeAwayIntStats
    let draws: FBHomeAwayIntStats
    let loses: FBHomeAwayIntStats
}

struct FBTeamStatsGoals: Decodable, Equatable {
    let teamGoalsFor: FBTeamStatsGoalsDetail
    let teamGoalsAgainst: FBTeamStatsGoalsDetail
    
    enum CodingKeys: String, CodingKey {
        case teamGoalsFor = "for"
        case teamGoalsAgainst = "against"
    }
}

struct FBTeamStatsGoalsDetail: Decodable, Equatable {
    let total: FBHomeAwayIntStats
    let average: FBHomeAwayStringStats
}

struct FBTeamStatsBiggest: Decodable, Equatable {
    let streak: FBTeamStatsStreak
    let wins: FBHomeAwayStringStats
    let loses: FBHomeAwayStringStats
    let goals: FBTeamStatsBiggestGoals
}

struct FBTeamStatsStreak: Decodable, Equatable {
    private let _wins: Int?
    private let _draws: Int?
    private let _loses: Int?
    
    var wins: Int {
        return _wins ?? 0
    }
    var draws: Int {
        return _draws ?? 0
    }
    var loses: Int {
        return _loses ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _wins = "wins"
        case _draws = "draws"
        case _loses = "loses"
    }
}

struct FBTeamStatsBiggestGoals: Decodable, Equatable {
    let teamBiggestGoalsFor: FBHomeAwayIntStats
    let teamBiggestGoalsAgainst: FBHomeAwayIntStats
    
    enum CodingKeys: String, CodingKey {
        case teamBiggestGoalsFor = "for"
        case teamBiggestGoalsAgainst = "against"
    }
}

struct FBTeamStatsPenalty: Decodable, Equatable {
    let scored: FBTeamStatsPenaltyPercentage
    let missed: FBTeamStatsPenaltyPercentage
    private let _total: Int?
    
    var total: Int {
        return _total ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case scored, missed
        case _total = "total"
    }
}

struct FBTeamStatsPenaltyPercentage: Decodable, Equatable {
    private let _total: Int?
    private let _percentage: String?
    
    var total: Int {
        return _total ?? 0
    }
    var percentage: String {
        return _percentage ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case _total = "total"
        case _percentage = "percentage"
    }
}

// football api response로 오는 standings 전용 모델들
struct FBTeamForStandings: Decodable, Equatable {
    // NOTE: 일단은 필요한 프로퍼티만 만들어놓음.
    let team: FBTeamInfo
    let league: FBLeague?
    let all: FBTeamStandingsGameStats
    let home: FBTeamStandingsGameStats
    let away: FBTeamStandingsGameStats
    private let _update: String?
    private let _form: String?
    private let _rank: Int?
    private let _points: Int?
    
    var update: String { _update ?? "" }
    var form: String { _form ?? "" }
    var rank: Int { _rank ?? 0 }
    var points: Int { _points ?? 0 }
    
    private enum CodingKeys: String, CodingKey {
        case team, league, all, home, away
        case _update = "update"
        case _form = "form"
        case _rank = "rank"
        case _points = "points"
    }
}

struct FBTeamStandingsGameStats: Decodable, Equatable {
    private let _played: Int?
    private let _win: Int?
    private let _draw: Int?
    private let _lose: Int?
    let goals: FBTeamStandingsGoalStats
    
    var played: Int { _played ?? 0 }
    var win: Int { _win ?? 0 }
    var draw: Int { _draw ?? 0 }
    var lose: Int { _lose ?? 0 }
    
    private enum CodingKeys: String, CodingKey {
        case goals
        case _played = "played"
        case _win = "win"
        case _draw = "draw"
        case _lose = "lose"
    }
}

struct FBTeamStandingsGoalStats: Decodable, Equatable {
    private let _for: Int?
    private let _against: Int?
    
    var goalsFor: Int { _for ?? 0 }
    var goalsAgainst: Int { _against ?? 0 }
    
    private enum CodingKeys: String, CodingKey {
        case _for = "for"
        case _against = "against"
    }
}
