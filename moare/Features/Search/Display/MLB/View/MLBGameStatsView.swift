//
//  MLBGameStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBGameStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var mlbGameStatsStore: StoreOf<MLBGameStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: MLBGameStatsDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 10) {
                if let mlbGameStatsStore {
                    let playerNameDic = mlbGameStatsStore.baseGameStats.playerNameDictionary
                    let hitterStandings: [StandingsItemState] = mlbGameStatsStore.teamHitters.map {
                        let playerData = $0.1
                        let playerBatting = playerData.stats?.batting
                        let playerSeasonBatting = playerData.seasonStats?.batting
                        
                        return StandingsItemState(
                            isGameStats: true,
                            imageUrl: MLBUtil.playerPhotoURL(id: Int($0.0.trimmingPrefix("ID"))),
                            name: playerNameDic["\(playerData.person?.id ?? 0)"] ?? (playerData.person?.fullName ?? ""),
                            extraInfo: playerData.position?.abbreviation,
                            dataList: [
                                String(playerBatting?.atBats ?? 0),
                                String(playerBatting?.hits ?? 0),
                                String(playerBatting?.homeRuns ?? 0),
                                String(playerBatting?.rbi ?? 0),
                                String(playerBatting?.runs ?? 0),
                                String(playerBatting?.stolenBases ?? 0),
                                String(playerBatting?.baseOnBalls ?? 0),
                                String(playerBatting?.strikeOuts ?? 0),
                                playerSeasonBatting?.avg ?? "0.0"
                            ]
                        )
                    }
                    let pitcherStandings: [StandingsItemState] = mlbGameStatsStore.teamPitchers.map {
                        let playerData = $0.1
                        let playerPitching = playerData.stats?.pitching
                        let playerSeasonPitching = playerData.seasonStats?.pitching
                        
                        return StandingsItemState(
                            isGameStats: true,
                            imageUrl: MLBUtil.playerPhotoURL(id: Int($0.0.trimmingPrefix("ID"))),
                            name: playerNameDic["\(playerData.person?.id ?? 0)"] ?? (playerData.person?.fullName ?? ""),
                            extraInfo: playerData.position?.abbreviation,
                            dataList: [
                                playerPitching?.inningsPitched ?? "0.0",
                                String(playerPitching?.runs ?? 0),
                                String(playerPitching?.earnedRuns ?? 0),
                                String(playerPitching?.baseOnBalls ?? 0),
                                String(playerPitching?.strikeOuts ?? 0),
                                String(playerPitching?.hits ?? 0),
                                playerSeasonPitching?.era ?? "0.0"
                            ]
                        )
                    }
                    
                    /* ---------------------
                       game title
                       --------------------- */
                    HStack {
                        BaseballLeagueTitle(
                            logoUrl: MLBUtil.mlbLogoUrl,
                            name: "MLB",
                            season: Int(mlbGameStatsStore.baseGameStats.displayModel?.game.game.season ?? "2025") ?? 2025
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    
                    MLBGameStatsScoreInfoItem(
                        mlbGameStatsStore: mlbGameStatsStore
                    )
                    
                    Capsule()
                        .fill(.moare)
                        .frame(height: 1)
                        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    
                    if mlbGameStatsStore.baseGameStats.displayModel?.game.status.statusCode != "S" {
                        /* ---------------------
                           team select button
                           --------------------- */
                        MLBGameStatsTeamButtonAdditionalInfoContainer(
                            searchStore: searchStore,
                            mlbGameStatsStore: mlbGameStatsStore
                        )
                        
                        /* ---------------------
                           player stats
                           --------------------- */
                        // hitter stats
                        HStack {
                            VStack {
                                Text("타자")
                                    .font(.system(size: 15, weight: .medium))
                                
                                HCapsuleBar()
                            }
                            .frame(minWidth: 100)
                            
                            Spacer()
                        }
                        
                        StandingsViewContainer(
                            state: StandingsContainerState(
                                firstCategoryText: StringConstants.gameStatsFirstCategory,
                                secondCategories: StringConstants.MLB.gameStatsHittingCategories,
                                standings: hitterStandings,
                                secondCategorySelectedIndex: mlbGameStatsStore.baseGameStats.firstCategorySelectedIndex
                            ),
                            actions: StandingsContainerActions(
                                secondCategoryButtonAction: { index in
                                    mlbGameStatsStore.send(.baseGameStats(.selectFirstCategory(index)))
                                },
                                itemButtonAction: {
                                    
                                }
                            ),
                            titleContent: {},
                            customListContent: { _ in }
                        )
                        
                        // pitcher stats
                        HStack {
                            VStack {
                                Text("투수")
                                    .font(.system(size: 15, weight: .medium))
                                
                                HCapsuleBar()
                            }
                            .frame(minWidth: 100)
                            
                            Spacer()
                        }
                        
                        StandingsViewContainer(
                            state: StandingsContainerState(
                                firstCategoryText: StringConstants.gameStatsFirstCategory,
                                secondCategories: StringConstants.MLB.gameStatsPitchingCategories,
                                standings: pitcherStandings,
                                secondCategorySelectedIndex: mlbGameStatsStore.baseGameStats.secondCategorySelectedIndex
                            ),
                            actions: StandingsContainerActions(
                                secondCategoryButtonAction: { index in
                                    mlbGameStatsStore.send(.baseGameStats(.selectSecondCategory(index)))
                                },
                                itemButtonAction: {
                                    
                                }
                            ),
                            titleContent: {},
                            customListContent: { _ in }
                        )
                    } else {
                        Text("경기 시작 후 데이터가 업데이트됩니다.")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                } // if let mlbGameStatsStore
            } // VStack
            .onAppear {
                // init MLBGameStatsStore
                let mlbGameStatsStore: StoreOf<MLBGameStatsStore> = storeManager.getStore(forKey: StoreKeys.mlbGameStatsStore) ?? {
                    let newStore = Store(initialState: MLBGameStatsStore.State()) { MLBGameStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.mlbGameStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.mlbGameStatsStore = mlbGameStatsStore
                }
                
                if searchStore.poppedView == nil {
                    mlbGameStatsStore.send(.baseGameStats(.initData(displayModel: displayModel)))
                }
            } // onAppear
            .onChange(of: displayModel) {
                if case .mlbGameStats = searchStore.poppedView {
                    mlbGameStatsStore?.send(.baseGameStats(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

struct MLBGameStatsScoreInfoItem: View {
    @Bindable var mlbGameStatsStore: StoreOf<MLBGameStatsStore>
    
    var body: some View {
        let displayModel = mlbGameStatsStore.baseGameStats.displayModel
        let game = displayModel?.game
        let homeTeamId = game?.teams.home.id
        let awayTeamId = game?.teams.away.id
        let teamNameDic = mlbGameStatsStore.baseGameStats.teamNameDictionary
        let gameStatus = game?.status.detailedState
        
        let gameStatusText: String = {
            switch gameStatus {
            case StringConstants.MLB.gameScheduled:
                return StringConstants.gameNotStartedStr
            case StringConstants.MLB.gameLive:
                return "\(game?.linescore.currentInning ?? 1)회\((game?.linescore.isTopInning ?? true) ? "초" : "말")"
            case StringConstants.MLB.gamePostponed:
                return StringConstants.gamePostponedStr
            case let status? where StringConstants.MLB.gameFinishedList.contains(status):
                return StringConstants.gameFinishedStr
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            if gameStatus == StringConstants.MLB.gameLive {
                return .moare
            } else {
                return .secondary
            }
        }()
        
        HStack {
            VStack {
                URLImage(
                    url: MLBUtil.teamLogoURL(id: homeTeamId),
                    size: .small,
                    isSvg: true
                )
                
                HStack {
                    RoundedBorderText(
                        text: "홈",
                        fontSize: 11,
                        textColor: .moare,
                        radius: 4,
                        strokeColor: .moare
                    )
                    
                    Text(teamNameDic["short_\(homeTeamId ?? 0)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .padding(.leading, 4)
                }
                
                CapsuleButton(
                    text: gameStatusText,
                    color: gameStatusColor
                ) {
                }
                .disabled(true)
                .padding(.vertical, 4)
                
                HStack {
                    RoundedBorderText(
                        text: "원정",
                        fontSize: 11,
                        textColor: .secondary,
                        radius: 4,
                        strokeColor: .secondary
                    )
                    
                    Text(teamNameDic["short_\(awayTeamId ?? 0)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .padding(.leading, 4)
                }
                
                URLImage(
                    url: MLBUtil.teamLogoURL(id: awayTeamId),
                    size: .small,
                    isSvg: true
                )
            } // VStack
            .padding(.top, 26)
            
            MLBGameStatsLineScoreContainer(mlbGameStatsStore: mlbGameStatsStore)
                .frame(height: 127)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct MLBGameStatsLineScoreContainer: View {
    @Bindable var mlbGameStatsStore: StoreOf<MLBGameStatsStore>
    
    var body: some View {
        if let game = mlbGameStatsStore.baseGameStats.displayModel?.game {
            let isGameScheduled = game.status.detailedState == StringConstants.MLB.gameScheduled
            let lineScore = game.linescore
            let homeTeamLineScore = lineScore.teams.home.runs
            let awayTeamLineScore = lineScore.teams.away.runs
            
            VStack(spacing: 0) {
                HStack {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 26)
                        
                        if !isGameScheduled {
                            Text("\(homeTeamLineScore)")
                                .frame(width: 30, height: mlbGameStatsStore.lineScoreItemHeight)
                                .fontWeight(.medium)
                                .padding(.leading, 4)
                                .padding(.trailing, 8)
                                .foregroundStyle(
                                    homeTeamLineScore >= awayTeamLineScore ? .moare : .primary
                                )
                        } else {
                            Text("-")
                                .frame(width: 30, height: mlbGameStatsStore.lineScoreItemHeight)
                                .fontWeight(.medium)
                                .padding(.leading, 4)
                                .padding(.trailing, 8)
                                .foregroundStyle(.primary)
                        }
                        
                    }
                    
                    VStack(spacing: 0) {
                        MLBGameStatsLineScoreTitle(lineScoreInnings: lineScore.innings)
                            .frame(height: 25)
                        
                        Capsule()
                            .fill(.secondary)
                            .frame(height: 1)
                            .opacity(0.5)
                        
                        MLBGameStatsLineScoreItem(
                            mlbGameStatsStore: mlbGameStatsStore,
                            isHome: true,
                            lineScoreInnings: lineScore.innings
                        )
                        .frame(height: mlbGameStatsStore.lineScoreItemHeight)
                    }
                }
                
                Capsule()
                    .fill(.secondary)
                    .frame(height: 1)
                    .opacity(0.5)
                
                HStack {
                    if !isGameScheduled {
                        Text("\(awayTeamLineScore)")
                            .frame(width: 30, height: mlbGameStatsStore.lineScoreItemHeight)
                            .fontWeight(.medium)
                            .padding(.leading, 4)
                            .padding(.trailing, 8)
                            .foregroundStyle(awayTeamLineScore >= homeTeamLineScore ? .moare : .primary)
                    } else {
                        Text("-")
                            .frame(width: 30, height: mlbGameStatsStore.lineScoreItemHeight)
                            .fontWeight(.medium)
                            .padding(.leading, 4)
                            .padding(.trailing, 8)
                            .foregroundStyle(.primary)
                    }
                    
                    MLBGameStatsLineScoreItem(
                        mlbGameStatsStore: mlbGameStatsStore,
                        isHome: false,
                        lineScoreInnings: lineScore.innings
                    )
                    .frame(height: mlbGameStatsStore.lineScoreItemHeight)
                }
            }
        }
        
    }
}

struct MLBGameStatsLineScoreTitle: View {
    let lineScoreInnings: [MLBGameLineScoreInning]
    
    var body: some View {
        let inningsCount = lineScoreInnings.isEmpty ? 9 : lineScoreInnings.count
        
        HStack(spacing: 0) {
            ForEach(1...inningsCount, id: \.self) { index in
//                let data = lineScoreInnings[index]
                
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                Text("\(index)회")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct MLBGameStatsLineScoreItem: View {
    @Bindable var mlbGameStatsStore: StoreOf<MLBGameStatsStore>
    
    let isHome: Bool
    let lineScoreInnings: [MLBGameLineScoreInning]
    
    var body: some View {
        HStack(spacing: 0) {
            if !lineScoreInnings.isEmpty {
                ForEach(lineScoreInnings.indices, id: \.self) { index in
                    let data = lineScoreInnings[index]
                    
                    Rectangle()
                        .frame(width: 1)
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                    Text("\(isHome ? data.home.runs : data.away.runs)")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            } else {
                ForEach(0..<9, id: \.self) { index in
                    Rectangle()
                        .frame(width: 1)
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                    Text("-")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct MLBGameStatsTeamButtonAdditionalInfoContainer: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbGameStatsStore: StoreOf<MLBGameStatsStore>
    
    @State private var barOffset: CGSize = .zero
    
    var body: some View {
        let displayModel = mlbGameStatsStore.baseGameStats.displayModel
        let teamNameDic = mlbGameStatsStore.baseGameStats.teamNameDictionary
        
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    // home
                    MLBGameStatsTeamButton(
                        mlbGameStatsStore: mlbGameStatsStore,
                        team: teamNameDic["short_\(displayModel?.game.teams.home.id ?? 0)"] ?? "",
                        index: 0
                    )
                    .frame(maxWidth: mlbGameStatsStore.teamButtonWidth)
                    
                    VCapsuleBar()
                        .opacity(0.5)
                    
                    // away
                    MLBGameStatsTeamButton(
                        mlbGameStatsStore: mlbGameStatsStore,
                        team: teamNameDic["short_\(displayModel?.game.teams.away.id ?? 0)"] ?? "",
                        index: 1
                    )
                    .frame(maxWidth: mlbGameStatsStore.teamButtonWidth)
                }
                .frame(height: 40)
                
                HCapsuleBar(size: .medium)
                    .offset(barOffset)
            } // VStack
            
            
            HStack(alignment: .top) {
                // refresh button
                if displayModel?.game.status.statusCode == "I" {
                    Button(action: {
                        searchStore.send(.refreshGame(category: "baseball"))
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .tint(.secondary)
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary, lineWidth: 1)
                            }
                            .opacity(0.6)
                    }
                    .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("날짜: \(CalendarUtil.formatDate(date: displayModel?.game.gameInfo.gameDate).split(separator: " ").first ?? "")")
                        .font(.system(size: 12))
                    
                    Text("\(CalendarUtil.formatDate(date: displayModel?.game.gameInfo.gameDate, formatType: .ampm))")
                        .font(.system(size: 12))
                    
                    Text("장소: \(teamNameDic["venue_\(displayModel?.game.teams.home.id ?? 0)"] ?? "")")
                        .font(.system(size: 12))
                    
                    Text("관중수: \(displayModel?.game.gameInfo.attendance ?? 0)")
                        .font(.system(size: 12))
                    
                    Text("심판:")
                        .font(.system(size: 12))
                    
                    if let officials = displayModel?.game.boxscore?.officials {
                        ForEach(officials.indices, id: \.self) { index in
                            let item = officials[index]
//
                            Text("• \(item.official.fullName)")
                                .font(.system(size: 12))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .onAppear {
            moveBar(index: 0)
        }
        .onChange(of: mlbGameStatsStore.baseGameStats.selectedTeamIndex) {
            moveBar(index: mlbGameStatsStore.baseGameStats.selectedTeamIndex)
        }
    }
    
    func moveBar(index: Int) {
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = CGSize(width:getOffsetOfAniCapsuleBar(itemWidth: mlbGameStatsStore.teamButtonWidth, barWidth: 50), height:0)
            default:
                barOffset = CGSize(width: 2 + getOffsetOfAniCapsuleBar(itemWidth: mlbGameStatsStore.teamButtonWidth, barWidth: 50, index: index), height: 0)
            }
        }
    }
}

struct MLBGameStatsTeamButton: View {
    @Bindable var mlbGameStatsStore: StoreOf<MLBGameStatsStore>
    
    let team: String
    let index: Int
    
    init(mlbGameStatsStore: StoreOf<MLBGameStatsStore>, team: String, index: Int) {
        self.mlbGameStatsStore = mlbGameStatsStore
        self.team = team
        self.index = index
    }
    
    var body: some View {
        Button(action: {
            mlbGameStatsStore.send(.baseGameStats(.selectTeam(index)))
        }) {
            Text(team)
                .lineLimit(2)
                .font(.system(size: 16))
        }
        .foregroundStyle(.primary)
    }
}
