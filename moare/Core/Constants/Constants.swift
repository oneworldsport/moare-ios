//
//  Constants.swift
//  moare
//
//  Created by Mohwa Yoon on 4/23/25.
//

struct Constants {
    struct Keys {
        static let eplPlayerDic = "epl_player"
        static let eplTeamDic = "epl_team"
        static let laligaPlayerDic = "laliga_player"
        static let laligaTeamDic = "laliga_team"
        static let bundesligaPlayerDic = "bundesliga_player"
        static let bundesligaTeamDic = "bundesliga_team"
        static let ligue1PlayerDic = "ligue1_player"
        static let ligue1TeamDic = "ligue1_team"
        static let serieaPlayerDic = "seriea_player"
        static let serieaTeamDic = "seriea_team"
        static let mlsPlayerDic = "mls_player"
        static let mlsTeamDic = "mls_team"
        static let nbaPlayerDic = "nba_player"
        static let nbaTeamDic = "nba_team"
        static let kboPlayerDic = "kbo_player"
        static let kboTeamDic = "kbo_team"
        static let mlbPlayerDic = "mlb_player"
        static let mlbTeamDic = "mlb_team"
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
        
        // nba team
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
    
    struct NBAGameStatus {
        static let notStarted = 1
        static let live = 2
        static let finished = 3
    }
}
