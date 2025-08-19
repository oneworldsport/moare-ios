//
//  KBOGameStatsView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOGameStatsView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var kboGameStatsStore: StoreOf<KBOGameStatsStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: KBOGameStatsDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 10) {
                if let kboGameStatsStore {
                    let hitterStandings: [StandingsItemState] = kboGameStatsStore.teamHitters.map {
                        StandingsItemState(
                            isGameStats: true,
                            imageUrl: KBOUtil.playerPhotoURL(id: $0.id),
                            name: $0.name,
                            dataList: [
                                $0.ab,
                                $0.h,
                                $0.hr,
                                $0.rbi,
                                $0.r,
                                $0.sb,
                                $0.bb,
                                $0.so
                            ]
                        )
                    }
                    let pitcherStandings: [StandingsItemState] = kboGameStatsStore.teamPitchers.map {
                        StandingsItemState(
                            isGameStats: true,
                            imageUrl: KBOUtil.playerPhotoURL(id: $0.id),
                            name: $0.name,
                            dataList: [
                                $0.ip,
                                $0.r,
                                $0.er,
                                $0.bb,
                                $0.so,
                                $0.h
                            ]
                        )
                    }
                    
                    /* ---------------------
                       game title
                       --------------------- */
                    HStack {
                        BaseballLeagueTitle(
                            logoUrl: KBOUtil.kboLogoUrl,
                            name: "KBO",
                            season: 2025
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    
                    KBOGameStatsScoreInfoItem(
                        kboGameStatsStore: kboGameStatsStore
                    )
                    
                    Capsule()
                        .fill(.moare)
                        .frame(height: 1)
                        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
                    
                    if kboGameStatsStore.baseGameStats.displayModel?.game.gameInfo?.gameStatus != "1" {
                        /* ---------------------
                           team select button
                           --------------------- */
                        KBOGameStatsTeamButtonAdditionalInfoContainer(
                            searchStore: searchStore,
                            kboGameStatsStore: kboGameStatsStore
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
                                secondCategories: StringConstants.KBO.gameStatsHittingCategories,
                                standings: hitterStandings,
                                secondCategorySelectedIndex: kboGameStatsStore.baseGameStats.firstCategorySelectedIndex
                            ),
                            actions: StandingsContainerActions(
                                secondCategoryButtonAction: { index, _ in
                                    kboGameStatsStore.send(.baseGameStats(.selectFirstCategory(index)))
                                },
                                itemButtonAction: { id in
                                    
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
                                secondCategories: StringConstants.KBO.gameStatsPitchingCategories,
                                standings: pitcherStandings,
                                secondCategorySelectedIndex: kboGameStatsStore.baseGameStats.secondCategorySelectedIndex
                            ),
                            actions: StandingsContainerActions(
                                secondCategoryButtonAction: { index, _ in
                                    kboGameStatsStore.send(.baseGameStats(.selectSecondCategory(index)))
                                },
                                itemButtonAction: { id in
                                    
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
                } // if let kboGameStatsStore
            } // VStack
            .onAppear {
                // init KBOGameStatsStore
                let kboGameStatsStore: StoreOf<KBOGameStatsStore> = storeManager.getStore(forKey: StoreKeys.kboGameStatsStore) ?? {
                    let newStore = Store(initialState: KBOGameStatsStore.State()) { KBOGameStatsStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboGameStatsStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.kboGameStatsStore = kboGameStatsStore
                }
                
                if searchStore.poppedView == nil {
                    kboGameStatsStore.send(.baseGameStats(.initData(displayModel: displayModel)))
                }
            } // onAppear
            .onChange(of: displayModel) {
                if case .kboGameStats = searchStore.poppedView {
                    kboGameStatsStore?.send(.baseGameStats(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

struct KBOGameStatsScoreInfoItem: View {
    @Bindable var kboGameStatsStore: StoreOf<KBOGameStatsStore>
    
    var body: some View {
        let displayModel = kboGameStatsStore.baseGameStats.displayModel
        let game = displayModel?.game
        let homeTeamId = game?.gameInfo?.homeTeamId
        let awayTeamId = game?.gameInfo?.awayTeamId
        let teamNameDic = kboGameStatsStore.baseGameStats.teamNameDictionary
        let gameStatus = Int(game?.gameInfo?.gameStatus ?? "0") ?? 0
        
        let gameStatusText: String = {
            switch gameStatus {
            case StringConstants.KBO.gameScheduled:
                return StringConstants.gameNotStartedStr
            case StringConstants.KBO.gameLive:
                return StringConstants.gameLiveStr
            case StringConstants.KBO.gameFinal:
                return StringConstants.gameFinishedStr
            case StringConstants.KBO.gameCanceled:
                return StringConstants.gameCanceledStr
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            if gameStatus == StringConstants.KBO.gameLive {
                return .moare
            } else {
                return .secondary
            }
        }()
        
        HStack {
            VStack {
                URLImage(
                    url: KBOUtil.teamLogoURL(id: homeTeamId),
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
                    url: KBOUtil.teamLogoURL(id: awayTeamId),
                    size: .small,
                    isSvg: true
                )
            } // VStack
            .padding(.top, 26)
            
            KBOGameStatsLineScoreContainer(kboGameStatsStore: kboGameStatsStore)
                .frame(height: 127)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct KBOGameStatsLineScoreContainer: View {
    @Bindable var kboGameStatsStore: StoreOf<KBOGameStatsStore>
    
    var body: some View {
        if let lineScore = kboGameStatsStore.baseGameStats.displayModel?.game.lineScore {
            let homeTeamLineScore = Int(lineScore.home.r) ?? 0
            let awayTeamLineScore = Int(lineScore.away.r) ?? 0
            
            VStack(spacing: 0) {
                HStack {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 26)
                        
//                        if let homeTeamPts = homeTeamLineScore.pts, let awayTeamPts = awayTeamLineScore.pts {
                            Text("\(homeTeamLineScore)")
                                .frame(width: 30, height: kboGameStatsStore.lineScoreItemHeight)
                                .fontWeight(.medium)
                                .padding(.leading, 4)
                                .padding(.trailing, 8)
                                .foregroundStyle(homeTeamLineScore >= awayTeamLineScore ? .moare : .primary)
//                        } else {
//                            Text("-")
//                                .frame(width: 30, height: nbaGameStatsStore.lineScoreItemHeight)
//                                .fontWeight(.medium)
//                                .padding(.leading, 4)
//                                .padding(.trailing, 8)
//                                .foregroundStyle(.primary)
//                        }
                        
                    }
                    
                    VStack(spacing: 0) {
                        KBOGameStatsLineScoreTitle(lineScore: lineScore.away)
                            .frame(height: 25)
                        
                        Capsule()
                            .fill(.secondary)
                            .frame(height: 1)
                            .opacity(0.5)
                        
                        KBOGameStatsLineScoreItem(
                            kboGameStatsStore: kboGameStatsStore,
                            lineScore: lineScore.home
                        )
                        .frame(height: kboGameStatsStore.lineScoreItemHeight)
                    }
                }
                
                Capsule()
                    .fill(.secondary)
                    .frame(height: 1)
                    .opacity(0.5)
                
                HStack {
//                    if let homeTeamPts = homeTeamLineScore.pts, let awayTeamPts = awayTeamLineScore.pts {
                        Text("\(awayTeamLineScore)")
                            .frame(width: 30, height: kboGameStatsStore.lineScoreItemHeight)
                            .fontWeight(.medium)
                            .padding(.leading, 4)
                            .padding(.trailing, 8)
                            .foregroundStyle(awayTeamLineScore >= homeTeamLineScore ? .moare : .primary)
//                    } else {
//                        Text("-")
//                            .frame(width: 30, height: nbaGameStatsStore.lineScoreItemHeight)
//                            .fontWeight(.medium)
//                            .padding(.leading, 4)
//                            .padding(.trailing, 8)
//                            .foregroundStyle(.primary)
//                    }
                    
                    KBOGameStatsLineScoreItem(
                        kboGameStatsStore: kboGameStatsStore,
                        lineScore: lineScore.away
                    )
                    .frame(height: kboGameStatsStore.lineScoreItemHeight)
                }
            }
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
                    Rectangle()
                        .frame(width: 1)
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                    Text(lineScore.innings[index])
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct KBOGameStatsTeamButtonAdditionalInfoContainer: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboGameStatsStore: StoreOf<KBOGameStatsStore>
    
    @State private var barOffset: CGSize = .zero
    
    var body: some View {
        let displayModel = kboGameStatsStore.baseGameStats.displayModel
        let teamNameDic = kboGameStatsStore.baseGameStats.teamNameDictionary
        
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    // home
                    KBOGameStatsTeamButton(
                        kboGameStatsStore: kboGameStatsStore,
                        team: teamNameDic["short_\(displayModel?.game.gameInfo?.homeTeamId ?? 0)"] ?? "",
                        index: 0
                    )
                    .frame(maxWidth: kboGameStatsStore.teamButtonWidth)
                    
                    VCapsuleBar()
                        .opacity(0.5)
                    
                    // away
                    KBOGameStatsTeamButton(
                        kboGameStatsStore: kboGameStatsStore,
                        team: teamNameDic["short_\(displayModel?.game.gameInfo?.awayTeamId ?? 0)"] ?? "",
                        index: 1
                    )
                    .frame(maxWidth: kboGameStatsStore.teamButtonWidth)
                }
                .frame(height: 40)
                
                HCapsuleBar(size: .medium)
                    .offset(barOffset)
            } // VStack
            
            
            HStack(alignment: .top) {
                // refresh button
                if displayModel?.game.gameInfo?.gameStatus == "2" {
                    Button(action: {
                        if let displayModel = kboGameStatsStore.displayModel {
                            searchStore.send(.refreshGame(season: displayModel.season, category: "baseball"))
                        }
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
                    Text("날짜: \(CalendarUtil.formatDate(date: displayModel?.game.gameInfo?.date).split(separator: " ").first ?? "")")
                        .font(.system(size: 12))
                    
                    Text("\(CalendarUtil.formatDate(date: displayModel?.game.gameInfo?.date, formatType: .ampm))")
                        .font(.system(size: 12))
                    
                    Text("장소: \(teamNameDic["venue_\(displayModel?.game.gameInfo?.homeTeamId ?? 0)"] ?? "")")
                        .font(.system(size: 12))
                }
            }
        }
        .onAppear {
            moveBar(index: 0)
        }
        .onChange(of: kboGameStatsStore.baseGameStats.selectedTeamIndex) {
            moveBar(index: kboGameStatsStore.baseGameStats.selectedTeamIndex)
        }
    }
    
    func moveBar(index: Int) {
        withAnimation(.spring(duration: 0.5)) {
            switch index {
            case 0:
                barOffset = CGSize(width:getOffsetOfAniCapsuleBar(itemWidth: kboGameStatsStore.teamButtonWidth, barWidth: 50), height:0)
            default:
                barOffset = CGSize(width: 2 + getOffsetOfAniCapsuleBar(itemWidth: kboGameStatsStore.teamButtonWidth, barWidth: 50, index: index), height: 0)
            }
        }
    }
}

struct KBOGameStatsTeamButton: View {
    @Bindable var kboGameStatsStore: StoreOf<KBOGameStatsStore>
    
    let team: String
    let index: Int
    
    init(kboGameStatsStore: StoreOf<KBOGameStatsStore>, team: String, index: Int) {
        self.kboGameStatsStore = kboGameStatsStore
        self.team = team
        self.index = index
    }
    
    var body: some View {
        Button(action: {
            kboGameStatsStore.send(.baseGameStats(.selectTeam(index)))
        }) {
            Text(team)
                .lineLimit(2)
                .font(.system(size: 16))
        }
        .foregroundStyle(.primary)
    }
}
