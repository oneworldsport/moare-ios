//
//  Constants.swift
//  moare
//
//  Created by Mohwa Yoon on 4/23/25.
//

import SwiftUI

struct Constants {
    struct Keys {
        static let eplPlayerDic = "epl_player"
        static let laligaPlayerDic = "laliga_player"
        static let bundesligaPlayerDic = "bundesliga_player"
        static let ligue1PlayerDic = "ligue1_player"
        static let serieaPlayerDic = "seriea_player"
        static let mlsPlayerDic = "mls_player"
        static let nbaPlayerDic = "nba_player"
        static let nbaTeamDic = "nba_team"
        static let kboPlayerDic = "kbo_player"
        static let kboTeamDic = "kbo_team"
        static let mlbPlayerDic = "mlb_player"
        static let mlbTeamDic = "mlb_team"
        static let footballTeamDic = "football_team"
        
        static let tournamentTeams = "tournament_teams"
    }
    
    struct Ids {
        // league
        static let epl = 39
        static let laliga = 140
        static let bundesliga = 78
        static let ligue1 = 61
        static let seriea = 135
        static let mls = 253
        static let nba = 90001
        static let kbo = 90101
        static let mlb = 90102
        static let footballLeagues = [epl, laliga, bundesliga, ligue1, seriea, mls]
        static let championsLeague = 2
        static let europaLeague = 3
        static let conferenceLeague = 848
        static let faCup = 45
        static let eflCup = 48
        static let dfbPokal = 81
        static let coupeDeFrance = 66
        static let copaDelRey = 143
        static let coppaItalia = 137
        static let footballTournamentLeagues = [championsLeague, europaLeague, conferenceLeague, faCup, eflCup, dfbPokal, coupeDeFrance, copaDelRey, coppaItalia]
        
        // nba team
        struct NBATeam {
            static let atl = 1610612737
            static let bos = 1610612738
            static let cle = 1610612739
            static let nop = 1610612740
            static let chi = 1610612741
            static let dal = 1610612742
            static let den = 1610612743
            static let gsw = 1610612744
            static let hou = 1610612745
            static let lac = 1610612746
            static let lal = 1610612747
            static let mia = 1610612748
            static let mil = 1610612749
            static let min = 1610612750
            static let bkn = 1610612751
            static let nyk = 1610612752
            static let orl = 1610612753
            static let ind = 1610612754
            static let phi = 1610612755
            static let phx = 1610612756
            static let por = 1610612757
            static let sac = 1610612758
            static let sas = 1610612759
            static let okc = 1610612760
            static let tor = 1610612761
            static let uta = 1610612762
            static let mem = 1610612763
            static let was = 1610612764
            static let det = 1610612765
            static let cha = 1610612766
            static let eastConference = [cle, bos, nyk, ind, mil, det, orl, atl, chi, mia, tor, bkn, phi, cha, was]
            static let westConference = [nop, dal, den, gsw, hou, lac, lal, min, phx, por, sac, sas, okc, uta, mem]
        }
        
        // mls team
        struct MLSTeam {
            static let sea = 1595
            static let jos = 1596
            static let dal = 1597
            static let orl = 1598
            static let phi = 1599
            static let hou = 1600
            static let tor = 1601
            static let yor = 1602
            static let van = 1603
            static let nyk = 1604
            static let ang = 1605
            static let sal = 1606
            static let chi = 1607
            static let atl = 1608
            static let eng = 1609
            static let cor = 1610
            static let kan = 1611
            static let min = 1612
            static let col = 1613
            static let mon = 1614
            static let uni = 1615
            static let laf = 1616
            static let por = 1617
            static let cin = 2242
            static let mia = 9568
            static let nas = 9569
            static let aus = 16489
            static let cha = 18310
            static let stl = 20787
            static let san = 25484
            static let eastConference = [orl, phi, tor, yor, nyk, chi, atl, eng, col, mon, uni, cin, mia, nas, cha]
            static let westConference = [sea, jos, dal, hou, van, ang, sal, cor, kan, min, laf, por, aus, stl, san]
        }
        
        // mlb league, division
        static let americanLeague = 103
        static let nationalLeague = 104
        static let americanLeagueWest = 200
        static let americanLeagueEast = 201
        static let americanLeagueCentral = 202
        static let nationalLeagueWest = 203
        static let nationalLeagueEast = 204
        static let nationalLeagueCentral = 205
    }
    
    struct GameStatus {
        struct Football {
            static let notStarted = "NS"
            static let firstHalf = "1H"
            static let halftime = "HT"
            static let secondHalf = "2H"
            static let extraTime = "ET" // 연장전
            static let breakTime = "BT" // 연장전 전반 후 휴식시간
            static let penaltyShootout = "P" // 승부차기
            static let finished = "FT"
            static let finishedAfterExtraTime = "AET" // 승부차기 없이 연장전 후 경기 종료
            static let finishedAfterPenaltyShootout = "PET" // 승부차기 후 경기 종료
            static let postponed = "PST"
            static let cancelled = "CANC"
            static let liveList = [firstHalf, halftime, secondHalf, extraTime, breakTime, penaltyShootout]
            static let finishedList = [finished, finishedAfterExtraTime, finishedAfterPenaltyShootout]
        }
        
        struct NBA {
            static let notStarted = 1
            static let live = 2
            static let finished = 3
        }
        
        struct MLB {
            static let scheduled = "Scheduled"
            static let warmup = "Warmup"
            static let preGame = "Pre-Game"
            static let live = "In Progress"
            static let postponed = "Postponed"
            static let rain = "Completed Early: Rain"
            static let gameOver = "Game Over"
            static let final = "Final"
            static let beforeGameList = [scheduled, warmup, preGame]
            static let finishedList = [rain, gameOver, final]
        }
        
        struct KBO {
            static let scheduled = "1"
            static let live = "2"
            static let final = "3"
            static let canceled = "4"
        }
        
        static func gameStatusText(leagueId: Int, status: String) -> String {
            switch leagueId {
            case let id where Constants.Ids.footballLeagues.contains(id) || Constants.Ids.footballTournamentLeagues.contains(id):
                switch status {
                case Football.notStarted:
                    return StringConstants.gameNotStartedStr
                case Football.firstHalf:
                    return StringConstants.Football.gameFirstHalfStr
                case Football.halftime:
                    return StringConstants.Football.gameHalftimeStr
                case Football.secondHalf:
                    return StringConstants.Football.gameSecondHalfStr
                case let status where Football.finishedList.contains(status):
                    return StringConstants.gameFinishedStr
                default:
                    return ""
                }
            case Constants.Ids.nba:
                return ""
            case Constants.Ids.kbo:
                switch status {
                case KBO.scheduled:
                    return StringConstants.gameNotStartedStr
                case KBO.live:
                    return StringConstants.gameLiveStr
                case KBO.final:
                    return StringConstants.gameFinishedStr
                case KBO.canceled:
                    return StringConstants.gameCanceledStr
                default:
                    return ""
                }
            default :
                return ""
            }
        }
        
        static func mlbGameStatusText(
            status: String,
            currentInning: String? = nil,
            linescore: MLBGameLineScore? = nil,
            isResultOpened: Bool = true
        ) -> String {
            switch status {
            case let status where MLB.beforeGameList.contains(status):
                return StringConstants.gameNotStartedStr
            case MLB.live:
                if let currentInning {
                    return currentInning
                } else if let linescore {
                    return "\(linescore.currentInning)회\(linescore.isTopInning ? "초" : "말")"
                } else {
                    return StringConstants.gameLiveStr
                }
            case MLB.postponed:
                return StringConstants.gamePostponedStr
            case let status where MLB.finishedList.contains(status):
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
            default:
                return ""
            }
        }
        
        static func isLive(leagueId: Int, status: String) -> Bool {
            switch leagueId {
            case let id where Constants.Ids.footballLeagues.contains(id) || Constants.Ids.footballTournamentLeagues.contains(id):
                switch status {
                case let status where Football.liveList.contains(status):
                    return true
                default:
                    return false
                }
            case Constants.Ids.nba:
                return false
            case Constants.Ids.mlb:
                if status == MLB.live {
                    return true
                } else {
                    return false
                }
            case Constants.Ids.kbo:
                if status == KBO.live {
                    return true
                } else {
                    return false
                }
            default :
                return false
            }
        }
        
        static func gameStatusColor(leagueId: Int, status: String) -> Color {
            isLive(leagueId: leagueId, status: status) ? .moare : .secondary
        }
    }
}
