//
//  ScheduleGameItem.swift
//  moare
//
//  Created by Mohwa Yoon on 6/5/25.
//

import SwiftUI

struct ScheduleGameItem: View {
    let state: ScheduleGameItemState
    let actions: ScheduleGameItemActions
    
    var body: some View {
        let homeTeamScore = state.homeTeamScore
        let awayTeamScore = state.awayTeamScore
        
        HStack {
            /* ---------------------
               home
               --------------------- */
            Button(action: {
//                searchStore.send(.updateTextField("토트넘"))
//                searchStore.send(.performSearch())
            }) {
                VStack(spacing: 2) {
                    URLImage(url: state.homeTeamLogo, size: .small, isSvg: state.isSvgLogo)
                    
                    Text(state.homeTeamName)
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
            .frame(width: 100)
            .foregroundStyle(.primary)
            .disabled(true) // TODO: modify when api added
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            // score
            Text("\(homeTeamScore)")
                .frame(maxWidth: 20)
                .opacity(state.isResultOpened ? 1 : 0)
                .foregroundStyle(homeTeamScore >= awayTeamScore ? .moare : .primary)
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            /* ---------------------
               game info
               --------------------- */
            VStack {
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
                    Text(CalendarUtil.formatDate(date: state.date, formatType: .ampm))
                        .font(.system(size: 12))
                        .padding(.vertical, 2)
                } else {
                    Text(CalendarUtil.formatDate(date: state.date).split(separator: " ").first ?? "")
                        .font(.system(size: 12))
                        .padding(.top, 2)
                    
                    Text(CalendarUtil.formatDate(date: state.date, formatType: .ampm))
                        .font(.system(size: 12))
                        .padding(.bottom, 2)
                }
                
                
                // venue
                if state.shouldShowVenue {
                    Text("장소: \(state.venue)")
                        .font(.system(size: 12, weight: .light))
                        .lineLimit(1)
                    .padding(.bottom, 2)
                }
                
                // game type
                if state.shouldShowGameType {
                    
                }
                
                
                // referee
                if state.shouldShowReferee {
                    Text("심판: \(state.referee ?? "")")
                    .font(.system(size: 12, weight: .light))
                    .lineLimit(1)
                }
            }
            .frame(width: 110)
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            /* ---------------------
               away
               --------------------- */
            // socre
            Text("\(awayTeamScore)")
                .frame(maxWidth: 20)
                .opacity(state.isResultOpened ? 1 : 0)
                .foregroundStyle(awayTeamScore >= homeTeamScore ? .moare : .primary)
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            Button(action: {
//                searchStore.send(.updateTextField("토트넘"))
//                searchStore.send(.performSearch())
            }) {
                VStack(spacing: 2) {
                    URLImage(url: state.awayTeamLogo, size: .small, isSvg: state.isSvgLogo)
                    
                    Text(state.awayTeamName)
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
            .frame(width: 100)
            .foregroundStyle(.primary)
            .disabled(true) // TODO: modify when api added
        } // HStack
        .background(Color.clear) // added for tapGesture on Spacer()
        .onTapGesture {
            // TODO: Should change to Button
            if state.isClickEnabled {
                actions.onGameItemClick()                
            }
        }
    }
}
