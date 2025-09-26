//
//  NBAUtil.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import Foundation

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
}
