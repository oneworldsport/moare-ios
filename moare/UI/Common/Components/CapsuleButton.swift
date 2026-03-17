//
//  CapsuleButton.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/7/25.
//

import SwiftUI

struct CapsuleButton: View {
    let text: String
    let color: Color
    let onClick: () -> Void
    
    init(text: String, color: Color = .moare, onClick: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.onClick = onClick
    }
    
    var body: some View {
        Button(action: {
            onClick()
        }) {
            Text(text)
                .font(.system(size: 12))
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 1)
                }
        }
        .foregroundStyle(color)
    }
}

//#Preview {
//    CapsuleButton(text: "test", onClick: {})
//}

enum GameStatusContext {
    case tennis(status: Int?, isResultOpened: Bool = true)
    case nba(status: Int, period: Int? = nil, isResultOpened: Bool = true)
    case mlb(status: String, currentInning: String? = nil, linescore: MLBGameLineScore? = nil, isResultOpened: Bool = true)
    case football(status: String, elapsed: Int?, isResultOpened: Bool = true)
    case kbo(status: String, currentInning: String? = nil, isResultOpened: Bool = true)
}

struct GameStatusCapsuleButton: View {
    let gameStatusContext: GameStatusContext
    let leagueId: Int
    let onClick: () -> Void
    
    var text: String {
        switch gameStatusContext {
        case .tennis(let status, _):
            return Constants.GameStatus.tennisGameStatusText(status: status)
        case .nba(let status, let period, _):
            return Constants.GameStatus.nbaGameStatusText(status: status, period: period)
        case .mlb(let status, _,let linescore, _):
            return Constants.GameStatus.mlbGameStatusText(status: status, linescore: linescore)
        case .football(let status, let elapsed, _):
            return Constants.GameStatus.fbGameStatusText(status: status, elapsed: elapsed)
        case .kbo(let status, let currentInning, _):
            return Constants.GameStatus.kboGameStatusText(status: status, currentInning: currentInning)
        default:
            return ""
        }
    }
    
    var color: Color {
        switch gameStatusContext {
        case .tennis(let status, _):
            return Constants.GameStatus.gameStatusColor(leagueId: leagueId, status: String(status ?? 0))
        case .nba(let status, _, _):
            return Constants.GameStatus.gameStatusColor(leagueId: leagueId, status: String(status))
        case .mlb(let status, _, _, _):
            return Constants.GameStatus.gameStatusColor(leagueId: leagueId, status: status)
        case .football(let status, _, _):
            return Constants.GameStatus.gameStatusColor(leagueId: leagueId, status: status)
        case .kbo(let status, _, _):
            return Constants.GameStatus.gameStatusColor(leagueId: leagueId, status: status)
        default:
            return .clear
        }
    }
    
    var body: some View {
        CapsuleButton(text: text, color: color) {
            onClick()
        }
    }
}
