//
//  TournamentSingleGameItem.swift
//  moare
//
//  Created by Mohwa Yoon on 9/16/25.
//

import SwiftUI

// NOTE: 현재는 축구에서만 쓰임
struct TournamentSingleGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let game: GameForSchedule<T>
    let teamNameDic: [String: String]
    
    var body: some View {
        let homeTeamId = game.homeTeamId
        let awayTeamId = game.awayTeamId
        let homeTeamScore = game.homeTeamScore
        let awayTeamScore = game.awayTeamScore
        let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
        let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
        let elapsed = (game as? FBGameForSchedule)?.gameInfo?.status?.elapsed
        let extra = (game as? FBGameForSchedule)?.gameInfo?.status?.extra
        let shouldShowScore = !Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game.gameStatus)
        let isFinished = Constants.GameStatus.Football.finishedList.contains(game.gameStatus)
        
        var isHomeWinner: Bool {
            if let homePenalty = homeTeamPenaltyScore,
               let awayPenalty = awayTeamPenaltyScore {
                return homePenalty > awayPenalty
            }
            
            return homeTeamScore > awayTeamScore
        }
        
        HStack(spacing: 0) {
            Button(action: {
            }) {
                VStack(spacing: 2) {
                    if isFinished && isHomeWinner {
                        HCapsuleBar()
                            .padding(.bottom, 4)
                    }
                    
                    URLImage(url: Util.teamLogoURL(leagueId: leagueId, teamId: homeTeamId), size: .small)
                    
                    Text(teamNameDic["short_\(homeTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
            }
            .frame(width: 80)
            .foregroundStyle(.primary)
            .opacity((isFinished && !isHomeWinner) ? 0.3 : 1)
            
            if shouldShowScore {
                VStack(spacing: 2) {
                    // 축구 패널티킥 경기는 일반 스코어 검정색
                    let scoreColor: Color = (homeTeamPenaltyScore != nil && awayTeamPenaltyScore != nil) ? .primary : (homeTeamScore >= awayTeamScore ? .moare : .primary)
                    
                    Text("\(homeTeamScore)")
                        .frame(width: 30)
                        .foregroundStyle(scoreColor)
                    
                    if let homeTeamPenaltyScore, let awayTeamPenaltyScore {
                        Text("\(homeTeamPenaltyScore)")
                            .font(.system(size: 12))
                            .foregroundStyle(homeTeamPenaltyScore >= awayTeamPenaltyScore ? .moare : .primary)
                    }
                }
            }
            
            VStack(spacing: 0) {
                // game status                
                GameStatusCapsuleButton(
                    gameStatusContext: .football(status: game.gameStatus, elapsed: elapsed, extra: extra), leagueId: leagueId
                ){}
                
                // game date
                Text(CalendarUtil.formatDate(date: game.date).split(separator: " ").first ?? "")
                    .font(.system(size: 12))
                    .padding(.top, 2)
                
                Text(CalendarUtil.formatDate(date: game.date, outputFormatType: .ampm))
                    .font(.system(size: 12))
                    .padding(.bottom, 2)
            }
            .frame(width: 110)
            
            if shouldShowScore {
                VStack(spacing: 2) {
                    // 축구 패널티킥 경기는 일반 스코어 검정색
                    let scoreColor: Color = (homeTeamPenaltyScore != nil && awayTeamPenaltyScore != nil) ? .primary : (awayTeamScore >= homeTeamScore ? .moare : .primary)
                    
                    Text("\(awayTeamScore)")
                        .frame(width: 30)
                        .foregroundStyle(scoreColor)
                    
                    if let homeTeamPenaltyScore, let awayTeamPenaltyScore {
                        // TODO: 유령 버그..? 로직은 문제 없는데 스코어가 안나옴. 중간에 이상한 Text하나 추가하면 나옴...
                        Text("\(awayTeamPenaltyScore)")
                            .font(.system(size: 12))
                            .foregroundStyle(awayTeamPenaltyScore >= homeTeamPenaltyScore ? .moare : .primary)
                    }
                }
            }
            
            Button(action: {
            }) {
                VStack(spacing: 2) {
                    if isFinished && !isHomeWinner {
                        HCapsuleBar()
                            .padding(.bottom, 4)
                    }
                    
                    URLImage(url: Util.teamLogoURL(leagueId: leagueId, teamId: awayTeamId), size: .small)
                    
                    Text(teamNameDic["short_\(awayTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
            }
            .frame(width: 80)
            .foregroundStyle(.primary)
            .opacity((isFinished && isHomeWinner) ? 0.3 : 1)
        }
    }
}
