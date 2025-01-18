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
    var statistics: [FBTeamStats] = []
}

struct FBTeamStats: Decodable, Equatable {
    let league: FBLeague
    let team: FBTeamInfo
    private let _form: String?
    let fixtures: FBTeamStatsFixtures
    let goals: FBTeamStatsGoals
    let biggest: FBTeamStatsBiggest
    let cleanSheet: FBHomeAwayIntStats
    let failedToScore: FBHomeAwayIntStats
    let penalty: FBTeamStatsPenalty
    
    var form: String {
        return _form ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case league
        case team
        case _form = "form"
        case fixtures
        case goals
        case biggest
        case cleanSheet = "clean_sheet"
        case failedToScore = "failed_to_score"
        case penalty
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
        case scored
        case missed
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

