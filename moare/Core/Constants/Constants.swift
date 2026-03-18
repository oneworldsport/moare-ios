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
        static let footballDrawTournamentLeagues = [faCup, eflCup, dfbPokal, coupeDeFrance, copaDelRey, coppaItalia]
        static let footballAll = footballLeagues + footballTournamentLeagues // TODO: 이걸로 refactoring 필요
        
        static let nba = 90001
        static let kbo = 90101
        static let mlb = 90102
        
        // AUS OPEN
        static let ausOpenMSingle = 80001
        static let ausOpenMDoubles = 80002
        static let ausOpenMixedDoubles = 80003
        static let ausOpenWSingle = 80004
        static let ausOpenWDoubles = 80005
        static let ausOpenAll = [ausOpenMSingle, ausOpenMDoubles, ausOpenMixedDoubles, ausOpenWSingle, ausOpenWDoubles]
        // ROLAND GARROS
        static let rolandGarrosMSingle = 80006
        static let rolandGarrosMDoubles = 80007
        static let rolandGarrosMixedDoubles = 80008
        static let rolandGarrosWSingle = 80009
        static let rolandGarrosWDoubles = 80010
        static let rolandGarrosAll = [rolandGarrosMSingle, rolandGarrosMDoubles, rolandGarrosMixedDoubles, rolandGarrosWSingle, rolandGarrosWDoubles]
        // WIMBLEDON
        static let wimbledonMSingle = 80011
        static let wimbledonMDoubles = 80012
        static let wimbledonMixedDoubles = 80013
        static let wimbledonWSingle = 80014
        static let wimbledonWDoubles = 80015
        static let wimbledonAll = [wimbledonMSingle, wimbledonMDoubles, wimbledonMixedDoubles, wimbledonWSingle, wimbledonWDoubles]
        // US OPEN
       static let usOpenMSingle = 80016
       static let usOpenMDoubles = 80017
       static let usOpenMixedDoubles = 80018
       static let usOpenWSingle = 80019
       static let usOpenWDoubles = 80020
       static let usOpenAll = [usOpenMSingle, usOpenMDoubles, usOpenMixedDoubles, usOpenWSingle, usOpenWDoubles]
        // INDIAN WELLS
       static let indianWellsMSingle = 80021
       static let indianWellsMDoubles = 80022
       static let indianWellsWSingle = 80023
       static let indianWellsWDoubles = 80024
       static let indianWellsAll = [indianWellsMSingle, indianWellsMDoubles, indianWellsWSingle, indianWellsWDoubles]
        // MIAMI
        static let miamiMSingle = 80025
        static let miamiMDoubles = 80026
        static let miamiWSingle = 80027
        static let miamiWDoubles = 80028
        static let miamiAll = [miamiMSingle, miamiMDoubles, miamiWSingle, miamiWDoubles]
        // MONTE CARLO
       static let monteCarloMSingle = 80029
       static let monteCarloMDoubles = 80030
       static let monteCarloAll = [monteCarloMSingle, monteCarloMDoubles]
        // MADRID
        static let madridMSingle = 80031
        static let madridMDoubles = 80032
        static let madridWSingle = 80033
        static let madridWDoubles = 80034
        static let madridAll = [madridMSingle, madridMDoubles, madridWSingle, madridWDoubles]
        // ROME
        static let romeMSingle = 80035
        static let romeMDoubles = 80036
        static let romeWSingle = 80037
        static let romeWDoubles = 80038
        static let romeAll = [romeMSingle, romeMDoubles, romeWSingle, romeWDoubles]
        // TORONTO
        static let torontoMSingle = 80039
        static let torontoMDoubles = 80040
        static let torontoWSingle = 80041
        static let torontoWDoubles = 80042
        static let torontoAll = [torontoMSingle, torontoMDoubles, torontoWSingle, torontoWDoubles]
        // MONTREAL
        static let montrealMSingle = 80043
        static let montrealMDoubles = 80044
        static let montrealAll = [montrealMSingle, montrealMDoubles]
        // CINCINNAI
        static let cincinnatiMSingle = 80045
        static let cincinnatiMDoubles = 80046
        static let cincinnatiWSingle = 80047
        static let cincinnatiWDoubles = 80048
        static let cincinnatiAll = [cincinnatiMSingle, cincinnatiMDoubles, cincinnatiWSingle, cincinnatiWDoubles]
        // SHANGHAI
        static let shanghaiMSingle = 80049
        static let shanghaiMDoubles = 80050
        static let shanghaiAll = [shanghaiMSingle, shanghaiMDoubles]
        // PARIS
        static let parisMSingle = 80051
        static let parisMDoubles = 80052
        static let parisAll = [parisMSingle, parisMDoubles]
        // DOHA (W)
        static let dohaWSingle = 80053
        static let dohaWDoubles = 80054
        static let dohaAll = [dohaWSingle, dohaWDoubles]
        // DUBAI (W)
        static let dubaiWSingle = 80055
        static let dubaiAll = [dubaiWSingle]
        // BEIJING (W)
        static let beijingWSingle = 80056
        static let beijingWDoubles = 80057
        static let beijingAll = [beijingWSingle, beijingWDoubles]
        // WUHAN (W)
        static let wuhanWSingle = 80058
        static let wuhanWDoubles = 80059
        static let wuhanAll = [wuhanWSingle, wuhanWDoubles]
        
        static let mSingleAll = [
            ausOpenMSingle,
            rolandGarrosMSingle,
            wimbledonMSingle,
            usOpenMSingle,
            indianWellsMSingle,
            miamiMSingle,
            monteCarloMSingle,
            madridMSingle,
            romeMSingle,
            torontoMSingle,
            montrealMSingle,
            cincinnatiMSingle,
            shanghaiMSingle,
            parisMSingle
        ]
        static let mDoublesAll = [
            ausOpenMDoubles,
            rolandGarrosMDoubles,
            wimbledonMDoubles,
            usOpenMDoubles,
            indianWellsMDoubles,
            miamiMDoubles,
            monteCarloMDoubles,
            madridMDoubles,
            romeMDoubles,
            torontoMDoubles,
            montrealMDoubles,
            cincinnatiMDoubles,
            shanghaiMDoubles,
            parisMDoubles
        ]
        static let mixedDoublesAll = [
            ausOpenMixedDoubles,
            rolandGarrosMixedDoubles,
            wimbledonMixedDoubles,
            usOpenMixedDoubles
        ]
        static let wSingleAll = [
            ausOpenWSingle,
            rolandGarrosWSingle,
            wimbledonWSingle,
            usOpenWSingle,
            indianWellsWSingle,
            miamiWSingle,
            madridWSingle,
            romeWSingle,
            torontoWSingle,
            cincinnatiWSingle,
            dohaWSingle,
            dubaiWSingle,
            beijingWSingle,
            wuhanWSingle
        ]
        static let wDoublesAll = [
            ausOpenWDoubles,
            rolandGarrosWDoubles,
            wimbledonWDoubles,
            usOpenWDoubles,
            indianWellsWDoubles,
            miamiWDoubles,
            madridWDoubles,
            romeWDoubles,
            torontoWDoubles,
            cincinnatiWDoubles,
            dohaWDoubles,
            beijingWDoubles,
            wuhanWDoubles
        ]
        static let tennisAll = ausOpenAll +
        rolandGarrosAll +
        wimbledonAll +
        usOpenAll +
        indianWellsAll +
        miamiAll +
        monteCarloAll +
        madridAll +
        romeAll +
        torontoAll +
        montrealAll +
        cincinnatiAll +
        shanghaiAll +
        parisAll +
        dohaAll +
        dubaiAll +
        beijingAll +
        wuhanAll
        
        // nba teams
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
            // TODO: 임시 올스타 팀 id. 나중에 id s3에서 가져와 사용하게 리팩토링 필요.
            static let teamMelo = 1610616862
            static let teamAustin = 1610616865
            static let teamTMac = 1610616864
            static let teamVince = 1610616863
            static let teamStars = 1610616859
            static let teamWorld = 1610616861
            static let teamStripes = 1610616860
            static let allStar = [teamMelo, teamAustin, teamTMac, teamVince, teamStars, teamWorld, teamStripes]
            //
            static let eastConference = [cle, bos, nyk, ind, mil, det, orl, atl, chi, mia, tor, bkn, phi, cha, was]
            static let westConference = [nop, dal, den, gsw, hou, lac, lal, min, phx, por, sac, sas, okc, uta, mem]
            static let all = eastConference + westConference + allStar
        }
        
        // mlb teams
        // MLBTeamInfo의 abbreviation 사용
        struct MLBTeam {
            static let ath = 133
            static let pit = 134
            static let sd = 135
            static let sea = 136
            static let sf = 137
            static let stl = 138
            static let tb = 139
            static let tex = 140
            static let tor = 141
            static let min = 142
            static let phi = 143
            static let atl = 144
            static let cws = 145
            static let mia = 146
            static let nyy = 147
            static let mil = 158
            static let laa = 108
            static let az = 109
            static let bal = 110
            static let bos = 111
            static let chc = 112
            static let cin = 113
            static let cle = 114
            static let col = 115
            static let det = 116
            static let hou = 117
            static let kc = 118
            static let lad = 119
            static let wsh = 120
            static let nym = 121
            static let alConference = [ath, sea, tb, tex, tor, min, cws, nyy, laa, bal, bos, cle, det, hou, kc]
            static let nlConference = [pit, sd, sf, stl, phi, atl, mia, mil, az, chc, cin, col, lad, wsh, nym]
            static let all = alConference + nlConference
        }
        
        // mls teams
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
            static let all = eastConference + westConference
        }
        
        struct KBOTeam {
            static let lg = 5
            static let lt = 2
            static let hh = 4
            static let ss = 3
            static let kt = 9
            static let sk = 10
            static let ht = 6
            static let ob = 1
            static let nc = 8
            static let wo = 7
            static let all = [lg, lt, hh, ss, kt, sk, ht, ob, nc, wo]
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
        
        static func checkTeamId(leagueId: Int, teamId: Int?) -> Int? {
            guard let teamId else { return nil }
            
            switch leagueId {
            case let id where Constants.Ids.footballLeagues.contains(id)
                || Constants.Ids.footballTournamentLeagues.contains(id)
                || Constants.Ids.tennisAll.contains(id):
                return teamId
            case Constants.Ids.nba:
                return Constants.Ids.NBATeam.all.contains(teamId) ? teamId : nil
            case Constants.Ids.mlb:
                return Constants.Ids.MLBTeam.all.contains(teamId) ? teamId : nil
            case Constants.Ids.kbo:
                return Constants.Ids.KBOTeam.all.contains(teamId) ? teamId : nil
            default :
                return nil
            }
        }
    } // Ids
    
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
            static let finishedAfterPenaltyShootout = "PEN" // 승부차기 후 경기 종료
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
        
        struct Tennis {
            static let notStarted = 0
            static let firstSet = 8
            static let secondSet = 9
            static let thirdSet = 10
            static let fourthSet = 11
            static let fifthSet = 12
            static let finished = 100
            static let canceled = 70
            static let retired = 92
            static let walkover = 91
            static let liveList = [firstSet, secondSet, thirdSet, fourthSet, fifthSet]
            static let finishedList = [finished, canceled, retired, walkover]
        }
        
        static func kboGameStatusText(
            status: String,
            currentInning: String? = nil,
            isResultOpened: Bool = true
        ) -> String {
            switch status {
            case KBO.scheduled:
                return StringConstants.gameNotStartedStr
            case KBO.live:
                return currentInning ?? StringConstants.gameLiveStr
            case KBO.final:
                return isResultOpened
                ? StringConstants.gameFinishedStr
                : StringConstants.resultOpen
            case KBO.canceled:
                return StringConstants.gameCanceledStr
            default:
                return ""
            }
        }
        
        static func fbGameStatusText(
            status: String,
            elapsed: Int?,
            extra: Int?,
            isResultOpened: Bool = true
        ) -> String {
            switch status {
            case Football.notStarted:
                return StringConstants.gameNotStartedStr
            case Football.firstHalf:
                if let elapsed {
                    if let extra {
                        return "전반\(elapsed)+\(extra)’"
                    } else {
                        return "전반\(elapsed)'"
                    }
                } else {
                    return StringConstants.Football.gameFirstHalfStr
                }
            case Football.halftime:
                return StringConstants.Football.gameHalftimeStr
            case Football.secondHalf:
                if let elapsed {
                    if let extra {
                        return "후반\(elapsed-45)+\(extra)’"
                    } else {
                        return "후반\(elapsed-45)'"
                    }
                } else {
                    return StringConstants.Football.gameSecondHalfStr
                }
            case Football.extraTime:
                return StringConstants.Football.gameExtraTime
            case Football.penaltyShootout:
                return StringConstants.Football.gamePenaltyShootout
            case Football.postponed:
                return StringConstants.Football.gamePostponed
            case Football.cancelled:
                return StringConstants.Football.gameCancelled
            case let status where Football.finishedList.contains(status):
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
            default:
                return ""
            }
        }
        
        static func nbaGameStatusText(
            status: Int,
            period: Int? = nil,
            isResultOpened: Bool = true
        ) -> String {
            switch status {
            case NBA.notStarted:
                return StringConstants.gameNotStartedStr
            case NBA.live:
                if let period {
                    if period > 4 {
                        return "연장 \(period-4)쿼터"
                    } else {
                        return "\(period)쿼터"
                    }
                } else {
                    return StringConstants.gameLiveStr
                }
            case NBA.finished:
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
            default:
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
        
        static func tennisGameStatusText(
            status: Int?,
            isResultOpened: Bool = true
        ) -> String {
            switch status {
            case Tennis.notStarted:
                return StringConstants.gameNotStartedStr
            case Tennis.firstSet:
                return "1세트"
            case Tennis.secondSet:
                return "2세트"
            case Tennis.thirdSet:
                return "3세트"
            case Tennis.fourthSet:
                return "4세트"
            case Tennis.fifthSet:
                return "5세트"
            case Tennis.finished:
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
            case Tennis.canceled:
                return StringConstants.gameCanceledStr
            case Tennis.retired:
                return isResultOpened ? "기권" : StringConstants.resultOpen
            case Tennis.walkover:
                return isResultOpened ? "부전" : StringConstants.resultOpen
            default:
                return StringConstants.gameNotStartedStr
            }
        }
        
        static func isLive(leagueId: Int, status: String) -> Bool {
            switch leagueId {
            case let id where Constants.Ids.footballLeagues.contains(id) || Constants.Ids.footballTournamentLeagues.contains(id):
                return Football.liveList.contains(status)
            case Constants.Ids.nba:
                return status == String(NBA.live)
            case Constants.Ids.mlb:
                return status == MLB.live
            case Constants.Ids.kbo:
                return status == KBO.live
            case let id where Constants.Ids.tennisAll.contains(id):
                let status = Int(status) ?? 0
                return Tennis.liveList.contains(status)
            default :
                return false
            }
        }
        
        static func isBeforeGame(leagueId: Int, status: String) -> Bool {
            switch leagueId {
            case let id where Constants.Ids.footballLeagues.contains(id) || Constants.Ids.footballTournamentLeagues.contains(id):
                return status == Football.notStarted
            case Constants.Ids.nba:
                return status == String(NBA.notStarted)
            case Constants.Ids.mlb:
                return MLB.beforeGameList.contains(status)
            case Constants.Ids.kbo:
                return status == KBO.scheduled
            default :
                return false
            }
        }
        
        static func gameStatusColor(leagueId: Int, status: String) -> Color {
            isLive(leagueId: leagueId, status: status) ? .moare : .secondary
        }
    }
}
