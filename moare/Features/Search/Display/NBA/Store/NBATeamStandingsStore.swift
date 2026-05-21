//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBATeamStandingsStore {
    typealias BaseStandings = BaseTeamStandingsStore<NBATeamStandingsDisplayModel>
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let categoryItemHeight: CGFloat = 44
        let firstCategoryItemWidth: CGFloat = 132
        let dataItemWidth: CGFloat = 60
        let categoryFontSize: CGFloat = 15
        let dataFontSize: CGFloat = 15
        
        /* ---------------------
           data state
           --------------------- */
        let responseModel: NBATeamStandingsResponseModel
        var baseStandings: BaseStandings.State
        
        var standings: [NBATeamStandingsDisplay] = []
        
        init(responseModel: NBATeamStandingsResponseModel, displayModel: NBATeamStandingsDisplayModel) {
            self.responseModel = responseModel
            self.baseStandings = BaseStandings.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseStandings(BaseStandings.Action)
        
        case sortStandings
        case showTeamStats(id: Int)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showTeamStats(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseStandings, action: \.baseStandings) { BaseStandings() }
        
        Reduce { state, action in
            switch action {
            case .baseStandings(.initData):
                // init with default value
                state.baseStandings.categorySelectedIndex = 1
                
                return .send(.baseStandings(.selectHeaderCategory(index: 0, isInit: true)))
                
            case let .baseStandings(.selectHeaderCategory(index, isInit)):
                let displayModel = state.baseStandings.displayModel
                
                var standings: [NBATeamStandingsDisplay]
                
                if isInit {
                    let entityTeam = displayModel.standings.first { team in
                        // Any first team that matches with any team in entityInfo
                        displayModel.entityInfo.first { $0.teamId == team.team.id } != nil
                    }
                    
                    // When init, if entity's conference is east, set index 1.
                    // Otherwise do nothing, which would be set as default(0).
                    if entityTeam?.team.teamConference.lowercased() == "east" {
                        state.baseStandings.headerCategorySelectedIndex = 1
                    }
                    
                    standings = displayModel.standings.filter {
                        if entityTeam != nil {
                            $0.team.teamConference == entityTeam?.team.teamConference
                        } else {
                            $0.team.teamConference.lowercased() == "west"
                        }
                    }
                } else {
                    state.baseStandings.headerCategorySelectedIndex = index
                    
                    standings = displayModel.standings.filter {
                        if index == 0 {
                            $0.team.teamConference.lowercased() == "west"
                        } else {
                            $0.team.teamConference.lowercased() == "east"
                        }
                    }
                }
                
                state.standings = standings
                
                return .send(.sortStandings)
                
            case .baseStandings(.selectCategory):
                return .send(.sortStandings)
                
            case .sortStandings:
                let standings = state.standings
                
                switch state.baseStandings.categorySelectedIndex {
                case 0: // 게임차
                    state.standings.sort { $0.stats.playoffRank < $1.stats.playoffRank }
                    for i in standings.indices {
                        state.standings[i].displayRank = state.standings[i].stats.playoffRank
                    }
                case 1: // 승률
                    state.standings.sort { $0.stats.playoffRank < $1.stats.playoffRank }
                    for i in standings.indices {
                        state.standings[i].displayRank = state.standings[i].stats.playoffRank
                    }
                case 2: // 승
                    state.standings.sort { $0.stats.wins > $1.stats.wins }
                    state.standings.assignCompetitionRank { $0.stats.wins }
                case 3: // 패
                    state.standings.sort { $0.stats.losses < $1.stats.losses }
                    state.standings.assignCompetitionRank { $0.stats.losses }
                case 4: // 경기수
                    state.standings.sort { $0.stats.gp > $1.stats.gp }
                    state.standings.assignCompetitionRank { $0.stats.gp }
                case 5: // 연속
                    state.standings.sort {
                        streakValue($0.stats.strCurrentStreak) > streakValue($1.stats.strCurrentStreak)
                    }
                    state.standings.assignCompetitionRank { $0.stats.krCurrentStreak }
                case 6: // 최근 10경기
                    state.standings.sort { a, b in
                        let ra = a.stats.parseRecord(a.stats.l10)
                        let rb = b.stats.parseRecord(b.stats.l10)
                        
                        if ra.winPct != rb.winPct {
                            return ra.winPct > rb.winPct          // 1) 승률 내림차순
                        } else {
                            return ra.wins > rb.wins              // 2) 승수 내림차순
                        }
                    }
                    state.standings.assignCompetitionRank { $0.stats.krL10 }
                case 7: // 홈성적
                    state.standings.sort { a, b in
                        let ra = a.stats.parseRecord(a.stats.home)
                        let rb = b.stats.parseRecord(b.stats.home)
                        
                        if ra.winPct != rb.winPct {
                            return ra.winPct > rb.winPct
                        } else {
                            return ra.wins > rb.wins
                        }
                    }
                    state.standings.assignCompetitionRank { $0.stats.krHome }
                case 8: // 원정성적
                    state.standings.sort { a, b in
                        let ra = a.stats.parseRecord(a.stats.road)
                        let rb = b.stats.parseRecord(b.stats.road)
                        
                        if ra.winPct != rb.winPct {
                            return ra.winPct > rb.winPct
                        } else {
                            return ra.wins > rb.wins
                        }
                    }
                    state.standings.assignCompetitionRank { $0.stats.krRoad }
                case 10: // 경기당 득점
                    state.standings.sort { $0.stats.ptsPG > $1.stats.ptsPG }
                    state.standings.assignCompetitionRank { $0.stats.ptsPG }
                case 11: // 경기당 득실마진
                    state.standings.sort { $0.stats.plusMinusPG > $1.stats.plusMinusPG }
                    state.standings.assignCompetitionRank { $0.stats.plusMinusPG }
                case 12: // 경기당 도움
                    state.standings.sort { $0.stats.astPG > $1.stats.astPG }
                    state.standings.assignCompetitionRank { $0.stats.astPG }
                case 13: // 경기당 리바운드
                    state.standings.sort { $0.stats.rebPG > $1.stats.rebPG }
                    state.standings.assignCompetitionRank { $0.stats.rebPG }
                case 14: // 야투 성공률
                    state.standings.sort { $0.stats.fgPct > $1.stats.fgPct }
                    state.standings.assignCompetitionRank { $0.stats.fgPct }
                case 15: // 3점 성공률
                    state.standings.sort { $0.stats.fg3Pct > $1.stats.fg3Pct }
                    state.standings.assignCompetitionRank { $0.stats.fg3Pct }
                case 16: // 자유투 성공률
                    state.standings.sort { $0.stats.ftPct > $1.stats.ftPct }
                    state.standings.assignCompetitionRank { $0.stats.ftPct }
                case 17: // 경기당 스틸
                    state.standings.sort { $0.stats.stlPG > $1.stats.stlPG }
                    state.standings.assignCompetitionRank { $0.stats.stlPG }
                case 18: // 경기당 블록
                    state.standings.sort { $0.stats.blkPG > $1.stats.blkPG }
                    state.standings.assignCompetitionRank { $0.stats.blkPG }
                case 19: // 경기당 턴오버
                    state.standings.sort { $0.stats.tovPG < $1.stats.tovPG }
                    state.standings.assignCompetitionRank { $0.stats.tovPG }
                case 20: // 경기당 파울
                    state.standings.sort { $0.stats.pfPG < $1.stats.pfPG }
                    state.standings.assignCompetitionRank { $0.stats.pfPG }
                default:
                    break
                }
                
                return .none
                
            case let .showTeamStats(id):
                let team = state.responseModel.standings.first { $0.team.id == id }
                let responseModel = NBATeamInfoResponseModel(info: team, lastGame: nil, nextGame: nil)
                
                let dataModel: SportDecodableModel = .nbaTeamStats(
                    responseModel,
                    ModelConverter.shared.nbaTeamStatsConverter(response: responseModel)
                )
                
                return .send(.delegate(.showTeamStats(model: dataModel)))
                
            case .baseStandings:
                return .none
                
            case .delegate:
                return .none
            } // switch action
            
            func streakValue(_ streak: String) -> Double {
                let streakNumber = extractNumber(from: streak)
                let sign = streak.lowercased().hasPrefix("w") ? 1 : -1
                return Double(streakNumber * sign)
            }
            
            func extractNumber(from string: String) -> Int {
                let upper = string.uppercased()
                let digits = upper.dropFirst().filter { $0.isNumber }
                return Int(String(digits)) ?? 0
            }
        }
    }
}
