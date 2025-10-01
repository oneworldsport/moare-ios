//
//  NBAUtil.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import Foundation
import SwiftUI

struct MLBUtil {
    static let mlbLogoUrl = "https://www.mlbstatic.com/team-logos/league-on-dark/1.svg"
    
    static let positionCodeMap: [String: String] = [
        "P": "투수"
    ]
    
    static let leagueDivisionMap: [Int: String] = [
        Constants.Ids.americanLeague: "아메리칸리그",
        Constants.Ids.nationalLeague: "내셔널리그",
        Constants.Ids.americanLeagueWest: "아메리칸 서부",
        Constants.Ids.americanLeagueEast: "아메리칸 동부",
        Constants.Ids.americanLeagueCentral: "아메리칸 중부",
        Constants.Ids.nationalLeagueWest: "내셔널 서부",
        Constants.Ids.nationalLeagueEast: "내셔널 동부",
        Constants.Ids.nationalLeagueCentral: "내셔널 중부",
    ]
    
    static let teamMap: [Int: String] = [
        133: "ATH", 134: "PIT", 135: "SD", 136: "SEA", 137: "SF", 138: "STL", 139: "TB", 140: "TEX", 141: "TOR", 142: "MIN",
        143: "PHI", 144: "ATL", 145: "CWS", 146: "MIA", 147: "NYY", 158: "MIL", 108: "LAA", 109: "AZ", 110: "BAL", 111: "BOS",
        112: "CHC", 113: "CIN", 114: "CLE", 115: "COL", 116: "DET", 117: "HOU", 118: "KC", 119: "LAD", 120: "WSH", 121: "NYM"
    ]
    
    static func playerPhotoURL(id: Int?) -> String? {
        if let id {
            return "https://img.mlbstatic.com/mlb-photos/image/upload/v1/people/\(id)/headshot/67/current.png"
        } else {
            return nil
        }
    }
    
    static func teamLogoURL(id: Int?) -> String? {
        if let id {
            return "https://www.mlbstatic.com/team-logos/\(id).svg"
        } else {
            return nil
        }
    }
    
    static func getPositionName(input: String) -> String {
        return positionCodeMap[input] ?? "타자"
    }

    static func changeToCm(input: String) -> Int {
        let pattern = #"(\d+)'\s*(\d+)""#
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsrange = NSRange(input.startIndex..<input.endIndex, in: input)
        
        guard
            let match = regex?.firstMatch(in: input, options: [], range: nsrange),
            let feetRange = Range(match.range(at: 1), in: input),
            let inchesRange = Range(match.range(at: 2), in: input),
            let feet = Int(input[feetRange]),
            let inches = Int(input[inchesRange])
        else {
            return 0
        }

        return Int(NBAUtil.toCm(feet: feet, inches: inches))
    }
    
    // NOTE: divisionGamesBack(게임차) 값이 이상해서 만듬
    static func calculateGamesBack(team: MLBTeamStats, standings: [MLBTeamStandingsDisplay]) -> Double {
        guard let leader = standings.max(by: { Double($0.stats.recordData?.winningPercentage ?? "0") ?? 0 < Double($1.stats.recordData?.winningPercentage ?? "0") ?? 0 }) else {
            return 0.0
        }

        if let leaderRecordData = leader.stats.recordData,
           let teamRecordData = team.recordData {
            let gamesBack = Double((leaderRecordData.wins - teamRecordData.wins) + (teamRecordData.losses - leaderRecordData.losses)) / 2.0
            return gamesBack
        } else {
            return 0.0
        }
    }
    
    static func formatSeriesResult(
        seriesStatus: String,
        homeTeamId: Int,
        awayTeamId: Int,
        teamNameDic: [String: String]
    ) -> Text? {
        // seriesStatus 예시: "STL wins 3-0", "Series tied 2-2"
        let parts = seriesStatus.split(separator: " ")
        guard parts.count == 3 else { return nil }
        
        let score = String(parts[2])
        let scoreParts = score.split(separator: "-")
        
        if parts[0].lowercased() == "series" {
            return Text("시리즈 스코어: ")
            + Text(teamNameDic["short_\(awayTeamId)"] ?? "")
            + Text(" \(scoreParts[0])").foregroundStyle(.moare)
            + Text(" - ")
            + Text("\(scoreParts[1]) ").foregroundStyle(.moare)
            + Text(teamNameDic["short_\(homeTeamId)"] ?? "")
        }
        
        let winnerCode = String(parts[0])
        
        let homeCode = teamMap[homeTeamId]!
//        let awayCode = teamMap[awayTeamId]!
        
        let homeScore: Int
        let awayScore: Int
        
        if homeCode == winnerCode {
            homeScore = Int(scoreParts[0]) ?? 0
            awayScore = Int(scoreParts[1]) ?? 0
        } else {
            homeScore = Int(scoreParts[1]) ?? 0
            awayScore = Int(scoreParts[0]) ?? 0
        }
        
        return Text("시리즈 스코어: ")
        + Text(teamNameDic["short_\(awayTeamId)"] ?? "")
        + Text(" \(awayScore)").foregroundStyle(awayScore >= homeScore ? .moare : .primary)
        + Text(" - ")
        + Text("\(homeScore) ").foregroundStyle(homeScore > awayScore ? .moare : .primary)
        + Text(teamNameDic["short_\(homeTeamId)"] ?? "")
    }
}
