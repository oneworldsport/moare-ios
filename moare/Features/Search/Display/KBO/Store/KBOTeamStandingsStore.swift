//
//  KBOTeamStandingsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/8/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KBOTeamStandingsStore {
    typealias BaseStandings = BaseTeamStandingsStore<KBOTeamStandingsDisplayModel>
    
    @ObservableState
    struct State {
        let responseModel: KBOTeamStandingsResponseModel
        var baseStandings: BaseStandings.State
        
        var standings: [KBOTeamStandingsDisplay] = []
        
        init(responseModel: KBOTeamStandingsResponseModel, displayModel: KBOTeamStandingsDisplayModel) {
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
                state.standings = state.baseStandings.displayModel.standings
                state.baseStandings.categorySelectedIndex = 1 // defalue category is "승률"
                
                return .send(.sortStandings)
                
            case .baseStandings(.selectCategory):
                return .send(.sortStandings)
                
            case .sortStandings:
                switch state.baseStandings.categorySelectedIndex {
                case 0: // 승률
                    state.standings.sort { Double($0.stats.rankData.winpct) ?? 0 > Double($1.stats.rankData.winpct) ?? 0 }
                case 1: // 게임차
                    state.standings.sort { Double($0.stats.rankData.gb) ?? 0 < Double($1.stats.rankData.gb) ?? 0 }
                case 2: // 승
                    state.standings.sort { Int($0.stats.rankData.wins) ?? 0 > Int($1.stats.rankData.wins) ?? 0 }
                case 3: // 패
                    state.standings.sort { Int($0.stats.rankData.losses) ?? 0 < Int($1.stats.rankData.losses) ?? 0 }
                case 4: // 경기수
                    state.standings.sort { Int($0.stats.rankData.gp) ?? 0 > Int($1.stats.rankData.gp) ?? 0 }
                case 5: // 연속
                    state.standings.sort { a, b in
                        let aStreak = a.stats.rankData.streak
                        let bStreak = b.stats.rankData.streak
                        let aIsWin = aStreak.hasSuffix("승")
                        let bIsWin = bStreak.hasSuffix("승")

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
                case 6: // 타율
                    state.standings.sort { Double($0.stats.hitterData.avg) ?? 0 > Double($1.stats.hitterData.avg) ?? 0 }
                case 7: // 안타
                    state.standings.sort { Int($0.stats.hitterData.h) ?? 0 > Int($1.stats.hitterData.h) ?? 0 }
                case 8: // 홈런
                    state.standings.sort { Int($0.stats.hitterData.hr) ?? 0 > Int($1.stats.hitterData.hr) ?? 0 }
                case 9: // 장타율
                    state.standings.sort { Double($0.stats.hitterData.slg) ?? 0 > Double($1.stats.hitterData.slg) ?? 0 }
                case 10: // 득점
                    state.standings.sort { Int($0.stats.hitterData.r) ?? 0 > Int($1.stats.hitterData.r) ?? 0 }
                case 11: // 평균자책
                    state.standings.sort { Double($0.stats.pitcherData.era) ?? 0 < Double($1.stats.pitcherData.era) ?? 0 }
                case 12: // 피안타율
                    state.standings.sort { Double($0.stats.pitcherData.avg) ?? 0 < Double($1.stats.pitcherData.avg) ?? 0 }
                case 13: // 피안타
                    state.standings.sort { Int($0.stats.pitcherData.h) ?? 0 < Int($1.stats.pitcherData.h) ?? 0 }
                case 14: // 피홈런
                    state.standings.sort { Int($0.stats.pitcherData.hr) ?? 0 < Int($1.stats.pitcherData.hr) ?? 0 }
                case 15: // 실점
                    state.standings.sort { Int($0.stats.pitcherData.r) ?? 0 < Int($1.stats.pitcherData.r) ?? 0 }
                case 16: // 도루성공률
                    state.standings.sort { Double($0.stats.runnerData.sbPercent) ?? 0 > Double($1.stats.runnerData.sbPercent) ?? 0 }
                default: break
                }
                
                return .none
                
            case .baseStandings:
                return .none
                
            case let .showTeamStats(id):
                let team = state.responseModel.standings.first { $0.team.id == id }
                let responseModel = KBOTeamInfoResponseModel(info: team, lastGame: nil, nextGame: nil)
                
                let dataModel: SportDecodableModel = .kboTeamStats(
                    responseModel,
                    ModelConverter.shared.kboTeamStatsConverter(response: responseModel)
                )
                
                return .send(.delegate(.showTeamStats(model: dataModel)))
                
            case .delegate:
                return .none
            }
            
            func extractNumber(from string: String) -> Int {
                return Int(string.dropLast()) ?? 0
            }
        }
    }
}
