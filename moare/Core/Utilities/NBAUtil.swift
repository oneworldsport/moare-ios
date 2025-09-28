//
//  NBAUtil.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import Foundation

struct NBAUtil {
    static func translateEastWest(_ input: String) -> String {
        return if input.lowercased() == "east" {
            "동부"
        } else if input.lowercased() == "west" {
            "서부"
        } else {
            input
        }
    }
    
    static func playerPhotoURL(id: Int?) -> String? {
        if let id {
            return "https://cdn.nba.com/headshots/nba/latest/1040x760/\(id).png"
        } else {
            return nil
        }
    }
    
    static func teamLogoURL(id: Int?) -> String? {
        if let id {
            return "https://cdn.nba.com/logos/nba/\(id)/primary/L/logo.svg"
        } else {
            return nil
        }
    }
    
    static func gameType(gameSummary: NBAGameSummary?, isShort: Bool = false) -> String {
        guard let gameSummary else { return "" }
        
        if gameSummary.seriesGameNumber.isEmpty {
            return "정규시즌"
        } else if gameSummary.gameLabel.lowercased().contains("play-in") {
            return "플레이인 토너먼트"
        } else if !gameSummary.seriesGameNumber.isEmpty {
            let label = gameSummary.gameLabel.lowercased()
            let subLabel = gameSummary.gameSubLabel
            let conference = label.contains("west") ? "서부" : "동부"
            
            if label.contains("round") {
                return isShort ? "플레이오프-\(conference) 1R \(subLabel)" : "플레이오프 - \(conference) 컨퍼런스 1라운드 \(subLabel)"
            } else if label.contains("semifinals") {
                return isShort ? "플레이오프-\(conference) 준결승 \(subLabel)" : "플레이오프 - \(conference) 컨퍼런스 준결승 \(subLabel)"
            } else if label.contains("finals") {
                if label.contains("nba") {
                    return isShort ? "플레이오프-NBA 결승 \(subLabel)" : "플레이오프 - NBA 결승 \(subLabel)"
                } else {
                    return isShort ? "플레이오프-\(conference) 결승 \(subLabel)" : "플레이오프 - \(conference) 컨퍼런스 결승 \(subLabel)"
                }
            } else {
                return "정규시즌"
            }
        } else {
            return "정규시즌"
        }
    }
    
    // TODO: 다른곳에서 다시 정리 필요
    static func toCm(feet: Int, inches: Int, decimalPlaces: Int = 0) -> Double {
        let totalInches = feet * 12 + inches
        return (Double(totalInches) * 2.54).rounded(to: decimalPlaces)
    }
    
    static func calculateGamesBack(team: NBATeamStats, standings: [NBATeamStandingsDisplay]) -> Double {
        guard let leader = standings.max(by: { $0.stats.winsPct < $1.stats.winsPct }) else {
            return 0.0
        }
        
        return Double((leader.stats.wins - team.wins) + (team.losses - leader.stats.losses)) / 2.0
    }
}
