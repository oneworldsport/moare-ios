//
//  FBUtil.swift
//  moare
//
//  Created by Mohwa Yoon on 6/20/25.
//

struct FBUtil {
    static func teamLogoURL(id: Int?) -> String? {
        if let id {
            return "https://media.api-sports.io/football/teams/\(id).png"
        } else {
            return nil
        }
    }
    
}

struct Util {
    static func teamLogoURL(leagueId: Int, teamId: Int?) -> String? {
        if let teamId {
            switch leagueId {
            case let id where Constants.Ids.footballLeagues.contains(id) || Constants.Ids.footballTournamentLeagues.contains(id):
                return "https://media.api-sports.io/football/teams/\(teamId).png"
            case Constants.Ids.nba:
                return "https://cdn.nba.com/logos/nba/\(teamId)/primary/L/logo.svg"
            case Constants.Ids.mlb:
                return "https://www.mlbstatic.com/team-logos/\(teamId).svg"
            case Constants.Ids.kbo:
                if let code = KBOUtil.codeMap[teamId] {
                    return "https://6ptotvmi5753.edge.naverncp.com/KBO_IMAGE/emblem/regular/fixed/emblem_\(code).png"
                } else {
                    return nil
                }
            default :
                return nil
            }
        } else {
            return nil
        }
    }
}
