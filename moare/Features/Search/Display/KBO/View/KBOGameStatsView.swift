//
//  KBOGameStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOGameStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<KBOGameStatsStore>
    let didPop: Bool
    
    private let firstStatsColumnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 50, 50, 50]
    private let secondStatsColumnWidthList: [CGFloat] = [50, 50, 50, 50, 50, 50]
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseGameStats.displayModel
        let game = displayModel.game
        let teamNameDic = store.baseGameStats.teamNameDictionary
        
        let teamIds = [game.gameInfo?.homeTeamId, game.gameInfo?.awayTeamId]
        let teamCategories: [GameStatsTeamState] = teamIds.map {
            return GameStatsTeamState(
                name: teamNameDic["short_\($0 ?? 0)"] ?? "",
                imageUrl: KBOUtil.teamLogoURL(id: $0)
            )
        }
        
        let hitterList: [StandingsItemState] = store.teamHitters.map {
            StandingsItemState(
                numInfo: $0.battingNumber,
                imageUrl: KBOUtil.playerPhotoURL(id: $0.id),
                name: $0.name,
                extraInfo: $0.position
                    .replacingOccurrences(of: "#", with: "•")
                    .replacingOccurrences(of: "지명타자", with: "지명"),
                dataList: [
                    String($0.ab),
                    String($0.h),
                    String($0.homeRuns),
                    String($0.rbi),
                    String($0.r),
                    String($0.baseOnBalls),
                    String($0.strikeOuts),
                    String($0.groundIntoDoublePlay)
                ]
            )
        }
        let pitcherList: [StandingsItemState] = store.teamPitchers.map {
            StandingsItemState(
                imageUrl: KBOUtil.playerPhotoURL(id: $0.id),
                name: $0.name,
                dataList: [String($0.inningsPitched), $0.r, $0.er, $0.bb, $0.so, $0.h]
            )
        }
        
        let gameDetailTitle = "날짜: \n\n장소: "
        let gameDetailContent: String = {
            var result = ""
            result += "\(CalendarUtil.formatDate(date: game.gameInfo?.date).split(separator: " ").first ?? "")\n"
            result += "\(CalendarUtil.formatDate(date: game.gameInfo?.date, outputFormatType: .ampm))\n"
            result += "\(teamNameDic["venue_\(game.gameInfo?.homeTeamId ?? 0)"] ?? "")\n"
            return result
        }()
        
        VStack {
            if show {
                GameStatsViewContainer(
                    state: GameStatsContainerState(
                        shouldShowStats: (game.gameInfo?.gameStatus.toIntOrNil() == StringConstants.KBO.gameLive) || (game.gameInfo?.gameStatus.toIntOrNil() == StringConstants.KBO.gameFinal),
                        shouldShowRefreshButton: game.gameInfo?.gameStatus.toIntOrNil() == StringConstants.KBO.gameLive,
                        teamCategories: teamCategories,
                        teamCategorySelectedIndex: store.baseGameStats.teamCategorySelectedIndex,
                        firstColumnWidth: 150,
                        gameDetailTitle: gameDetailTitle,
                        gameDetailContent: gameDetailContent,
                        firstStatsTitle: "타자",
                        firstStatsCategories: StringConstants.KBO.gameStatsHittingCategories,
                        firstStatsCategorySelectedIndex: store.baseGameStats.firstCategorySelectedIndex,
                        firstStatsColumnWidthList: firstStatsColumnWidthList,
                        firstStatsPlayerList: hitterList,
                        secondStatsTitle: "투수",
                        secondStatsCategories: StringConstants.KBO.gameStatsPitchingCategories,
                        secondStatsCategorySelectedIndex: store.baseGameStats.secondCategorySelectedIndex,
                        secondStatsColumnWidthList: secondStatsColumnWidthList,
                        secondStatsPlayerList: pitcherList
                    ),
                    actions: GameStatsContainerActions(
                        teamCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectTeam(index: index)))
                        },
                        firstStatsTitleCategoryAction: {
                            store.send(.sortByBattingOrder)
                        },
                        firstStatsCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectFirstCategory(index)))
                        },
                        secondStatsCategoryButtonAction: { index in
                            store.send(.baseGameStats(.selectSecondCategory(index)))
                        },
                        refreshButtonAction: {
                            await store.send(.refreshGame()).finish()
                        }
                    ),
                    titleContent: {
                        VStack(alignment: .leading, spacing: 0) {
                            BaseballLeagueTitleForGameStats(
                                logoUrl: KBOUtil.kboLogoUrl,
                                name: "KBO",
                                season: displayModel.season,
                                seriesDescription: displayModel.game.gameInfo?.seriesDescription ?? ""
                            )
                        }
                    },
                    gameContent: {
//                            if game.gameInfo?.gameStatus.toIntOrNil() == StringConstants.KBO.gameScheduled ||
//                                game.gameInfo?.gameStatus.toIntOrNil() == StringConstants.KBO.gameCanceled {
//
//                            } else {
//                                KBOGameStatsScoreInfoItem(kboGameStatsStore: kboGameStatsStore)
//                            }
                        
                        KBOGameStatsScoreInfoItem(kboGameStatsStore: store)
                    }
                )
            }
        }
        .onAppear {
            if !didPop {
                store.send(.baseGameStats(.initData))
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct KBOGameStatsScoreInfoItem: View {
    @Bindable var kboGameStatsStore: StoreOf<KBOGameStatsStore>
    
    @State private var borderTextWidth: CGFloat = 0
    
    var body: some View {
        let displayModel = kboGameStatsStore.baseGameStats.displayModel
        let game = displayModel.game
        let homeTeamId = Constants.Ids.checkTeamId(leagueId: Constants.Ids.kbo, teamId: game.gameInfo?.homeTeamId)
        let awayTeamId = Constants.Ids.checkTeamId(leagueId: Constants.Ids.kbo, teamId: game.gameInfo?.awayTeamId)
        let teamNameDic = kboGameStatsStore.baseGameStats.teamNameDictionary
        let gameStatus = Int(game.gameInfo?.gameStatus ?? "0") ?? 0
        
        HStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    RoundedBorderText(
                        text: "원정",
                        fontSize: 11,
                        textColor: .secondary,
                        radius: 4,
                        strokeColor: .secondary
                    )
                    .readSize { size in
                        borderTextWidth = size.width
                    }
                    
                    URLImage(
                        url: KBOUtil.teamLogoURL(id: awayTeamId),
                        size: .small
                    )
                    
                    Text(awayTeamId == nil ? "미정" : (teamNameDic["short_\(awayTeamId ?? 0)"] ?? ""))
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                GameStatusCapsuleButton(
                    gameStatusContext: .kbo(status: String(gameStatus)), leagueId: Constants.Ids.kbo
                ){}
                .disabled(true)
                .padding(.vertical, 4)
                
                HStack(spacing: 0) {
                    RoundedBorderText(
                        text: "홈",
                        fontSize: 11,
                        textColor: .moare,
                        radius: 4,
                        strokeColor: .moare
                    )
                    .frame(width: borderTextWidth, alignment: .leading)
                    
                    URLImage(
                        url: KBOUtil.teamLogoURL(id: homeTeamId),
                        size: .small
                    )
                    
                    Text(homeTeamId == nil ? "미정" : (teamNameDic["short_\(homeTeamId ?? 0)"] ?? ""))
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } // VStack
            .frame(width: 110)
            
            KBOGameStatsLineScoreContainer(kboGameStatsStore: kboGameStatsStore)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct KBOGameStatsLineScoreContainer: View {
    @Bindable var kboGameStatsStore: StoreOf<KBOGameStatsStore>
    
    var body: some View {
        if let lineScore = kboGameStatsStore.baseGameStats.displayModel.game.lineScore {
            let homeTeamLineScore = Int(lineScore.home.r) ?? 0
            let awayTeamLineScore = Int(lineScore.away.r) ?? 0
            
            HStack(alignment: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Text("\(awayTeamLineScore)")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(awayTeamLineScore >= homeTeamLineScore ? .moare : .primary)
                    
                    Capsule()
                        .fill(.secondary)
                        .frame(width: 42, height: 1)  // width: 30 + 8 + 4
                        .opacity(0.5)
                    
                    Text("\(homeTeamLineScore)")
                        .frame(width: 30, height: 50)
                        .fontWeight(.medium)
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .foregroundStyle(
                            homeTeamLineScore >= awayTeamLineScore ? .moare : .primary
                        )
                }
                
                VStack(spacing: 0) {
                    KBOGameStatsLineScoreTitle(lineScore: lineScore.away)
                    
                    Capsule()
                        .fill(.secondary)
                        .frame(height: 1)
                        .opacity(0.5)
                    
                    KBOGameStatsLineScoreItem(
                        kboGameStatsStore: kboGameStatsStore,
                        lineScore: lineScore.away
                    )
                    
                    Capsule()
                        .fill(.secondary)
                        .frame(height: 1)
                        .opacity(0.5)
                    
                    KBOGameStatsLineScoreItem(
                        kboGameStatsStore: kboGameStatsStore,
                        lineScore: lineScore.home
                    )
                }
            }
            .frame(height: 127) // 25 + 1 + 50 + 1 + 50
        }
    }
}

struct KBOGameStatsLineScoreTitle: View {
    let lineScore: KBOGameLineScore
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...12, id: \.self) { index in
                if (index < 10) ||
                    (index == 10 && lineScore.inning10 != "-") ||
                    (index == 11 && lineScore.inning11 != "-") {
                    VCapsuleBar()
                        .opacity(0.5)
                    Text("\(index)")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 25)
    }
}

struct KBOGameStatsLineScoreItem: View {
    @Bindable var kboGameStatsStore: StoreOf<KBOGameStatsStore>
    
    let lineScore: KBOGameLineScore
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<11, id: \.self) { index in
                if (index < 9) ||
                    (index == 9 && lineScore.inning10 != "-") ||
                    (index == 10 && lineScore.inning11 != "-") {
                    VCapsuleBar()
                        .opacity(0.5)
                    Text(lineScore.innings[index])
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
}
