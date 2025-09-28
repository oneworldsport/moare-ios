//
//  TournamentSingleGameItem.swift
//  moare
//
//  Created by Mohwa Yoon on 9/16/25.
//

import SwiftUI

struct TournamentSingleGameItem: View {
    let state: TournamentGameItemState
    
    var body: some View {
        let homeTeamScore = state.homeTeamScore
        let awayTeamScore = state.awayTeamScore
        
        HStack(spacing: 0) {
            Button(action: {

            }) {
                VStack(spacing: 2) {
                    URLImage(url: state.homeTeamLogo, size: .small)
                    
                    Text(state.homeTeamName)
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
            }
            .frame(width: 80)
            .foregroundStyle(.primary)
            
            if let homeTeamScore, let awayTeamScore {
                Text("\(homeTeamScore)")
                    .frame(width: 30)
                    .foregroundStyle(homeTeamScore >= awayTeamScore ? .moare : .primary)
            }
            
            VStack(spacing: 0) {
                // game status
                CapsuleButton(
                    text: state.gameStatusText,
                    color: state.gameStatusColor
                ) {
                    
                }
                
                // game date
                Text(CalendarUtil.formatDate(date: state.date).split(separator: " ").first ?? "")
                    .font(.system(size: 12))
                    .padding(.top, 2)
                
                Text(CalendarUtil.formatDate(date: state.date, formatType: .ampm))
                    .font(.system(size: 12))
                    .padding(.bottom, 2)
            }
            .frame(width: 110)
            
            if let homeTeamScore, let awayTeamScore {
                Text("\(awayTeamScore)")
                    .frame(width: 30)
                    .foregroundStyle(awayTeamScore >= homeTeamScore ? .moare : .primary)
            }
            
            Button(action: {
            }) {
                VStack(spacing: 2) {
                    URLImage(url: state.awayTeamLogo, size: .small)
                    
                    Text(state.awayTeamName)
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
            }
            .frame(width: 80)
            .foregroundStyle(.primary)
        }
    }
}
