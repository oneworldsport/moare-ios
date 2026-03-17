//
//  TournamentBracketSingleGameItem.swift
//  moare
//
//  Created by Mohwa Yoon on 9/16/25.
//

import SwiftUI

// NOTE: 현재는 축구에서만 쓰임
struct TournamentBracketSingleLeftGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let teamNameDic: [String: String]
    let game: GameForSchedule<T>?
    let seedIdTuple: (topSeedId: Int?, lowerSeedId: Int?)
    let itemPosition: RoundSeriesKey // ui상에서 시리즈의 위치 ex) 1라운드의 첫번째 시리즈면 1_1
    
    @Binding var itemHeights: [RoundSeriesKey: CGFloat]
    
    let selectGame: ((GameForSchedule<T>) -> Void)?
    
    @State private var itemHeight: CGFloat = 0
    
    var body: some View {
        let topSeedTeamId = seedIdTuple.topSeedId
        let lowerSeedTeamId = seedIdTuple.lowerSeedId
        let gameStatus = game?.gameStatus ?? Constants.GameStatus.Football.notStarted
        let elapsed = (game as? FBGameForSchedule)?.gameInfo?.status?.elapsed
        let shouldShowScore = !Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: gameStatus)
        
        let homeTeamScore = game?.homeTeamScore ?? 0
        let awayTeamScore = game?.awayTeamScore ?? 0
        let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
        let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
        
        var topSeedTeamScore: Int {
            if game?.homeTeamId == topSeedTeamId && game?.awayTeamId == lowerSeedTeamId {
                homeTeamScore
            } else {
                awayTeamScore
            }
        }
        var lowerSeedTeamScore: Int {
            if game?.homeTeamId == lowerSeedTeamId && game?.awayTeamId == topSeedTeamId {
                homeTeamScore
            } else {
                awayTeamScore
            }
        }
        var topSeedTeamPenaltyScore: Int? {
            if game?.homeTeamId == topSeedTeamId && game?.awayTeamId == lowerSeedTeamId {
                homeTeamPenaltyScore
            } else {
                awayTeamPenaltyScore
            }
        }
        var lowerSeedTeamPenaltyScore: Int? {
            if game?.homeTeamId == lowerSeedTeamId && game?.awayTeamId == topSeedTeamId {
                homeTeamPenaltyScore
            } else {
                awayTeamPenaltyScore
            }
        }
        
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .trailing, spacing: 0) {
                    TournamentHBar(width: 75)
                    
                    TournamentVBar(height: topHeight())
                }
                
                Spacer()
            }
            .padding(.top, topPadding())
            
            HStack(spacing: 0) {
                Button(action: {
                    if let game {
                        selectGame?(game)
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            HStack {
                                Text(topSeedTeamId == nil ? "미정" : teamNameDic["short_\(topSeedTeamId ?? 0)"] ?? "")
                                    .font(.system(size: 15, weight: .medium))
                                
                                URLImage(
                                    url: Util.teamLogoURL(leagueId: leagueId, teamId: topSeedTeamId),
                                    size: .small
                                )
                            }
                            .frame(width: 110)
                            
                            // 축구 패널티킥 경기는 일반 스코어 검정색
                            let scoreColor: Color = (topSeedTeamPenaltyScore != nil && lowerSeedTeamPenaltyScore != nil) ? .primary : (topSeedTeamScore >= lowerSeedTeamScore ? .moare : .primary)
                            
                            Text(shouldShowScore ? "\(topSeedTeamScore)" : "-")
                                .foregroundStyle(shouldShowScore ? scoreColor : .primary)
                            
                            if let topSeedTeamPenaltyScore, let lowerSeedTeamPenaltyScore {
                                Text("\(topSeedTeamPenaltyScore)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(topSeedTeamPenaltyScore >= lowerSeedTeamPenaltyScore ? .moare : .primary)
                            }
                        }
                        .padding(.bottom, 2)
                        
                        VStack(spacing: 0) {
                            // game status
                            GameStatusCapsuleButton(
                                gameStatusContext: .football(status: gameStatus, elapsed: elapsed), leagueId: leagueId
                            ){}
                            
                            // game date
                            if let date = game?.date {
                                Text(CalendarUtil.formatDate(date: date).split(separator: " ").first ?? "")
                                    .font(.system(size: 12))
                                    .padding(.top, 2)
                                
                                Text(CalendarUtil.formatDate(date: date, outputFormatType: .ampm))
                                    .font(.system(size: 12))
                                    .padding(.bottom, 2)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            HStack {
                                Text(lowerSeedTeamId == nil ? "미정" : teamNameDic["short_\(lowerSeedTeamId ?? 0)"] ?? "")
                                    .font(.system(size: 15, weight: .medium))
                                
                                URLImage(
                                    url: Util.teamLogoURL(leagueId: leagueId, teamId: lowerSeedTeamId),
                                    size: .small
                                )
                            }
                            .frame(width: 110)
                            
                            // 축구 패널티킥 경기는 일반 스코어 검정색
                            let scoreColor: Color = (topSeedTeamPenaltyScore != nil && lowerSeedTeamPenaltyScore != nil) ? .primary : (lowerSeedTeamScore >= topSeedTeamScore ? .moare : .primary)
                            
                            Text(shouldShowScore ? "\(lowerSeedTeamScore)" : "-")
                                .foregroundStyle(shouldShowScore ? scoreColor : .primary)
                            
                            if let topSeedTeamPenaltyScore, let lowerSeedTeamPenaltyScore {
                                Text("\(lowerSeedTeamPenaltyScore)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(lowerSeedTeamPenaltyScore >= topSeedTeamPenaltyScore ? .moare : .primary)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                .foregroundStyle(.primary)
                .frame(width: 150)
                .readSize { size in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        itemHeight = size.height
                        itemHeights[itemPosition] = size.height
                    }
                }
                
                // bar
                VStack(alignment: .trailing, spacing: 0) {
                    TournamentHBar()
                    
                    TournamentVBar()
                    
                    TournamentHBar()
                }
                .padding(.vertical, 15)
                .frame(height: itemHeight)
            }
            
            HStack {
                VStack(alignment: .trailing, spacing: 0) {
                    TournamentVBar(height: bottomHeight())
                    
                    TournamentHBar(width: 75)
                }
                
                Spacer()
            }
            .padding(.bottom, bottomPadding())
        }
        .frame(width: 170)
    } // View
    
    private func h(_ r: Int, _ s: Int) -> CGFloat {
        itemHeights[RoundSeriesKey(round: r, series: s)] ?? 0
    }
    
    private func topPadding() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (2, 1): return h(1, 1) / 2
        case (2, 2): return h(1, 3) / 2
        case (3, 1): return h(1, 1) + (h(2, 1) / 2)
        case (4, 1): return h(1, 1) + h(2, 1) + (h(3, 1) / 2)
        default: return 0
        }
    }
    
    private func topHeight() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (2, 1): return h(1, 1) / 2
        case (2, 2): return h(1, 3) / 2
        case (3, 1): return h(1, 2) + (h(2, 1) / 2)
        case (4, 1): return h(3, 1) / 2 // NOTE: 일단은 KBO의 경우만 고려
        default: return 0
        }
    }
    
    private func bottomPadding() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (2, 1): return h(1, 2) / 2
        case (2, 2): return h(1, 4) / 2
        case (3, 1): return h(1, 4) + (h(2, 2) / 2)
        default: return 0
        }
    }
    
    private func bottomHeight() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (2, 1): return h(1, 2) / 2
        case (2, 2): return h(1, 4) / 2
        case (3, 1): return h(1, 3) + (h(2, 2) / 2)
        default: return 0
        }
    }
}

struct TournamentBracketSingleRightGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let teamNameDic: [String: String]
    let game: GameForSchedule<T>?
    let seedIdTuple: (topSeedId: Int?, lowerSeedId: Int?)
    let itemPosition: RoundSeriesKey // ui상에서 시리즈의 위치 ex) 1라운드의 첫번째 시리즈면 1_1
    
    @Binding var itemHeights: [RoundSeriesKey: CGFloat]
    
    let selectGame: ((GameForSchedule<T>) -> Void)?
    
    @State private var itemHeight: CGFloat = 0
    
    var body: some View {
        let topSeedTeamId = seedIdTuple.topSeedId
        let lowerSeedTeamId = seedIdTuple.lowerSeedId
        let gameStatus = game?.gameStatus ?? Constants.GameStatus.Football.notStarted
        let elapsed = (game as? FBGameForSchedule)?.gameInfo?.status?.elapsed
        let shouldShowScore = !Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: gameStatus)
        
        let homeTeamScore = game?.homeTeamScore ?? 0
        let awayTeamScore = game?.awayTeamScore ?? 0
        let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
        let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
        
        var topSeedTeamScore: Int {
            if game?.homeTeamId == topSeedTeamId && game?.awayTeamId == lowerSeedTeamId {
                homeTeamScore
            } else {
                awayTeamScore
            }
        }
        var lowerSeedTeamScore: Int {
            if game?.homeTeamId == lowerSeedTeamId && game?.awayTeamId == topSeedTeamId {
                homeTeamScore
            } else {
                awayTeamScore
            }
        }
        var topSeedTeamPenaltyScore: Int? {
            if game?.homeTeamId == topSeedTeamId && game?.awayTeamId == lowerSeedTeamId {
                homeTeamPenaltyScore
            } else {
                awayTeamPenaltyScore
            }
        }
        var lowerSeedTeamPenaltyScore: Int? {
            if game?.homeTeamId == lowerSeedTeamId && game?.awayTeamId == topSeedTeamId {
                homeTeamPenaltyScore
            } else {
                awayTeamPenaltyScore
            }
        }
        
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    TournamentHBar(width: 75)
                    
                    TournamentVBar(height: topHeight())
                }
            }
            .padding(.top, topPadding())
            
            HStack(spacing: 0) {
                // bar
                VStack(alignment: .leading, spacing: 0) {
                    TournamentHBar()
                    
                    TournamentVBar()
                    
                    TournamentHBar()
                }
                .padding(.vertical, 15)
                .frame(height: itemHeight)
                
                Button(action: {
                    if let game {
                        selectGame?(game)
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            // 축구 패널티킥 경기는 일반 스코어 검정색
                            let scoreColor: Color = (topSeedTeamPenaltyScore != nil && lowerSeedTeamPenaltyScore != nil) ? .primary : (topSeedTeamScore >= lowerSeedTeamScore ? .moare : .primary)
                            
                            Text(shouldShowScore ? "\(topSeedTeamScore)" : "-")
                                .foregroundStyle(shouldShowScore ? scoreColor : .primary)
                            
                            if let topSeedTeamPenaltyScore, let lowerSeedTeamPenaltyScore {
                                Text("\(topSeedTeamPenaltyScore)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(topSeedTeamPenaltyScore >= lowerSeedTeamPenaltyScore ? .moare : .primary)
                            }
                            
                            HStack {
                                Text(topSeedTeamId == nil ? "미정" : teamNameDic["short_\(topSeedTeamId ?? 0)"] ?? "")
                                    .font(.system(size: 15, weight: .medium))
                                
                                URLImage(
                                    url: Util.teamLogoURL(leagueId: leagueId, teamId: topSeedTeamId),
                                    size: .small
                                )
                            }
                            .frame(width: 110)
                        }
                        .padding(.bottom, 2)
                        
                        VStack(spacing: 0) {
                            // game status
                            GameStatusCapsuleButton(
                                gameStatusContext: .football(status: gameStatus, elapsed: elapsed), leagueId: leagueId
                            ){}
                            
                            // game date
                            if let date = game?.date {
                                Text(CalendarUtil.formatDate(date: date).split(separator: " ").first ?? "")
                                    .font(.system(size: 12))
                                    .padding(.top, 2)
                                
                                Text(CalendarUtil.formatDate(date: date, outputFormatType: .ampm))
                                    .font(.system(size: 12))
                                    .padding(.bottom, 2)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            // 축구 패널티킥 경기는 일반 스코어 검정색
                            let scoreColor: Color = (topSeedTeamPenaltyScore != nil && lowerSeedTeamPenaltyScore != nil) ? .primary : (lowerSeedTeamScore >= topSeedTeamScore ? .moare : .primary)
                            
                            Text(shouldShowScore ? "\(lowerSeedTeamScore)" : "-")
                                .foregroundStyle(shouldShowScore ? scoreColor : .primary)
                            
                            if let topSeedTeamPenaltyScore, let lowerSeedTeamPenaltyScore {
                                Text("\(lowerSeedTeamPenaltyScore)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(lowerSeedTeamPenaltyScore >= topSeedTeamPenaltyScore ? .moare : .primary)
                            }
                            
                            HStack {
                                Text(lowerSeedTeamId == nil ? "미정" : teamNameDic["short_\(lowerSeedTeamId ?? 0)"] ?? "")
                                    .font(.system(size: 15, weight: .medium))
                                
                                URLImage(
                                    url: Util.teamLogoURL(leagueId: leagueId, teamId: lowerSeedTeamId),
                                    size: .small
                                )
                            }
                            .frame(width: 110)
                        }
                        .padding(.top, 2)
                    }
                }
                .foregroundStyle(.primary)
                .frame(width: 150)
                .readSize { size in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        itemHeight = size.height
                        itemHeights[itemPosition] = size.height
                    }
                }
            }
            
            HStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    TournamentVBar(height: bottomHeight())
                    
                    TournamentHBar(width: 75)
                }
            }
            .padding(.bottom, bottomPadding())
        }
        .frame(width: 170)
    } // View
    
    private func h(_ r: Int, _ s: Int) -> CGFloat {
        itemHeights[RoundSeriesKey(round: r, series: s)] ?? 0
    }
    
    private func topPadding() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (6, 1): return h(7, 1) / 2
        case (6, 2): return h(7, 3) / 2
        case (5, 1): return h(7, 1) + (h(6, 1) / 2)
        default: return 0
        }
    }
    
    private func topHeight() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (6, 1): return h(7, 1) / 2
        case (6, 2): return h(7, 3) / 2
        case (5, 1): return h(7, 2) + (h(6, 1) / 2)
        default: return 0
        }
    }
    
    private func bottomPadding() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (6, 1): return h(7, 2) / 2
        case (6, 2): return h(7, 4) / 2
        case (5, 1): return h(7, 4) + (h(6, 2) / 2)
        default: return 0
        }
    }
    
    private func bottomHeight() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (6, 1): return h(7, 2) / 2
        case (6, 2): return h(7, 4) / 2
        case (5, 1): return h(7, 3) + (h(6, 2) / 2)
        default: return 0
        }
    }
}

struct TournamentBracketSingleFinalGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let teamNameDic: [String: String]
    let game: GameForSchedule<T>?
    let seedIdTuple: (topSeedId: Int?, lowerSeedId: Int?)
    
    @Binding var itemHeights: [RoundSeriesKey: CGFloat]
    
    let selectGame: ((GameForSchedule<T>) -> Void)?
    
    @State private var itemTopPadding: CGFloat = 0 // 아이템 Y 위치
    
    var body: some View {
        let topSeedTeamId = seedIdTuple.topSeedId
        let lowerSeedTeamId = seedIdTuple.lowerSeedId
        let gameStatus = game?.gameStatus ?? Constants.GameStatus.Football.notStarted
        let elapsed = (game as? FBGameForSchedule)?.gameInfo?.status?.elapsed
        let shouldShowScore = !Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: gameStatus)
        
        let homeTeamScore = game?.homeTeamScore ?? 0
        let awayTeamScore = game?.awayTeamScore ?? 0
        let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
        let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
        
        var topSeedTeamScore: Int {
            if game?.homeTeamId == topSeedTeamId && game?.awayTeamId == lowerSeedTeamId {
                homeTeamScore
            } else {
                awayTeamScore
            }
        }
        var lowerSeedTeamScore: Int {
            if game?.homeTeamId == lowerSeedTeamId && game?.awayTeamId == topSeedTeamId {
                homeTeamScore
            } else {
                awayTeamScore
            }
        }
        var topSeedTeamPenaltyScore: Int? {
            if game?.homeTeamId == topSeedTeamId && game?.awayTeamId == lowerSeedTeamId {
                homeTeamPenaltyScore
            } else {
                awayTeamPenaltyScore
            }
        }
        var lowerSeedTeamPenaltyScore: Int? {
            if game?.homeTeamId == lowerSeedTeamId && game?.awayTeamId == topSeedTeamId {
                homeTeamPenaltyScore
            } else {
                awayTeamPenaltyScore
            }
        }
        
        Button(action: {
            if let game {
                selectGame?(game)
            }
        }) {
            HStack {
                VStack {
                    URLImage(
                        url: Util.teamLogoURL(leagueId: leagueId, teamId: topSeedTeamId),
                        size: .small
                    )
                    
                    Text(topSeedTeamId == nil ? "미정" : teamNameDic["short_\(topSeedTeamId ?? 0)"] ?? "")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(width: 100)
                
                VStack(spacing: 2) {
                    // 축구 패널티킥 경기는 일반 스코어 검정색
                    let scoreColor: Color = (topSeedTeamPenaltyScore != nil && lowerSeedTeamPenaltyScore != nil) ? .primary : (topSeedTeamScore >= lowerSeedTeamScore ? .moare : .primary)
                    
                    Text(shouldShowScore ? "\(topSeedTeamScore)" : "-")
                        .foregroundStyle(shouldShowScore ? scoreColor : .primary)
                    
                    if let topSeedTeamPenaltyScore, let lowerSeedTeamPenaltyScore {
                        Text("\(topSeedTeamPenaltyScore)")
                            .font(.system(size: 12))
                            .foregroundStyle(topSeedTeamPenaltyScore >= lowerSeedTeamPenaltyScore ? .moare : .primary)
                    }
                }
                
                VStack(spacing: 0) {
                    // game status
                    GameStatusCapsuleButton(
                        gameStatusContext: .football(status: gameStatus, elapsed: elapsed), leagueId: leagueId
                    ){}
                    
                    // game date
                    if let date = game?.date {
                        Text(CalendarUtil.formatDate(date: date).split(separator: " ").first ?? "")
                            .font(.system(size: 12))
                            .padding(.top, 2)
                        
                        Text(CalendarUtil.formatDate(date: date, outputFormatType: .ampm))
                            .font(.system(size: 12))
                            .padding(.bottom, 2)
                    }
                }
                .frame(width: 110)
                
                VStack(spacing: 2) {
                    // 축구 패널티킥 경기는 일반 스코어 검정색
                    let scoreColor: Color = (topSeedTeamPenaltyScore != nil && lowerSeedTeamPenaltyScore != nil) ? .primary : (lowerSeedTeamScore >= topSeedTeamScore ? .moare : .primary)
                    
                    Text(shouldShowScore ? "\(lowerSeedTeamScore)" : "-")
                        .foregroundStyle(shouldShowScore ? scoreColor : .primary)
                    
                    if let topSeedTeamPenaltyScore, let lowerSeedTeamPenaltyScore {
                        Text("\(lowerSeedTeamPenaltyScore)")
                            .font(.system(size: 12))
                            .foregroundStyle(lowerSeedTeamPenaltyScore >= topSeedTeamPenaltyScore ? .moare : .primary)
                    }
                }
                
                VStack {
                    URLImage(
                        url: Util.teamLogoURL(leagueId: leagueId, teamId: lowerSeedTeamId),
                        size: .small
                    )
                    
                    Text(lowerSeedTeamId == nil ? "미정" : teamNameDic["short_\(lowerSeedTeamId ?? 0)"] ?? "")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(width: 100)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.moare, lineWidth: 1)
            }
        }
        .foregroundStyle(.primary)
//        .padding(.top, itemTopPadding)
        .padding(.top, 250)
        .padding(.horizontal, 8)
        .onAppear {
            // TODO: onAppear할때 값이 아직 없음..
//            itemTopPadding = h(1, 1) + h(2, 1) + h(3, 1)
        }
    }
    
    private func h(_ r: Int, _ s: Int) -> CGFloat {
        itemHeights[RoundSeriesKey(round: r, series: s)] ?? 0
    }
}
