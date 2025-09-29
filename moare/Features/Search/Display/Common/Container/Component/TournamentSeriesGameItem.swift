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
    let games: [GameForSchedule<T>]?
    let itemPosition: RoundSeriesKey // ui상에서 시리즈의 위치 ex) 1라운드의 첫번째 시리즈면 1_1
    
    var shouldDrawHBar = true // NOTE: MLB의 경우 이전 라운드에 시리즈가 하나 없으면 HBar가 필요없는 경우가 있음.
    
    @Binding var itemHeights: [RoundSeriesKey: CGFloat]
    
    let selectSeries: (([GameForSchedule<T>]) -> Void)?
    
    @State private var itemHeight: CGFloat = 0
    @State private var isScoreOpened = false
    
    @State private var initialItemHeight: CGFloat = 0 // NOTE: 첫번째 라운드에 시리즈가 없는 경우, 빈 아이템 만큼의 최초 높이가 필요해서 추가함.
    
    var body: some View {
        if let games {
            let topSeedTeamId = games.first != nil ? Constants.Ids.checkTeamId(leagueId: leagueId, id: games.first!.homeTeamId) : nil
            let lowerSeedTeamId = games.first != nil ? Constants.Ids.checkTeamId(leagueId: leagueId, id: games.first!.awayTeamId) : nil
            let isSeriesStarted = topSeedTeamId != nil && lowerSeedTeamId != nil
            
            let (topSeedTeamSeriesScore, lowerSeedTeamSeriesScore) = games.reduce((0, 0)) { partial, game in
                var (top, lower) = partial
                
                if game.homeTeamId == topSeedTeamId {
                    if game.homeTeamScore > game.awayTeamScore {
                        top += 1
                    } else if game.awayTeamScore > game.homeTeamScore {
                        lower += 1
                    }
                } else {
                    if game.homeTeamScore > game.awayTeamScore {
                        lower += 1
                    } else if game.awayTeamScore > game.homeTeamScore {
                        top += 1
                    }
                }
                
                return (top, lower)
            }
            
            VStack(spacing: 0) {
                if itemPosition.round == 2 || itemPosition.round == 3 {
                    HStack {
                        VStack(alignment: .trailing, spacing: 0) {
                            TournamentHBar(width: 75)
                            
                            TournamentVBar(height: topHeight())
                        }
                        
                        Spacer()
                    }
                    .padding(.top, topPadding())
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
                                        let homeTeamScore = game.homeTeamScore
                                        let awayTeamScore = game.awayTeamScore
                                        let isBeforeGame = Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game.gameStatus)
                                        
                                        VStack(spacing: 0) {
                                            Text("Game \(index + 1) - \(CalendarUtil.formatDate(date: game.date).split(separator: " ").first ?? "")")
                                                .font(.system(size: 12, weight: .light))
                                                .padding(.top, 4)
                                            
                                            HStack(spacing: 0) {
                                                Text(isBeforeGame ? "-" : "\(homeTeamScore)")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .frame(width: 30)
                                                    .foregroundStyle(isBeforeGame ? Color.primary : (homeTeamScore >= awayTeamScore ? Color.moare : Color.primary))
                                                    
                                                Text("-")
                                                
                                                Text(isBeforeGame ? "-" : "\(awayTeamScore)")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .frame(width: 30)
                                                    .foregroundStyle(isBeforeGame ? Color.primary : (awayTeamScore >= homeTeamScore ? Color.moare : Color.primary))
                                            }
                                        }
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        
                        Button(action: {
        //                        withAnimation(.easeInOut(duration: 0.3)) {
                                isScoreOpened.toggle()
        //                        }
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
                    }
                    .frame(width: 150)
                    .readSize { size in
                        itemHeight = size.height
                        itemHeights[itemPosition] = size.height
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
                
                if itemPosition.round == 2 || itemPosition.round == 3 {
                    HStack {
                        VStack(alignment: .trailing, spacing: 0) {
                            TournamentVBar(height: bottomHeight())
                            
                            if shouldDrawHBar {
                                TournamentHBar(width: 75)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, bottomPadding())
                }
            }
            .frame(width: 170)
        } else {
            // NOTE: MLB의 경우 첫번째 라운드에 시리즈가 없는 경우가 있어, 해당 경우 비워놔야해서 추가.
            VStack {}
                .frame(height: initialItemHeight)
                .onAppear {
                    initialItemHeight = h(1, 1)
                }
        }
    } // View
    
    private func h(_ r: Int, _ s: Int) -> CGFloat {
        itemHeights[RoundSeriesKey(round: r, series: s)] ?? 0
    }
    
    private func topPadding() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (2, 1): return h(1, 1) / 2
        case (2, 2): return h(1, 3) / 2
        case (3, 1): return (h(2, 1) / 2) + h(1, 1)
        default: return 0
        }
    }
    
    private func topHeight() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (2, 1): return h(1, 1) / 2
        case (2, 2): return h(1, 3) / 2
        case (3, 1): return (h(2, 1) / 2) + h(1, 2)
        default: return 0
        }
    }
    
    private func bottomPadding() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (2, 1): return h(1, 2) / 2
        case (2, 2): return h(1, 4) / 2
        case (3, 1): return (h(2, 2) / 2) + h(1, 4)
        default: return 0
        }
    }
    
    private func bottomHeight() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (2, 1): return h(1, 2) / 2
        case (2, 2): return h(1, 4) / 2
        case (3, 1): return (h(2, 2) / 2) + h(1, 3)
        default: return 0
        }
    }
}

struct TournamentSeriesRightGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let teamNameDic: [String: String]
    let games: [GameForSchedule<T>]?
    let itemPosition: RoundSeriesKey // ui상에서 시리즈의 위치 ex) 1라운드의 첫번째 시리즈면 1_1
    
    var shouldDrawHBar = true // NOTE: MLB의 경우 이전 라운드에 시리즈가 하나 없으면 HBar가 필요없는 경우가 있음.
    
    @Binding var itemHeights: [RoundSeriesKey: CGFloat]
    
    let selectSeries: (([GameForSchedule<T>]) -> Void)?
    
    @State private var itemHeight: CGFloat = 0
    @State private var isScoreOpened = false
    
    @State private var initialItemHeight: CGFloat = 0 // NOTE: 첫번째 라운드에 시리즈가 없는 경우, 빈 아이템 만큼의 최초 높이가 필요해서 추가함.
    
    var body: some View {
        if let games {
            let topSeedTeamId = games.first != nil ? Constants.Ids.checkTeamId(leagueId: leagueId, id: games.first!.homeTeamId) : nil
            let lowerSeedTeamId = games.first != nil ? Constants.Ids.checkTeamId(leagueId: leagueId, id: games.first!.awayTeamId) : nil
            let isSeriesStarted = topSeedTeamId != nil && lowerSeedTeamId != nil
            
            let (topSeedTeamSeriesScore, lowerSeedTeamSeriesScore) = games.reduce((0, 0)) { partial, game in
                var (top, lower) = partial
                
                if game.homeTeamId == topSeedTeamId {
                    if game.homeTeamScore > game.awayTeamScore {
                        top += 1
                    } else if game.awayTeamScore > game.homeTeamScore {
                        lower += 1
                    }
                } else {
                    if game.homeTeamScore > game.awayTeamScore {
                        lower += 1
                    } else if game.awayTeamScore > game.homeTeamScore {
                        top += 1
                    }
                }
                
                return (top, lower)
            }
            
            VStack(spacing: 0) {
                if itemPosition.round == 5 || itemPosition.round == 6 {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            TournamentHBar(width: 75)
                            
                            TournamentVBar(height: topHeight())
                        }
                    }
                    .padding(.top, topPadding())
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
                                        let homeTeamScore = game.homeTeamScore
                                        let awayTeamScore = game.awayTeamScore
                                        let isBeforeGame = Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game.gameStatus)
                                        
                                        VStack(spacing: 0) {
                                            Text("Game \(index + 1) - \(CalendarUtil.formatDate(date: game.date).split(separator: " ").first ?? "")")
                                                .font(.system(size: 12, weight: .light))
                                                .padding(.top, 4)
                                            
                                            HStack(spacing: 0) {
                                                Text(isBeforeGame ? "-" : "\(homeTeamScore)")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .frame(width: 30)
                                                    .foregroundStyle(isBeforeGame ? Color.primary : (homeTeamScore >= awayTeamScore ? Color.moare : Color.primary))
                                                    
                                                Text("-")
                                                
                                                Text(isBeforeGame ? "-" : "\(awayTeamScore)")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .frame(width: 30)
                                                    .foregroundStyle(isBeforeGame ? Color.primary : (awayTeamScore >= homeTeamScore ? Color.moare : Color.primary))
                                            }
                                        }
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        
                        Button(action: {
        //                        withAnimation(.easeInOut(duration: 0.3)) {
                                isScoreOpened.toggle()
        //                        }
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
                    .frame(width: 150)
                    .readSize { size in
                        itemHeight = size.height
                        itemHeights[itemPosition] = size.height
                    }
                }
                
                if itemPosition.round == 5 || itemPosition.round == 6 {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            TournamentVBar(height: bottomHeight())
                            
                            if shouldDrawHBar {
                                TournamentHBar(width: 75)
                            }
                        }
                    }
                    .padding(.bottom, bottomPadding())
                }
            }
            .frame(width: 170)
        } else {
            // NOTE: MLB의 경우 첫번째 라운드에 시리즈가 없는 경우가 있어, 해당 경우 비워놔야해서 추가.
            VStack {}
                .frame(height: initialItemHeight)
                .onAppear {
                    initialItemHeight = h(7, 1)
                }
        }
    } // View
    
    private func h(_ r: Int, _ s: Int) -> CGFloat {
        itemHeights[RoundSeriesKey(round: r, series: s)] ?? 0
    }
    
    private func topPadding() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (6, 1): return h(7, 1) / 2
        case (6, 2): return h(7, 3) / 2
        case (5, 1): return (h(6, 1) / 2) + h(7, 1)
        default: return 0
        }
    }
    
    private func topHeight() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (6, 1): return h(7, 1) / 2
        case (6, 2): return h(7, 3) / 2
        case (5, 1): return (h(6, 1) / 2) + h(7, 2)
        default: return 0
        }
    }
    
    private func bottomPadding() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (6, 1): return h(7, 2) / 2
        case (6, 2): return h(7, 4) / 2
        case (5, 1): return (h(6, 2) / 2) + h(7, 4)
        default: return 0
        }
    }
    
    private func bottomHeight() -> CGFloat {
        switch (itemPosition.round, itemPosition.series) {
        case (6, 1): return h(7, 2) / 2
        case (6, 2): return h(7, 4) / 2
        case (5, 1): return (h(6, 2) / 2) + h(7, 3)
        default: return 0
        }
    }
}

struct TournamentSeriesFinalGameItem<T: Decodable & Equatable>: View {
    let leagueId: Int
    let teamNameDic: [String: String]
    let games: [GameForSchedule<T>]
    
    let selectSeries: (([GameForSchedule<T>]) -> Void)?
    
    @State private var isScoreOpened = false
    
    var body: some View {
        let topSeedTeamId = games.first != nil ? Constants.Ids.checkTeamId(leagueId: leagueId, id: games.first!.homeTeamId) : nil
        let lowerSeedTeamId = games.first != nil ? Constants.Ids.checkTeamId(leagueId: leagueId, id: games.first!.awayTeamId) : nil
        let isSeriesStarted = topSeedTeamId != nil && lowerSeedTeamId != nil
        
        let (topSeedTeamSeriesScore, lowerSeedTeamSeriesScore) = games.reduce((0, 0)) { partial, game in
            var (top, lower) = partial
            
            if game.homeTeamId == topSeedTeamId {
                if game.homeTeamScore > game.awayTeamScore {
                    top += 1
                } else if game.awayTeamScore > game.homeTeamScore {
                    lower += 1
                }
            } else {
                if game.homeTeamScore > game.awayTeamScore {
                    lower += 1
                } else if game.awayTeamScore > game.homeTeamScore {
                    top += 1
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
                            let game = games[index]
                            let homeTeamScore = game.homeTeamScore
                            let awayTeamScore = game.awayTeamScore
                            let isBeforeGame = Constants.GameStatus.isBeforeGame(leagueId: leagueId, status: game.gameStatus)
                            
                            VStack(spacing: 0) {
                                Text("Game \(index + 1) - \(CalendarUtil.formatDate(date: game.date).split(separator: " ").first ?? "")")
                                    .font(.system(size: 12, weight: .light))
                                    .padding(.top, 4)
                                
                                HStack(spacing: 0) {
                                    Text(isBeforeGame ? "-" : "\(homeTeamScore)")
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(width: 30)
                                        .foregroundStyle(isBeforeGame ? Color.primary : (homeTeamScore >= awayTeamScore ? Color.moare : Color.primary))
                                        
                                    Text("-")
                                    
                                    Text(isBeforeGame ? "-" : "\(awayTeamScore)")
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(width: 30)
                                        .foregroundStyle(isBeforeGame ? Color.primary : (awayTeamScore >= homeTeamScore ? Color.moare : Color.primary))
                                }
                            }
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            
            Button(action: {
//                        withAnimation(.easeInOut(duration: 0.3)) {
                    isScoreOpened.toggle()
//                        }
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
        .padding(.top, 280) // 게임 오픈 안했을때 게임 높이가 대략 89로 측정됨
        .padding(.horizontal, 8)
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
