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
    typealias BaseStandings = BaseTeamStandingsStore<MLBTeamStandingsDisplayModel>
    
    @ObservableState
    struct State {
        let columnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 60, 60, 50, 50, 50, 70]
        
        /* ---------------------
           data state
           --------------------- */
        let responseModel: MLBTeamStandingsResponseModel
        var baseStandings: BaseStandings.State
        
        var westStandings: [MLBTeamStandingsDisplay] = []
        var eastStandings: [MLBTeamStandingsDisplay] = []
        var centralStandings: [MLBTeamStandingsDisplay] = []
        
        init(responseModel: MLBTeamStandingsResponseModel, displayModel: MLBTeamStandingsDisplayModel) {
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
                // init data
                state.westStandings = []
                state.eastStandings = []
                state.centralStandings = []
                state.baseStandings.categorySelectedIndex = 1 // defalue category is "승률"
                
                return .send(.baseStandings(.selectHeaderCategory(index: 0, isInit: true)))
                
            case .baseStandings(.selectCategory):
                return .send(.sortStandings)
                
            case let .baseStandings(.selectHeaderCategory(index, isInit)):
                let displayModel = state.baseStandings.displayModel
                
                if isInit {
                    let entityTeam = displayModel.standings.first { team in
                        // Any first team that matches with any team in entityInfo
                        displayModel.entityInfo.first { $0.teamId == team.team.id } != nil
                    }
                    
                    // When init, if entity's league is american, set index 1.
                    // Otherwise do nothing, which would be set as default(0).
                    if entityTeam?.team.league.id == Constants.Ids.americanLeague {
                        state.baseStandings.headerCategorySelectedIndex = 1
                    }
                    
                    state.westStandings = displayModel.standings.filter {
                        if entityTeam?.team.league.id == Constants.Ids.americanLeague {
                            $0.team.division.id == Constants.Ids.americanLeagueWest
                        } else {
                            $0.team.division.id == Constants.Ids.nationalLeagueWest
                        }
                    }
                    state.eastStandings = displayModel.standings.filter {
                        if entityTeam?.team.league.id == Constants.Ids.americanLeague {
                            $0.team.division.id == Constants.Ids.americanLeagueEast
                        } else {
                            $0.team.division.id == Constants.Ids.nationalLeagueEast
                        }
                    }
                    state.centralStandings = displayModel.standings.filter {
                        if entityTeam?.team.league.id == Constants.Ids.americanLeague {
                            $0.team.division.id == Constants.Ids.americanLeagueCentral
                        } else {
                            $0.team.division.id == Constants.Ids.nationalLeagueCentral
                        }
                    }
                } else {
                    state.baseStandings.headerCategorySelectedIndex = index
                    
                    state.westStandings = displayModel.standings.filter {
                        if index == 0 {
                            $0.team.division.id == Constants.Ids.nationalLeagueWest
                        } else {
                            $0.team.division.id == Constants.Ids.americanLeagueWest
                        }
                    }
                    state.eastStandings = displayModel.standings.filter {
                        if index == 0 {
                            $0.team.division.id == Constants.Ids.nationalLeagueEast
                        } else {
                            $0.team.division.id == Constants.Ids.americanLeagueEast
                        }
                    }
                    state.centralStandings = displayModel.standings.filter {
                        if index == 0 {
                            $0.team.division.id == Constants.Ids.nationalLeagueCentral
                        } else {
                            $0.team.division.id == Constants.Ids.americanLeagueCentral
                        }
                    }

                }
                
                return .send(.sortStandings)
                
            case .sortStandings:
                switch state.baseStandings.categorySelectedIndex {
                case 0: // 게임차
                    sortAllDivision(by: <) {
                        Double($0.stats.recordData?.divisionRank ?? "0") ?? 0
                    }
                case 1: // 승률
                    sortAllDivision(by: <) {
                        Double($0.stats.recordData?.divisionRank ?? "0") ?? 0
                    }
                case 2: // 승
                    sortAllDivision(by: >) {
                        Double($0.stats.recordData?.wins ?? 0)
                    }
                case 3: // 패
                    sortAllDivision(by: <) {
                        Double($0.stats.recordData?.losses ?? 0)
                    }
                case 4: // 경기수
                    sortAllDivision(by: >) {
                        Double($0.stats.recordData?.gamesPlayed ?? 0)
                    }
                case 5: // 연속
                    sortAllDivision(by: >) {
                        let streak = $0.stats.recordData?.streak
                        let streakNumber = streak?.streakNumber ?? 0
                        let sign = (streak?.streakType.lowercased().hasPrefix("w") ?? false) ? 1 : -1
                        return Double(streakNumber * sign)
                    }
                case 6: // 타율
                    sortAllDivision(by: >) {
                        Double($0.stats.hitting?.avg ?? "0") ?? 0
                    }
                case 7: // 안타
                    sortAllDivision(by: >) {
                        Double($0.stats.hitting?.hits ?? 0)
                    }
                case 8: // 홈런
                    sortAllDivision(by: >) {
                        Double($0.stats.hitting?.homeRuns ?? 0)
                    }
                case 9: // 장타율
                    sortAllDivision(by: >) {
                        Double($0.stats.hitting?.slg ?? "0") ?? 0
                    }
                case 10: // 득점
                    sortAllDivision(by: >) {
                        Double($0.stats.hitting?.runs ?? 0)
                    }
                case 11: // 평균자책
                    sortAllDivision(by: <) {
                        Double($0.stats.pitching?.era ?? "0") ?? 0
                    }
                case 12: // 피안타율
                    sortAllDivision(by: <) {
                        Double($0.stats.pitching?.avg ?? "0") ?? 0
                    }
                case 13: // 피안타
                    sortAllDivision(by: <) {
                        Double($0.stats.pitching?.hits ?? 0)
                    }
                case 14: // 피홈런
                    sortAllDivision(by: <) {
                        Double($0.stats.pitching?.homeRuns ?? 0)
                    }
                case 15: // 실점
                    sortAllDivision(by: <) {
                        Double($0.stats.pitching?.runs ?? 0)
                    }
                case 16: // 도루성공률
                    sortAllDivision(by: >) {
                        Double($0.stats.hitting?.stolenBasePercentage ?? "0") ?? 0
                    }
                default: break
                }
                
                return .none
                
            case let .showTeamStats(id):
                let team = state.responseModel.standings.first { $0.team.id == id }
                let responseModel = MLBTeamInfoResponseModel(info: team, lastGame: nil, nextGame: nil)
                
                let dataModel: SportDecodableModel = .mlbTeamStats(
                    responseModel,
                    ModelConverter.shared.mlbTeamStatsConverter(response: responseModel)
                )
                
                return .send(.delegate(.showTeamStats(model: dataModel)))
                
            case .delegate:
                return .none
            }
            
            func extractNumber(from string: String) -> Int {
                return Int(string.dropFirst()) ?? 0
            }
            
            func sortAllDivision(
                by order: (Double, Double) -> Bool,
                value: (MLBTeamStandingsDisplay) -> Double
            ) {
                state.westStandings.sort { order(value($0), value($1)) }
                state.eastStandings.sort { order(value($0), value($1)) }
                state.centralStandings.sort { order(value($0), value($1)) }

                state.westStandings.assignCompetitionRank(by: value)
                state.eastStandings.assignCompetitionRank(by: value)
                state.centralStandings.assignCompetitionRank(by: value)
            }
        }
    }
}
