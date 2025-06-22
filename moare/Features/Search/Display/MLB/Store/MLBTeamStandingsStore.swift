//
//  MLBTeamStandingsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/8/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MLBTeamStandingsStore {
    typealias BaseTeamStandings = BaseTeamStandingsStore<MLBTeamStandingsDisplayModel>
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var baseTeamStandings = BaseTeamStandings.State()
        var westStandings: [MLBTeamStandingsDisplay] = []
        var eastStandings: [MLBTeamStandingsDisplay] = []
        var centralStandings: [MLBTeamStandingsDisplay] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var headerCategorySelectedIndex = 0
    }
    
    enum Action {
        case baseTeamStandings(BaseTeamStandings.Action)
        
        /* ---------------------
           view action
           --------------------- */
        case selectHeaderCategory(index: Int, isInit: Bool = false)
        
        /* ---------------------
           private
           --------------------- */
        case sortStandings
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseTeamStandings, action: \.baseTeamStandings) {
            BaseTeamStandings()
        }
        
        Reduce { state, action in
            switch action {
            case .baseTeamStandings(.initData):
                // init data
                state.westStandings = []
                state.eastStandings = []
                state.centralStandings = []
                
                return .send(.selectHeaderCategory(index: 0, isInit: true))
                
            case .baseTeamStandings(.selectSecondCategory):
                return .send(.sortStandings)
                
            case .selectHeaderCategory(let index, let isInit):
                if isInit {
                    let entityTeam = state.baseTeamStandings.displayModel?.standings.first { team in
                        // Any first team that matches with any team in entityInfo
                        state.baseTeamStandings.displayModel?.entityInfo.first { $0.teamId == team.team.id } != nil
                    }
                    
                    // When init, if entity's league is american, set index 1.
                    // Otherwise do nothing, which would be set as default(0).
                    if entityTeam?.team.league.id == Constants.Ids.americanLeague {
                        state.headerCategorySelectedIndex = 1
                    }
                    
                    state.westStandings = state.baseTeamStandings.displayModel?.standings.filter {
                        if entityTeam?.team.league.id == Constants.Ids.americanLeague {
                            $0.team.division.id == Constants.Ids.americanLeagueWest
                        } else {
                            $0.team.division.id == Constants.Ids.nationalLeagueWest
                        }
                    } ?? []
                    state.eastStandings = state.baseTeamStandings.displayModel?.standings.filter {
                        if entityTeam?.team.league.id == Constants.Ids.americanLeague {
                            $0.team.division.id == Constants.Ids.americanLeagueEast
                        } else {
                            $0.team.division.id == Constants.Ids.nationalLeagueEast
                        }
                    } ?? []
                    state.centralStandings = state.baseTeamStandings.displayModel?.standings.filter {
                        if entityTeam?.team.league.id == Constants.Ids.americanLeague {
                            $0.team.division.id == Constants.Ids.americanLeagueCentral
                        } else {
                            $0.team.division.id == Constants.Ids.nationalLeagueCentral
                        }
                    } ?? []
                } else {
                    state.headerCategorySelectedIndex = index
                    
                    state.westStandings = state.baseTeamStandings.displayModel?.standings.filter {
                        if index == 0 {
                            $0.team.division.id == Constants.Ids.nationalLeagueWest
                        } else {
                            $0.team.division.id == Constants.Ids.americanLeagueWest
                        }
                    } ?? []
                    state.eastStandings = state.baseTeamStandings.displayModel?.standings.filter {
                        if index == 0 {
                            $0.team.division.id == Constants.Ids.nationalLeagueEast
                        } else {
                            $0.team.division.id == Constants.Ids.americanLeagueEast
                        }
                    } ?? []
                    state.centralStandings = state.baseTeamStandings.displayModel?.standings.filter {
                        if index == 0 {
                            $0.team.division.id == Constants.Ids.nationalLeagueCentral
                        } else {
                            $0.team.division.id == Constants.Ids.americanLeagueCentral
                        }
                    } ?? []

                }
                
                return .send(.sortStandings)
                
            case .sortStandings:
                switch state.baseTeamStandings.secondCategorySelectedIndex {
                case 0: // 승률
                    state.westStandings.sort { Double($0.stats.recordData?.winningPercentage ?? "0") ?? 0 > Double($1.stats.recordData?.winningPercentage ?? "0") ?? 0 }
                    state.eastStandings.sort { Double($0.stats.recordData?.winningPercentage ?? "0") ?? 0 > Double($1.stats.recordData?.winningPercentage ?? "0") ?? 0 }
                    state.centralStandings.sort { Double($0.stats.recordData?.winningPercentage ?? "0") ?? 0 > Double($1.stats.recordData?.winningPercentage ?? "0") ?? 0 }
                case 1: // 게임차
                    state.westStandings.sort { Double($0.stats.recordData?.gamesBack ?? "0") ?? 0 < Double($1.stats.recordData?.gamesBack ?? "0") ?? 0 }
                    state.eastStandings.sort { Double($0.stats.recordData?.gamesBack ?? "0") ?? 0 < Double($1.stats.recordData?.gamesBack ?? "0") ?? 0 }
                    state.centralStandings.sort { Double($0.stats.recordData?.gamesBack ?? "0") ?? 0 < Double($1.stats.recordData?.gamesBack ?? "0") ?? 0 }
                case 2: // 승
                    state.westStandings.sort { $0.stats.recordData?.wins ?? 0 > $1.stats.recordData?.wins ?? 0 }
                    state.eastStandings.sort { $0.stats.recordData?.wins ?? 0 > $1.stats.recordData?.wins ?? 0 }
                    state.centralStandings.sort { $0.stats.recordData?.wins ?? 0 > $1.stats.recordData?.wins ?? 0 }
                case 3: // 패
                    state.westStandings.sort { $0.stats.recordData?.losses ?? 0 < $1.stats.recordData?.losses ?? 0 }
                    state.eastStandings.sort { $0.stats.recordData?.losses ?? 0 < $1.stats.recordData?.losses ?? 0 }
                    state.centralStandings.sort { $0.stats.recordData?.losses ?? 0 < $1.stats.recordData?.losses ?? 0 }
                case 4: // 경기수
                    state.westStandings.sort { $0.stats.recordData?.gamesPlayed ?? 0 > $1.stats.recordData?.gamesPlayed ?? 0 }
                    state.eastStandings.sort { $0.stats.recordData?.gamesPlayed ?? 0 > $1.stats.recordData?.gamesPlayed ?? 0 }
                    state.centralStandings.sort { $0.stats.recordData?.gamesPlayed ?? 0 > $1.stats.recordData?.gamesPlayed ?? 0 }
                case 5: // 연속
                    state.westStandings.sort { a, b in
                        sortStreak(a, b)
                    }
                    state.eastStandings.sort { a, b in
                        sortStreak(a, b)
                    }
                    state.centralStandings.sort { a, b in
                        sortStreak(a, b)
                    }
                case 6: // 타율
                    state.westStandings.sort { Double($0.stats.hitting?.avg ?? "0") ?? 0 > Double($1.stats.hitting?.avg ?? "0") ?? 0 }
                    state.eastStandings.sort { Double($0.stats.hitting?.avg ?? "0") ?? 0 > Double($1.stats.hitting?.avg ?? "0") ?? 0 }
                    state.centralStandings.sort { Double($0.stats.hitting?.avg ?? "0") ?? 0 > Double($1.stats.hitting?.avg ?? "0") ?? 0 }
                case 7: // 안타
                    state.westStandings.sort { $0.stats.hitting?.hits ?? 0 > $1.stats.hitting?.hits ?? 0 }
                    state.eastStandings.sort { $0.stats.hitting?.hits ?? 0 > $1.stats.hitting?.hits ?? 0 }
                    state.centralStandings.sort { $0.stats.hitting?.hits ?? 0 > $1.stats.hitting?.hits ?? 0 }
                case 8: // 홈런
                    state.westStandings.sort { $0.stats.hitting?.homeRuns ?? 0 > $1.stats.hitting?.homeRuns ?? 0 }
                    state.eastStandings.sort { $0.stats.hitting?.homeRuns ?? 0 > $1.stats.hitting?.homeRuns ?? 0 }
                    state.centralStandings.sort { $0.stats.hitting?.homeRuns ?? 0 > $1.stats.hitting?.homeRuns ?? 0 }
                case 9: // 장타율
                    state.westStandings.sort { Double($0.stats.hitting?.slg ?? "0") ?? 0 > Double($1.stats.hitting?.slg ?? "0") ?? 0 }
                    state.eastStandings.sort { Double($0.stats.hitting?.slg ?? "0") ?? 0 > Double($1.stats.hitting?.slg ?? "0") ?? 0 }
                    state.centralStandings.sort { Double($0.stats.hitting?.slg ?? "0") ?? 0 > Double($1.stats.hitting?.slg ?? "0") ?? 0 }
                case 10: // 득점
                    state.westStandings.sort { $0.stats.hitting?.runs ?? 0 > $1.stats.hitting?.runs ?? 0 }
                    state.eastStandings.sort { $0.stats.hitting?.runs ?? 0 > $1.stats.hitting?.runs ?? 0 }
                    state.centralStandings.sort { $0.stats.hitting?.runs ?? 0 > $1.stats.hitting?.runs ?? 0 }
                case 11: // 평균자책
                    state.westStandings.sort { Double($0.stats.pitching?.era ?? "0") ?? 0 < Double($1.stats.pitching?.era ?? "0") ?? 0 }
                    state.eastStandings.sort { Double($0.stats.pitching?.era ?? "0") ?? 0 < Double($1.stats.pitching?.era ?? "0") ?? 0 }
                    state.centralStandings.sort { Double($0.stats.pitching?.era ?? "0") ?? 0 < Double($1.stats.pitching?.era ?? "0") ?? 0 }
                case 12: // 피안타율
                    state.westStandings.sort { Double($0.stats.pitching?.avg ?? "0") ?? 0 < Double($1.stats.pitching?.avg ?? "0") ?? 0 }
                    state.eastStandings.sort { Double($0.stats.pitching?.avg ?? "0") ?? 0 < Double($1.stats.pitching?.avg ?? "0") ?? 0 }
                    state.centralStandings.sort { Double($0.stats.pitching?.avg ?? "0") ?? 0 < Double($1.stats.pitching?.avg ?? "0") ?? 0 }
                case 13: // 피안타
                    state.westStandings.sort { $0.stats.pitching?.hits ?? 0 < $1.stats.pitching?.hits ?? 0 }
                    state.eastStandings.sort { $0.stats.pitching?.hits ?? 0 < $1.stats.pitching?.hits ?? 0 }
                    state.centralStandings.sort { $0.stats.pitching?.hits ?? 0 < $1.stats.pitching?.hits ?? 0 }
                case 14: // 피홈런
                    state.westStandings.sort { $0.stats.pitching?.homeRuns ?? 0 < $1.stats.pitching?.homeRuns ?? 0 }
                    state.eastStandings.sort { $0.stats.pitching?.homeRuns ?? 0 < $1.stats.pitching?.homeRuns ?? 0 }
                    state.centralStandings.sort { $0.stats.pitching?.homeRuns ?? 0 < $1.stats.pitching?.homeRuns ?? 0 }
                case 15: // 실점
                    state.westStandings.sort { $0.stats.pitching?.runs ?? 0 < $1.stats.pitching?.runs ?? 0 }
                    state.eastStandings.sort { $0.stats.pitching?.runs ?? 0 < $1.stats.pitching?.runs ?? 0 }
                    state.centralStandings.sort { $0.stats.pitching?.runs ?? 0 < $1.stats.pitching?.runs ?? 0 }
                case 16: // 도루성공률
                    state.westStandings.sort { Double($0.stats.hitting?.stolenBasePercentage ?? "0") ?? 0 > Double($1.stats.hitting?.stolenBasePercentage ?? "0") ?? 0 }
                    state.eastStandings.sort { Double($0.stats.hitting?.stolenBasePercentage ?? "0") ?? 0 > Double($1.stats.hitting?.stolenBasePercentage ?? "0") ?? 0 }
                    state.centralStandings.sort { Double($0.stats.hitting?.stolenBasePercentage ?? "0") ?? 0 > Double($1.stats.hitting?.stolenBasePercentage ?? "0") ?? 0 }
                default: break
                }
                
                return .none
            }
            
            func sortStreak(_ a: MLBTeamStandingsDisplay, _ b: MLBTeamStandingsDisplay) -> Bool {
                guard let aStreak = a.stats.recordData?.streak.streakCode, let bStreak = b.stats.recordData?.streak.streakCode else {
                    return false
                }
                let aIsWin = aStreak.hasPrefix("W")
                let bIsWin = bStreak.hasPrefix("W")

                if aIsWin && bIsWin {
                    // 둘 다 승일 때: 숫자 큰 순
                    return extractNumber(from: aStreak) > extractNumber(from: bStreak)
                } else if !aIsWin && !bIsWin {
                    // 둘 다 패일 때: 숫자 작은 순
                    return extractNumber(from: aStreak) < extractNumber(from: bStreak)
                } else {
                    // 승이 우선
                    return aIsWin
                }
            }
            
            func extractNumber(from string: String) -> Int {
                return Int(string.dropFirst()) ?? 0
            }
        }
    }
}
