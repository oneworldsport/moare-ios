//
//  TournamentSeriesGameItem.swift
//  moare
//
//  Created by Mohwa Yoon on 9/18/25.
//

import SwiftUI

struct TournamentSeriesLeftGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let teamNameDic: [String: String]
    let maxRound: Int
    let games: [GameForSchedule<T>]?
    let itemPosition: RoundSeriesKey // ui상에서 시리즈의 위치 ex) 1라운드의 첫번째 시리즈면 1_1
    
    var shouldRemoveHBar = false // NOTE: MLB의 경우 이전 라운드에 시리즈가 하나 없으면 하단에 HBar가 필요없는 경우가 있음. KBO는 그냥 필요없음.
    
    @Binding var itemHeights: [RoundSeriesKey: CGFloat]
    
    let selectSeries: (([GameForSchedule<T>]) -> Void)?
    
    private let scoreTitleHeight: CGFloat = 16
    @State private var itemHeight: CGFloat = 0
    @State private var isScoreOpened = false
    
    var body: some View {
        if let games {
            let game = games.first
            let topSeedTeamId = game?.isHomeTopSeed == true ? game?.homeTeamIdOrNil : game?.awayTeamIdOrNil
            let lowerSeedTeamId = game?.isHomeTopSeed == true ? game?.awayTeamIdOrNil : game?.homeTeamIdOrNil
            let isUEFALeague = Constants.Ids.footballUEFALeagues.contains(leagueId)
            let isSeriesStarted = if isUEFALeague {
                // UEFA리그(합산 스코어 방식)는 경기중이어도 isSeriesStarted = true
                !Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game?.gameStatus ?? "")
            } else {
                Constants.GameStatus.isGameFinished(leagueId: leagueId, status: game?.gameStatus ?? "")
            }
            
            let (topSeedTeamSeriesScore, lowerSeedTeamSeriesScore) = games.reduce((0, 0)) { partial, game in
                var (top, lower) = partial
                
                let homeTeamScore = game.homeTeamScore
                let awayTeamScore = game.awayTeamScore
                let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
                let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
                
                var isHomeWinner: Bool {
                    if let homePenalty = homeTeamPenaltyScore,
                       let awayPenalty = awayTeamPenaltyScore {
                        return homePenalty > awayPenalty
                    }
                    
                    return homeTeamScore > awayTeamScore
                }
                var isAwayWinner: Bool {
                    if let homePenalty = homeTeamPenaltyScore,
                       let awayPenalty = awayTeamPenaltyScore {
                        return awayPenalty > homePenalty
                    }
                    
                    return awayTeamScore > homeTeamScore
                }
                
                if isUEFALeague {
                    if !Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game.gameStatus) {
                        if game.isHomeTopSeed == true {
                            top += homeTeamScore
                            lower += awayTeamScore
                        } else {
                            top += awayTeamScore
                            lower += homeTeamScore
                        }
                    }
                } else {
                    if Constants.GameStatus.isGameFinished(leagueId: leagueId, status: game.gameStatus) {
                        if game.isHomeTopSeed == true {
                            if isHomeWinner {
                                top += 1
                            } else if isAwayWinner {
                                lower += 1
                            }
                        } else {
                            // 홈팀이 lowerSeed인경우
                            if isHomeWinner {
                                lower += 1
                            } else if isAwayWinner {
                                top += 1
                            }
                        }
                    }
                }
                
                return (top, lower)
            }
            
            VStack(spacing: 0) {
                if itemPosition.round > 1  {
                    // 모양: ㄱ
                    HStack {
                        VStack(alignment: .trailing, spacing: 0) {
                            TournamentHBar(width: 80)
                            
                            TournamentVBar(height: verticalMetric(
                                leagueId: leagueId,
                                itemHeights: itemHeights,
                                round: itemPosition.round,
                                series: itemPosition.series,
                                maxRound: maxRound,
                                metric: .topHeight,
                                direction: .left)
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.top, verticalMetric(
                        leagueId: leagueId,
                        itemHeights: itemHeights,
                        round: itemPosition.round,
                        series: itemPosition.series,
                        maxRound: maxRound,
                        metric: .topPadding,
                        direction: .left)
                    )
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    if isUEFALeague {
                        Text("합산 스코어")
                            .frame(height: scoreTitleHeight)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 0) {
                        VStack(spacing: 4) {
                            HStack {
                                HStack {
                                    Text(topSeedTeamId == nil ? "미정" : teamNameDic["short_\(topSeedTeamId ?? 0)"] ?? "")
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    URLImage(
                                        url: Util.teamLogoURL(leagueId: leagueId, teamId: topSeedTeamId),
                                        size: .small
                                    )
                                }
                                .frame(width: 130)
                                
                                Text(isSeriesStarted ? "\(topSeedTeamSeriesScore)" : "-")
                                    .foregroundStyle(isSeriesStarted ? (topSeedTeamSeriesScore >= lowerSeedTeamSeriesScore ? Color.moare : Color.primary) : Color.primary)
                            }
                            .padding(.bottom, 2)
                            
                            if isScoreOpened {
                                Button(action: {
                                    selectSeries?(games)
                                }) {
                                    VStack(spacing: 4) {
                                        ForEach(games.indices, id: \.self) { index in
                                            let game = games[index]
                                            let topSeedScore = game.isHomeTopSeed == true ? game.homeTeamScore : game.awayTeamScore
                                            let lowerSeedScore = game.isHomeTopSeed == true ? game.awayTeamScore : game.homeTeamScore
                                            let isBeforeGame = Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game.gameStatus)
                                            
                                            // only football
                                            let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
                                            let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
                                            let topSeedPenaltyScore = game.isHomeTopSeed == true ? homeTeamPenaltyScore : awayTeamPenaltyScore
                                            let lowerSeedPenaltyScore = game.isHomeTopSeed == true ? awayTeamPenaltyScore : homeTeamPenaltyScore
                                            
                                            // 축구 패널티킥 경기에서 일반 스코어는 검정색
                                            let topSeedScoreColor: Color = (topSeedPenaltyScore != nil && lowerSeedPenaltyScore != nil) ? .primary : (topSeedScore >= lowerSeedScore ? .moare : .primary)
                                            let lowerSeedScoreColor: Color = (topSeedPenaltyScore != nil && lowerSeedPenaltyScore != nil) ? .primary : (lowerSeedScore >= topSeedScore ? .moare : .primary)
                                            
                                            VStack(spacing: 0) {
                                                Text("Game \(index + 1) - \(CalendarUtil.formatDate(date: game.date).split(separator: " ").first ?? "")")
                                                    .font(.system(size: 12, weight: .light))
                                                    .padding(.top, 4)
                                                
                                                HStack(spacing: 0) {
                                                    Text(isBeforeGame ? "-" : "\(topSeedScore)")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .frame(width: 30)
                                                        .foregroundStyle(isBeforeGame ? .primary : topSeedScoreColor)
                                                    
                                                    if let topSeedPenaltyScore, let lowerSeedPenaltyScore {
                                                        Text("\(topSeedPenaltyScore)")
                                                            .font(.system(size: 12))
                                                            .frame(width: 20)
                                                            .foregroundStyle(topSeedPenaltyScore >= lowerSeedPenaltyScore ? .moare : .primary)
                                                    }
                                                    
                                                    Text("-")
                                                    
                                                    if let topSeedPenaltyScore, let lowerSeedPenaltyScore {
                                                        Text("\(lowerSeedPenaltyScore)")
                                                            .font(.system(size: 12))
                                                            .frame(width: 20)
                                                            .foregroundStyle(lowerSeedPenaltyScore >= topSeedPenaltyScore ? .moare : .primary)
                                                    }
                                                    
                                                    Text(isBeforeGame ? "-" : "\(lowerSeedScore)")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .frame(width: 30)
                                                        .foregroundStyle(isBeforeGame ? .primary : lowerSeedScoreColor)
                                                }
                                            }
                                        }
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isScoreOpened.toggle()
                                }
                            }) {
                                HStack(spacing: 3) {
                                    Text("\(isScoreOpened ? "경기결과 숨기기" : "경기결과 보기")")
                                        .font(.system(size: 14))
                                    
                                    Image(systemName: "\(isScoreOpened ? "chevron.up" : "chevron.down")")
                                        .font(.system(size: 14))
                                        .padding(3)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.secondary, lineWidth: 1)
                                        }
                                }
                            }
                            .foregroundStyle(.secondary)
                            .opacity(0.7)
                            
                            HStack {
                                HStack {
                                    Text(lowerSeedTeamId == nil ? "미정" : teamNameDic["short_\(lowerSeedTeamId ?? 0)"] ?? "")
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    URLImage(
                                        url: Util.teamLogoURL(leagueId: leagueId, teamId: lowerSeedTeamId),
                                        size: .small
                                    )
                                }
                                .frame(width: 130)
                                
                                Text(isSeriesStarted ? "\(lowerSeedTeamSeriesScore)" : "-")
                                    .foregroundStyle(isSeriesStarted ? (lowerSeedTeamSeriesScore >= topSeedTeamSeriesScore ? Color.moare : Color.primary) : Color.primary)
                            }
                            .padding(.top, 2)
                        } // VStack
                        .frame(width: 160)
                        .readSize { size in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                itemHeight = size.height
                                itemHeights[itemPosition] = size.height
                            }
                        }
                        
                        // 모양: ]
                        VStack(alignment: .trailing, spacing: 0) {
                            TournamentHBar()
                            
                            TournamentVBar()
                            
                            TournamentHBar()
                        }
                        .padding(.vertical, 15)
                        .frame(height: itemHeight)
                    } // HStack
                }
                
                if itemPosition.round == 2 || itemPosition.round == 3 {
                    // 모양: ⏌
                    HStack {
                        VStack(alignment: .trailing, spacing: 0) {
                            TournamentVBar(height: verticalMetric(
                                leagueId: leagueId,
                                itemHeights: itemHeights,
                                round: itemPosition.round,
                                series: itemPosition.series,
                                maxRound: maxRound,
                                metric: .bottomHeight,
                                direction: .left)
                            )
                            
                            if !shouldRemoveHBar {
                                TournamentHBar(width: 80)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, verticalMetric(
                        leagueId: leagueId,
                        itemHeights: itemHeights,
                        round: itemPosition.round,
                        series: itemPosition.series,
                        maxRound: maxRound,
                        metric: .bottomPadding,
                        direction: .left)
                    )
                }
            }
            .frame(width: 180)
        } else {
            // NOTE: MLB의 경우 첫번째 라운드에 시리즈가 없는 경우가 있어, 해당 경우 비워놔야해서 추가.
            VStack {}
        }
    } // View
}

struct TournamentSeriesRightGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let teamNameDic: [String: String]
    let maxRound: Int
    let games: [GameForSchedule<T>]?
    let itemPosition: RoundSeriesKey // ui상에서 시리즈의 위치 ex) 1라운드의 첫번째 시리즈면 1_1
    
    var shouldRemoveHBar = false // NOTE: MLB의 경우 이전 라운드에 시리즈가 하나 없으면 HBar가 필요없는 경우가 있음.
    
    @Binding var itemHeights: [RoundSeriesKey: CGFloat]
    
    let selectSeries: (([GameForSchedule<T>]) -> Void)?
    
    @State private var itemHeight: CGFloat = 0
    @State private var isScoreOpened = false
    
    var body: some View {
        if let games {
            let game = games.first
            let topSeedTeamId = game?.isHomeTopSeed == true ? game?.homeTeamIdOrNil : game?.awayTeamIdOrNil
            let lowerSeedTeamId = game?.isHomeTopSeed == true ? game?.awayTeamIdOrNil : game?.homeTeamIdOrNil
            let isSeriesStarted = Constants.GameStatus.isGameFinished(leagueId: leagueId, status: game?.gameStatus ?? "")
            
            let (topSeedTeamSeriesScore, lowerSeedTeamSeriesScore) = games.reduce((0, 0)) { partial, game in
                var (top, lower) = partial
                
                let homeTeamScore = game.homeTeamScore
                let awayTeamScore = game.awayTeamScore
                let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
                let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
                
                var isHomeWinner: Bool {
                    if let homePenalty = homeTeamPenaltyScore,
                       let awayPenalty = awayTeamPenaltyScore {
                        return homePenalty > awayPenalty
                    }
                    
                    return homeTeamScore > awayTeamScore
                }
                var isAwayWinner: Bool {
                    if let homePenalty = homeTeamPenaltyScore,
                       let awayPenalty = awayTeamPenaltyScore {
                        return awayPenalty > homePenalty
                    }
                    
                    return awayTeamScore > homeTeamScore
                }
                
                if Constants.GameStatus.isGameFinished(leagueId: leagueId, status: game.gameStatus) {
                    if game.isHomeTopSeed == true {
                        // 홈팀이 topSeed인경우
                        if isHomeWinner {
                            top += 1
                        } else if isAwayWinner {
                            lower += 1
                        }
                    } else {
                        // 홈팀이 lowerSeed인경우
                        if isHomeWinner {
                            lower += 1
                        } else if isAwayWinner {
                            top += 1
                        }
                    }
                }
                
                return (top, lower)
            }
            
            VStack(spacing: 0) {
                if itemPosition.round == 5 || itemPosition.round == 6 {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            TournamentHBar(width: 80)
                            
                            TournamentVBar(height: verticalMetric(
                                leagueId: leagueId,
                                itemHeights: itemHeights,
                                round: itemPosition.round,
                                series: itemPosition.series,
                                maxRound: maxRound,
                                metric: .topHeight,
                                direction: .right)
                            )
                        }
                    }
                    .padding(.top, verticalMetric(
                        leagueId: leagueId,
                        itemHeights: itemHeights,
                        round: itemPosition.round,
                        series: itemPosition.series,
                        maxRound: maxRound,
                        metric: .topPadding,
                        direction: .right)
                    )
                }
                
                HStack(spacing: 0) {
                    // bar
                    VStack(alignment: .leading, spacing: 0) {
                        TournamentHBar()
                        
                        TournamentVBar()
                        
                        TournamentHBar()
                    }
                    .padding(.vertical, 15)
                    .frame(height: itemHeight)
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text(isSeriesStarted ? "\(topSeedTeamSeriesScore)" : "-")
                                .foregroundStyle(isSeriesStarted ? (topSeedTeamSeriesScore >= lowerSeedTeamSeriesScore ? Color.moare : Color.primary) : Color.primary)
                            
                            HStack {
                                Text(topSeedTeamId == nil ? "미정" : teamNameDic["short_\(topSeedTeamId ?? 0)"] ?? "")
                                    .font(.system(size: 15, weight: .medium))
                                
                                URLImage(
                                    url: Util.teamLogoURL(leagueId: leagueId, teamId: topSeedTeamId),
                                    size: .small
                                )
                            }
                            .frame(width: 130)
                        }
                        .padding(.bottom, 2)
                        
                        if isScoreOpened {
                            Button(action: {
                                selectSeries?(games)
                            }) {
                                VStack(spacing: 4) {
                                    ForEach(games.indices, id: \.self) { index in
                                        let game = games[index]
                                        let topSeedScore = game.isHomeTopSeed == true ? game.homeTeamScore : game.awayTeamScore
                                        let lowerSeedScore = game.isHomeTopSeed == true ? game.awayTeamScore : game.homeTeamScore
                                        let isBeforeGame = Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game.gameStatus)
                                        
                                        // only football
                                        let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
                                        let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
                                        let topSeedPenaltyScore = game.isHomeTopSeed == true ? homeTeamPenaltyScore : awayTeamPenaltyScore
                                        let lowerSeedPenaltyScore = game.isHomeTopSeed == true ? awayTeamPenaltyScore : homeTeamPenaltyScore
                                        
                                        // 축구 패널티킥 경기에서 일반 스코어는 검정색
                                        let topSeedScoreColor: Color = (topSeedPenaltyScore != nil && lowerSeedPenaltyScore != nil) ? .primary : (topSeedScore >= lowerSeedScore ? .moare : .primary)
                                        let lowerSeedScoreColor: Color = (topSeedPenaltyScore != nil && lowerSeedPenaltyScore != nil) ? .primary : (lowerSeedScore >= topSeedScore ? .moare : .primary)
                                        
                                        VStack(spacing: 0) {
                                            Text("Game \(index + 1) - \(CalendarUtil.formatDate(date: game.date).split(separator: " ").first ?? "")")
                                                .font(.system(size: 12, weight: .light))
                                                .padding(.top, 4)
                                            
                                            HStack(spacing: 0) {
                                                Text(isBeforeGame ? "-" : "\(topSeedScore)")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .frame(width: 30)
                                                    .foregroundStyle(isBeforeGame ? .primary : topSeedScoreColor)
                                                
                                                if let topSeedPenaltyScore, let lowerSeedPenaltyScore {
                                                    Text("\(topSeedPenaltyScore)")
                                                        .font(.system(size: 12))
                                                        .frame(width: 20)
                                                        .foregroundStyle(topSeedPenaltyScore >= lowerSeedPenaltyScore ? .moare : .primary)
                                                }
                                                
                                                Text("-")
                                                
                                                if let topSeedPenaltyScore, let lowerSeedPenaltyScore {
                                                    Text("\(lowerSeedPenaltyScore)")
                                                        .font(.system(size: 12))
                                                        .frame(width: 20)
                                                        .foregroundStyle(lowerSeedPenaltyScore >= topSeedPenaltyScore ? .moare : .primary)
                                                }
                                                
                                                Text(isBeforeGame ? "-" : "\(lowerSeedScore)")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .frame(width: 30)
                                                    .foregroundStyle(isBeforeGame ? .primary : lowerSeedScoreColor)
                                            }
                                        }
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isScoreOpened.toggle()
                            }
                        }) {
                            HStack(spacing: 3) {
                                Text("\(isScoreOpened ? "경기결과 숨기기" : "경기결과 보기")")
                                    .font(.system(size: 14))
                                
                                Image(systemName: "\(isScoreOpened ? "chevron.up" : "chevron.down")")
                                    .font(.system(size: 14))
                                    .padding(3)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.secondary, lineWidth: 1)
                                    }
                            }
                        }
                        .foregroundStyle(.secondary)
                        .opacity(0.7)
                        
                        HStack {
                            Text(isSeriesStarted ? "\(lowerSeedTeamSeriesScore)" : "-")
                                .foregroundStyle(isSeriesStarted ? (lowerSeedTeamSeriesScore >= topSeedTeamSeriesScore ? Color.moare : Color.primary) : Color.primary)
                            
                            HStack {
                                Text(lowerSeedTeamId == nil ? "미정" : teamNameDic["short_\(lowerSeedTeamId ?? 0)"] ?? "")
                                    .font(.system(size: 15, weight: .medium))
                                
                                URLImage(
                                    url: Util.teamLogoURL(leagueId: leagueId, teamId: lowerSeedTeamId),
                                    size: .small
                                )
                            }
                            .frame(width: 130)
                        }
                        .padding(.top, 2)
                    }
                    .frame(width: 160)
                    .readSize { size in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            itemHeight = size.height
                            itemHeights[itemPosition] = size.height
                        }
                    }
                }
                
                if itemPosition.round == 5 || itemPosition.round == 6 {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            TournamentVBar(height: verticalMetric(
                                leagueId: leagueId,
                                itemHeights: itemHeights,
                                round: itemPosition.round,
                                series: itemPosition.series,
                                maxRound: maxRound,
                                metric: .bottomHeight,
                                direction: .right)
                            )
                            
                            if !shouldRemoveHBar {
                                TournamentHBar(width: 80)
                            }
                        }
                    }
                    .padding(.bottom, verticalMetric(
                        leagueId: leagueId,
                        itemHeights: itemHeights,
                        round: itemPosition.round,
                        series: itemPosition.series,
                        maxRound: maxRound,
                        metric: .bottomPadding,
                        direction: .right)
                    )
                }
            }
            .frame(width: 180)
        } else {
            // NOTE: MLB의 경우 첫번째 라운드에 시리즈가 없는 경우가 있어, 해당 경우 비워놔야해서 추가.
            VStack {}
        }
    } // View
}

struct TournamentSeriesFinalGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let teamNameDic: [String: String]
    let games: [GameForSchedule<T>]
    
    @Binding var itemHeights: [RoundSeriesKey: CGFloat]
    
    let selectSeries: (([GameForSchedule<T>]) -> Void)?
    
    @State private var isScoreOpened = false
    @State private var itemTopPadding: CGFloat = 0 // 아이템 Y 위치
    
    var body: some View {
        let game = games.first
        let topSeedTeamId = game?.isHomeTopSeed == true ? game?.homeTeamIdOrNil : game?.awayTeamIdOrNil
        let lowerSeedTeamId = game?.isHomeTopSeed == true ? game?.awayTeamIdOrNil : game?.homeTeamIdOrNil
        let isSeriesStarted = Constants.GameStatus.isGameFinished(leagueId: leagueId, status: game?.gameStatus ?? "")
        
        let (topSeedTeamSeriesScore, lowerSeedTeamSeriesScore) = games.reduce((0, 0)) { partial, game in
            var (top, lower) = partial
            
            let homeTeamScore = game.homeTeamScore
            let awayTeamScore = game.awayTeamScore
            let homeTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.homeTeamPenaltyScore
            let awayTeamPenaltyScore = (game as? FBGameForSchedule)?.gameInfo?.awayTeamPenaltyScore
            
            var isHomeWinner: Bool {
                if let homePenalty = homeTeamPenaltyScore,
                   let awayPenalty = awayTeamPenaltyScore {
                    return homePenalty > awayPenalty
                }
                
                return homeTeamScore > awayTeamScore
            }
            var isAwayWinner: Bool {
                if let homePenalty = homeTeamPenaltyScore,
                   let awayPenalty = awayTeamPenaltyScore {
                    return awayPenalty > homePenalty
                }
                
                return awayTeamScore > homeTeamScore
            }
            
            if Constants.GameStatus.isGameFinished(leagueId: leagueId, status: game.gameStatus) {
                if game.isHomeTopSeed == true {
                    // 홈팀이 topSeed인경우
                    if isHomeWinner {
                        top += 1
                    } else if isAwayWinner {
                        lower += 1
                    }
                } else {
                    // 홈팀이 lowerSeed인경우
                    if isHomeWinner {
                        lower += 1
                    } else if isAwayWinner {
                        top += 1
                    }
                }
            }
            
            return (top, lower)
        }
        
        VStack(spacing: 4) {
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
                
                Text(isSeriesStarted ? "\(topSeedTeamSeriesScore)" : "-")
                    .foregroundStyle(isSeriesStarted ? (topSeedTeamSeriesScore >= lowerSeedTeamSeriesScore ? Color.moare : Color.primary) : Color.primary)
                
                Text("-")
                
                Text(isSeriesStarted ? "\(lowerSeedTeamSeriesScore)" : "-")
                    .foregroundStyle(isSeriesStarted ? (lowerSeedTeamSeriesScore >= topSeedTeamSeriesScore ? Color.moare : Color.primary) : Color.primary)
                
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
            .padding(.bottom, 2)
            
            if isScoreOpened {
                Button(action: {
                    selectSeries?(games)
                }) {
                    VStack(spacing: 4) {
                        ForEach(games.indices, id: \.self) { index in
                            // NOTE: 축구에서 final이 series인 경우는 아직 없어서 관련 코드가 없음
                            let game = games[index]
                            let topSeedScore = game.homeTeamId == topSeedTeamId ? game.homeTeamScore : game.awayTeamScore
                            let lowerSeedScore = game.homeTeamId == lowerSeedTeamId ? game.homeTeamScore : game.awayTeamScore
                            let isBeforeGame = Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game.gameStatus)
                            
                            VStack(spacing: 0) {
                                Text("Game \(index + 1) - \(CalendarUtil.formatDate(date: game.date).split(separator: " ").first ?? "")")
                                    .font(.system(size: 12, weight: .light))
                                    .padding(.top, 4)
                                
                                HStack(spacing: 0) {
                                    Text(isBeforeGame ? "-" : "\(topSeedScore)")
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(width: 30)
                                        .foregroundStyle(isBeforeGame ? Color.primary : (topSeedScore >= lowerSeedScore ? Color.moare : Color.primary))
                                        
                                    Text("-")
                                    
                                    Text(isBeforeGame ? "-" : "\(lowerSeedScore)")
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(width: 30)
                                        .foregroundStyle(isBeforeGame ? Color.primary : (lowerSeedScore >= topSeedScore ? Color.moare : Color.primary))
                                }
                            }
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isScoreOpened.toggle()
                }
            }) {
                HStack(spacing: 3) {
                    Text("\(isScoreOpened ? "경기결과 숨기기" : "경기결과 보기")")
                        .font(.system(size: 14))
                    
                    Image(systemName: "\(isScoreOpened ? "chevron.up" : "chevron.down")")
                        .font(.system(size: 14))
                        .padding(3)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.secondary, lineWidth: 1)
                        }
                }
            }
            .foregroundStyle(.secondary)
            .opacity(0.7)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.moare, lineWidth: 1)
        }
//        .padding(.top, itemTopPadding)
        .padding(.top, 200)
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

struct TournamentHBar: View {
    var width: CGFloat = 20
    
    var body: some View {
        Rectangle()
            .fill(.secondary)
            .opacity(0.7)
            .frame(width: width, height: 1)
    }
}

struct TournamentVBar: View {
    var height: CGFloat? = nil
    
    var body: some View {
        Rectangle()
            .fill(.secondary)
            .opacity(0.7)
            .frame(width: 1, height: height)
    }
}

enum VerticalMetric {
    case topPadding // ⏋or ⎾ 위 패딩
    case bottomPadding // ⏌ or ⎿ 아래 패딩
    case topHeight // ⏋or ⎾ 에서 | 부분 높이
    case bottomHeight // ⏌ or ⎿ 에서 | 부분 높이
}

enum RoundDirection {
    case left
    case right
}

func verticalMetric(
    leagueId: Int,
    itemHeights: [RoundSeriesKey: CGFloat],
    round: Int,
    series: Int,
    maxRound: Int,
    metric: VerticalMetric,
    direction: RoundDirection
) -> CGFloat {
    let isUEFALeague = Constants.Ids.footballUEFALeagues.contains(leagueId)
    
    func h(_ r: Int, _ s: Int) -> CGFloat {
        itemHeights[RoundSeriesKey(round: r, series: s)] ?? 0
    }
    
    precondition(series >= 1, "series must be >= 1")
    precondition(maxRound >= 2, "maxRound must be >= 2")

    switch direction {
    case .left:
        precondition(round >= 2, "round must be >= 2")
        precondition(round <= maxRound, "round must be <= maxRound")

    case .right:
        precondition(round >= 1, "round must be < maxRound")
        precondition(round < maxRound, "round must be < maxRound")
    }

    let depth: Int
    let halfRound: Int
    let roundsToSum: [Int]

    switch direction {
    case .left:
        depth = round
        halfRound = round - 1
        roundsToSum = round > 2 ? Array(1...(round - 2)) : []

    case .right:
        depth = maxRound - round + 1
        halfRound = round + 1
        roundsToSum = depth > 2
            ? Array(stride(from: maxRound, through: round + 2, by: -1))
            : []
    }

    let quarterIndex: Int
    switch metric {
    case .topPadding:
        quarterIndex = 0
    case .topHeight:
        quarterIndex = 1
    case .bottomHeight:
        quarterIndex = 2
    case .bottomPadding:
        quarterIndex = 3
    }

    var result: CGFloat = 0

    for (index, a) in roundsToSum.enumerated() {
        let count = 1 << (depth - index - 3)
        let blockSize = 1 << (depth - index - 1)
        let blockStart = 1 + (series - 1) * blockSize
        let startB = blockStart + quarterIndex * count

        for offset in 0..<count {
            result += h(a, startB + offset)
        }
    }

    let halfB: Int
    switch metric {
    case .topPadding, .topHeight:
        halfB = 2 * series - 1
    case .bottomPadding, .bottomHeight:
        halfB = 2 * series
    }

    result += h(halfRound, halfB) / 2
    
    if isUEFALeague && direction == .left && metric == .topPadding {
        // add scoreTitleHeight("합산 스코어")
        result += 16
    }

    return result
}
