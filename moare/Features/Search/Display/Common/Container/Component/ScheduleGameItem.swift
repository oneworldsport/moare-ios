//
//  ScheduleGameItem.swift
//  moare
//
//  Created by Mohwa Yoon on 6/5/25.
//

import SwiftUI

struct ScheduleGameItem<T: Decodable & Equatable>: View {
    let state: ScheduleGameItemState<T>
    let actions: ScheduleGameItemActions
    
    var body: some View {
        let game = state.game
        let leagueId = state.leagueId
        let teamNameDic = state.teamNameDic
        let homeTeamId = Constants.Ids.checkTeamId(leagueId: leagueId, teamId: game.homeTeamId)
        let awayTeamId = Constants.Ids.checkTeamId(leagueId: leagueId, teamId: game.awayTeamId)
        let homeTeamScore = game.homeTeamScore
        let awayTeamScore = game.awayTeamScore
        let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
        let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
        
        let defaultHomeTeamName = Constants.Ids.tennisAll.contains(leagueId) ? (game as? TennisGameForSchedule)?.gameInfo?.homeTeam?.name ?? "" : ""
        let defaultAwayTeamName = Constants.Ids.tennisAll.contains(leagueId) ? (game as? TennisGameForSchedule)?.gameInfo?.awayTeam?.name ?? "" : ""
        
        HStack(spacing: 0) {
            /* ---------------------
               home
               --------------------- */
            Button(action: {
//                searchStore.send(.updateTextField("토트넘"))
//                searchStore.send(.performSearch())
            }) {
                VStack(spacing: 2) {
                    URLImage(url: Util.teamLogoURL(leagueId: leagueId, teamId: homeTeamId), size: .small)
                    
                    // TODO: 그냥 id가 오류로 없는 경우도 "미정"이라고 나올 수 있음
                    Text(homeTeamId == nil ? "미정" : (teamNameDic["short_\(homeTeamId ?? 0)"] ?? defaultHomeTeamName))
                        .font(.system(size: 13))
                        .lineLimit(2)
                    
                    if state.shouldShowHomeLabel {
                        RoundedBorderText(
                            text: "홈",
                            fontSize: 11,
                            textColor: .moare,
                            radius: 4,
                            strokeColor: .moare
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.primary)
            .disabled(true) // TODO: modify when api added
            
//            Spacer()
//                .frame(maxHeight: 80)
//                .contentShape(Rectangle())
            
            // score
            VStack(spacing: 2) {
                // 축구 패널티킥 경기는 일반 스코어 검정색
                let scoreColor: Color = (homeTeamPenaltyScore != nil && awayTeamPenaltyScore != nil) ? .primary : (homeTeamScore >= awayTeamScore ? .moare : .primary)
                
                Text("\(homeTeamScore)")
                    .foregroundStyle(scoreColor)
                
                if let homeTeamPenaltyScore, let awayTeamPenaltyScore {
                    Text("\(homeTeamPenaltyScore)")
                        .font(.system(size: 12))
                        .foregroundStyle(homeTeamPenaltyScore >= awayTeamPenaltyScore ? .moare : .primary)
                }
            }
            .frame(width: 60)
            .opacity(state.isResultOpened ? 1 : 0) // TODO: onTapGesture is not triggered when opacity is 0
            
//            Spacer()
//                .frame(maxHeight: 80)
//                .contentShape(Rectangle())
            
            /* ---------------------
               game info
               --------------------- */
            VStack(spacing: 0) {
                // game status
                CapsuleButton(
                    text: state.gameStatusText,
                    color: state.gameStatusColor
                ) {
                    actions.onCapsuleButtonClick()
                }
                .disabled(state.isCapsuleButtonDisabled)
                
                // game date
                if state.shouldShowOnlyDateTime {
                    Text(CalendarUtil.formatDate(date: state.game.date, formatType: .ampm))
                        .font(.system(size: 12))
                        .padding(.vertical, 2)
                } else {
                    Text(CalendarUtil.formatDate(date: state.game.date).split(separator: " ").first ?? "")
                        .font(.system(size: 12))
                        .padding(.top, 2)
                    
                    Text(CalendarUtil.formatDate(date: state.game.date, formatType: .ampm))
                        .font(.system(size: 12))
                        .padding(.bottom, 2)
                }
                
                // game type
                // TODO: 나중에 작업
                if let gameType = state.gameType, !gameType.isEmpty, state.shouldShowGameType {
                    Text(gameType)
                        .font(.system(size: 12, weight: .light))
                        .lineLimit(1)
                }
                
                // referee
                if state.referee != nil && state.shouldShowReferee {
                    Text("심판: \(state.referee!)")
                        .font(.system(size: 12, weight: .light))
                        .lineLimit(1)
                }
            }
            .frame(width: 110)
            
//            Spacer()
//                .frame(maxHeight: 80)
//                .contentShape(Rectangle())
            
            /* ---------------------
               away
               --------------------- */
            // socre
            VStack(spacing: 2) {
                // 축구 패널티킥 경기는 일반 스코어 검정색
                let scoreColor: Color = (homeTeamPenaltyScore != nil && awayTeamPenaltyScore != nil) ? .primary : (awayTeamScore >= homeTeamScore ? .moare : .primary)
                
                Text("\(awayTeamScore)")
                    .foregroundStyle(scoreColor)
                
                if let homeTeamPenaltyScore, let awayTeamPenaltyScore {
                    Text("\(awayTeamPenaltyScore)")
                        .font(.system(size: 12))
                        .foregroundStyle(awayTeamPenaltyScore >= homeTeamPenaltyScore ? .moare : .primary)
                }
            }
            .frame(width: 60)
            .opacity(state.isResultOpened ? 1 : 0)
            
//            Spacer()
//                .frame(maxHeight: 80)
//                .contentShape(Rectangle())
            
            Button(action: {
//                searchStore.send(.updateTextField("토트넘"))
//                searchStore.send(.performSearch())
            }) {
                VStack(spacing: 2) {
                    URLImage(url: Util.teamLogoURL(leagueId: leagueId, teamId: awayTeamId), size: .small)
                    
                    Text(awayTeamId == nil ? "미정" : (teamNameDic["short_\(awayTeamId ?? 0)"] ?? defaultAwayTeamName))
                        .font(.system(size: 13))
                        .lineLimit(2)
                    
                    if state.shouldShowAwayLabel {
                        RoundedBorderText(
                            text: "원정",
                            fontSize: 11,
                            textColor: .secondary,
                            radius: 4,
                            strokeColor: .secondary
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.primary)
            .disabled(true) // TODO: modify when api added
        } // HStack
        .padding(.horizontal, 4)
        .background(Color.clear) // added for tapGesture on Spacer()
        .onTapGesture {
            // TODO: Should change to Button
            if state.isClickEnabled {
                actions.onGameItemClick()                
            }
        }
    }
}
