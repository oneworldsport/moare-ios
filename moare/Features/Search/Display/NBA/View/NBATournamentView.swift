//
//  NBATournamentView.swift
//  moare
//
//  Created by Mohwa Yoon on 4/21/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATournamentView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTournamentStore: StoreOf<NBATournamentStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATournamentDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack {
                if let nbaTournamentStore {
                    TournamentBracketViewContainer(
                        state: TournamentBracketContainerState(
                            leagueId: displayModel.leagueId,
                            teamNameDic: nbaTournamentStore.baseTournament.teamNameDic,
                            gameListTuple: nbaTournamentStore.gameListTuple,
                            isConference: true,
                            isSeries: true
                        )
                    )
                }
            }
            .onAppear {
                // init NBATournamentStore
                let nbaTournamentStore: StoreOf<NBATournamentStore> = storeManager.getStore(forKey: StoreKeys.nbaTournamentStore) ?? {
                    let newStore = Store(initialState: NBATournamentStore.State()) { NBATournamentStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaTournamentStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaTournamentStore = nbaTournamentStore
                }
                
                if searchStore.poppedView == nil {
                    nbaTournamentStore.send(.baseTournament(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .nbaTournament = searchStore.poppedView {
                    nbaTournamentStore?.send(.baseTournament(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

//struct NBATournamentMainContainer: View {
//    @Bindable var searchStore: StoreOf<SearchStore>
//    @Bindable var nbaTournamentStore: StoreOf<NBATournamentStore>
//    
//    // 130 + 30 + 1 + 30 + 1 = 192
//    // 192 - 65 = 127
//    // 127 * 2 = 254
////    private let infoContainerWidth: CGFloat = 130
////    private let hBarWidth: CGFloat = 30
////    private let barThickness: CGFloat = 1
//    
//    var body: some View {
//        let secondRoundContainerSpace = (nbaTournamentStore.infoContainerWidth + (nbaTournamentStore.hBarWidth * 2) + (nbaTournamentStore.barThickness * 2)) - (nbaTournamentStore.infoContainerWidth / 2)
//        let finalRoundContainerSpace = secondRoundContainerSpace * 2
//        
//        HStack(spacing: 0) {
//            // western conference
//            VStack(alignment: .leading, spacing: 0) {
//                // western 1 round - first game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.westFirstRoundFirstGameList,
//                        firstTeamId: nbaTournamentStore.westFirstRoundFirstGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.westFirstRoundFirstGameSecondTeamId
//                    )
//                }
//                
//                // western 2 round - first game
//                HStack(spacing: 0) {
//                    Spacer()
//                        .frame(width: secondRoundContainerSpace)
//                    
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.westSecondRoundFirstGameList,
//                        firstTeamId: nbaTournamentStore.westSecondRoundFirstGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.westSecondRoundFirstGameSecondTeamId
//                    )
//                }
//                
//                // western 1 round - second game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.westFirstRoundSecondGameList,
//                        firstTeamId: nbaTournamentStore.westFirstRoundSecondGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.westFirstRoundSecondGameSecondTeamId,
//                        isUp: true
//                    )
//                }
//                
//                // western final round
//                HStack(spacing: 0) {
//                    Spacer()
//                        .frame(width: finalRoundContainerSpace)
//                    
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.westFinalRoundGameList,
//                        firstTeamId: nbaTournamentStore.westFinalRoundGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.westFinalRoundGameSecondTeamId,
//                        isUp: true,
//                        isFinal: true
//                    )
//                }
//                
//                // western 1 round - third game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.westFirstRoundThirdGameList,
//                        firstTeamId: nbaTournamentStore.westFirstRoundThirdGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.westFirstRoundThirdGameSecondTeamId
//                    )
//                }
//                
//                // western 2 round - second game
//                HStack(spacing: 0) {
//                    Spacer()
//                        .frame(width: secondRoundContainerSpace)
//                    
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.westSecondRoundSecondGameList,
//                        firstTeamId: nbaTournamentStore.westSecondRoundSecondGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.westSecondRoundSecondGameSecondTeamId,
//                        isUp: true
//                    )
//                }
//                
//                // western 1 round - fourth game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.westFirstRoundFourthGameList,
//                        firstTeamId: nbaTournamentStore.westFirstRoundFourthGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.westFirstRoundFourthGameSecondTeamId,
//                        isUp: true
//                    )
//                }
//            } // VStack
//            
//            // final round
//            NBATournamentFinalContainer(
//                searchStore: searchStore,
//                nbaTournamentStore: nbaTournamentStore,
//                gameList: nbaTournamentStore.finalRoundGameList,
//                firstTeamId: nbaTournamentStore.finalRoundGameFirstTeamId,
//                secondTeamId: nbaTournamentStore.finalRoundGameSecondTeamId,
//            )
//            
//            // eastern conference
//            VStack(alignment: .trailing, spacing: 0) {
//                // eastern 1 round - first game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.eastFirstRoundFirstGameList,
//                        firstTeamId: nbaTournamentStore.eastFirstRoundFirstGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.eastFirstRoundFirstGameSecondTeamId,
//                        isLeft: false
//                    )
//                }
//                
//                // eastern 2 round - first game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.eastSecondRoundFirstGameList,
//                        firstTeamId: nbaTournamentStore.eastSecondRoundFirstGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.eastSecondRoundFirstGameSecondTeamId,
//                        isLeft: false
//                    )
//                    
//                    Spacer()
//                        .frame(width: secondRoundContainerSpace)
//                }
//                
//                // eastern 1 round - second game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.eastFirstRoundSecondGameList,
//                        firstTeamId: nbaTournamentStore.eastFirstRoundSecondGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.eastFirstRoundSecondGameSecondTeamId,
//                        isUp: true,
//                        isLeft: false
//                    )
//                }
//                
//                // eastern final round
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.eastFinalRoundGameList,
//                        firstTeamId: nbaTournamentStore.eastFinalRoundGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.eastFinalRoundGameSecondTeamId,
//                        isUp: true,
//                        isLeft: false,
//                        isFinal: true
//                    )
//                    
//                    Spacer()
//                        .frame(width: finalRoundContainerSpace)
//                }
//                
//                // eastern 1 round - third game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.eastFirstRoundThirdGameList,
//                        firstTeamId: nbaTournamentStore.eastFirstRoundThirdGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.eastFirstRoundThirdGameSecondTeamId,
//                        isLeft: false
//                    )
//                }
//                
//                // eastern 2 round - second game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.eastSecondRoundSecondGameList,
//                        firstTeamId: nbaTournamentStore.eastSecondRoundSecondGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.eastSecondRoundSecondGameSecondTeamId,
//                        isUp: true,
//                        isLeft: false
//                    )
//                    
//                    Spacer()
//                        .frame(width: secondRoundContainerSpace)
//                }
//                
//                // eastern 1 round - fourth game
//                HStack(spacing: 0) {
//                    NBATournamentRoundContainer(
//                        searchStore: searchStore,
//                        nbaTournamentStore: nbaTournamentStore,
//                        gameList: nbaTournamentStore.eastFirstRoundFourthGameList,
//                        firstTeamId: nbaTournamentStore.eastFirstRoundFourthGameFirstTeamId,
//                        secondTeamId: nbaTournamentStore.eastFirstRoundFourthGameSecondTeamId,
//                        isUp: true,
//                        isLeft: false
//                    )
//                }
//            } // VStack
//        } // HStack
//    }
//}
//
//struct NBATournamentRoundContainer: View {
//    @Bindable var searchStore: StoreOf<SearchStore>
//    @Bindable var nbaTournamentStore: StoreOf<NBATournamentStore>
//    
//    let gameList: [NBAGame]?
//    let firstTeamId: Int?
//    let secondTeamId: Int?
//    
//    let isUp: Bool
//    let isLeft: Bool
//    let isFinal: Bool
//    
//    @State private var itemSize: CGSize = .zero
//    @State private var isScoreOpened = false
//    
//    private let recordTextHeight: CGFloat = 30
//    
//    init(
//        searchStore: StoreOf<SearchStore>,
//        nbaTournamentStore: StoreOf<NBATournamentStore>,
//        gameList: [NBAGame]?,
//        firstTeamId: Int?,
//        secondTeamId: Int?,
//        isUp: Bool = false,
//        isLeft: Bool = true,
//        isFinal: Bool = false
//    ) {
//        self.searchStore = searchStore
//        self.nbaTournamentStore = nbaTournamentStore
//        self.gameList = gameList
//        self.firstTeamId = firstTeamId
//        self.secondTeamId = secondTeamId
//        self.isUp = isUp
//        self.isLeft = isLeft
//        self.isFinal = isFinal
//    }
//    
//    var body: some View {
//        let teamNameDic = nbaTournamentStore.teamNameDictionary
//        let seriesGame = gameList?.max(by: {
//            (($0.seasonSeries?.homeTeamWins ?? 0) + ($0.seasonSeries?.homeTeamLosses ?? 0)) < (($1.seasonSeries?.homeTeamWins ?? 0) + ($1.seasonSeries?.homeTeamLosses ?? 0))
//        })
//        let firstTeamRecord: Int? = seriesGame?.seasonSeries?.homeTeamId == firstTeamId ? seriesGame?.seasonSeries?.homeTeamWins : seriesGame?.seasonSeries?.homeTeamLosses
//        let secondTeamRecord: Int? = seriesGame?.seasonSeries?.homeTeamId == secondTeamId ? seriesGame?.seasonSeries?.homeTeamWins : seriesGame?.seasonSeries?.homeTeamLosses
//        
//        HStack(spacing: 0) {
//            if !isLeft {
//                HStack(spacing: 0) {
//                    if !isFinal {
//                        VStack(spacing: 0) {
//                            Rectangle()
//                                .fill(.secondary)
//                                .opacity(isUp ? 0.7 : 0)
//                                .frame(maxWidth: 1, maxHeight: .infinity)
//                            Rectangle()
//                                .fill(.secondary)
//                                .opacity(isUp ? 0 : 0.7)
//                                .frame(maxWidth: 1, maxHeight: .infinity)
//                        }
//                    }
//                    
//                    NBATournamentHBar(width: nbaTournamentStore.hBarWidth)
//                    
//                    Rectangle()
//                        .fill(.secondary)
//                        .opacity(0.7)
//                        .padding(.vertical, recordTextHeight / 2)
//                        .frame(width: 1)
//                    
//                    VStack(spacing: 0) {
//                        HStack {
//                            NBATournamentHBar(width: nbaTournamentStore.hBarWidth)
//                            
//                            if let first = firstTeamRecord, let second = secondTeamRecord {
//                                Text("\(first)")
//                                    .foregroundStyle(first >= second ? .moare : .primary)
//                            } else {
//                                Text("-")
//                                    .foregroundStyle(.primary)
//                            }
//                        }
//                        .frame(height: recordTextHeight)
//                        
//                        Spacer()
//                        
//                        HStack {
//                            NBATournamentHBar(width: nbaTournamentStore.hBarWidth)
//                            
//                            if let first = firstTeamRecord, let second = secondTeamRecord {
//                                Text("\(second)")
//                                    .foregroundStyle(second >= first ? .moare : .primary)
//                            } else {
//                                Text("-")
//                                    .foregroundStyle(.primary)
//                            }
//                        }
//                        .frame(height: recordTextHeight)
//                    }
//                } // HStack
//                .frame(height: itemSize.height)
//            } // if !isLeft
//            
//            Button(action: {
//                if let gameList {
//                    searchStore.send(.selectNBATournamentRound(gameList: gameList))                    
//                }
//            }) {
//                VStack(spacing: 0) {
//                    HStack {
//                        Text(teamNameDic["short_\(firstTeamId ?? 0)"] ?? "-")
//                            .font(.system(size: 15, weight: .medium))
//                        
//                        URLImage(
//                            url: NBAUtil.teamLogoURL(id: firstTeamId),
//                            size: .small,
//                            isSvg: true
//                        )
//                    }
//                    .padding(.bottom, 2)
//                    
//                    if isScoreOpened {
//                        if let gameList {
//                            ForEach(gameList.indices, id: \.self) { index in
//                                let game = gameList[index]
//                                let firstTeamPts = game.lineScore.first { $0.teamId == firstTeamId }?.pts
//                                let secondTeamPts = game.lineScore.first { $0.teamId == secondTeamId }?.pts
//                                
//                                if let gameSummary = game.gameSummary {
//                                    NBATournamentScoreContainer(
//                                        searchStore: searchStore,
//                                        nbaTournamentStore: nbaTournamentStore,
//                                        index: index + 1,
//                                        date: gameSummary.date,
//                                        firstTeamPts: firstTeamPts,
//                                        secondTeamPts: secondTeamPts
//                                    )
//                                }
//                            }
//                        }
//                        
//                        Button(action: {
//                            isScoreOpened.toggle()
//                        }) {
//                            HStack(spacing: 3) {
//                                Text("경기결과 숨기기")
//                                    .font(.system(size: 14))
//                                
//                                Image(systemName: "chevron.up")
//                                    .font(.system(size: 14))
//                                    .padding(3)
//                                    .overlay {
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(.secondary, lineWidth: 1)
//                                    }
//                            }
//                        }
//                        .foregroundStyle(.secondary)
//                        .opacity(0.7)
//                        .padding(.top, 4)
//                    } else {
//                        Button(action: {
//                            isScoreOpened.toggle()
//                        }) {
//                            HStack(spacing: 3) {
//                                Text("경기결과 보기")
//                                    .font(.system(size: 14))
//                                
//                                Image(systemName: "chevron.down")
//                                    .font(.system(size: 14))
//                                    .padding(3)
//                                    .overlay {
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(.secondary, lineWidth: 1)
//                                    }
//                            }
//                        }
//                        .foregroundStyle(.secondary)
//                        .opacity(0.7)
//                        .padding(.top, 4)
//                    }
//                    
//                    HStack {
//                        Text(teamNameDic["short_\(secondTeamId ?? 0)"] ?? "-")
//                            .font(.system(size: 15, weight: .medium))
//                        
//                        URLImage(
//                            url: NBAUtil.teamLogoURL(id: secondTeamId),
//                            size: .small,
//                            isSvg: true
//                        )
//                    }
//                    .padding(.top, 6)
//                } // VStack
//                .frame(width: nbaTournamentStore.infoContainerWidth)
//                .background(
//                    GeometryReader { proxy in
//                        DispatchQueue.main.async {
//                            itemSize = proxy.size
//                        }
//                        return Color.clear
//                    }
//                )
//            } // Button
//            .foregroundStyle(.primary)
//            
//            if isLeft {
//                HStack(spacing: 0) {
//                    VStack(spacing: 0) {
//                        HStack {
//                            if let first = firstTeamRecord, let second = secondTeamRecord {
//                                Text("\(first)")
//                                    .foregroundStyle(first >= second ? .moare : .primary)
//                            } else {
//                                Text("-")
//                                    .foregroundStyle(.primary)
//                            }
//                            
//                            NBATournamentHBar(width: nbaTournamentStore.hBarWidth)
//                        }
//                        .frame(height: recordTextHeight)
//                        
//                        Spacer()
//                        
//                        HStack {
//                            if let first = firstTeamRecord, let second = secondTeamRecord {
//                                Text("\(second)")
//                                    .foregroundStyle(second >= first ? .moare : .primary)
//                            } else {
//                                Text("-")
//                                    .foregroundStyle(.primary)
//                            }
//                            
//                            NBATournamentHBar(width: nbaTournamentStore.hBarWidth)
//                        }
//                        .frame(height: recordTextHeight)
//                    }
//                    
//                    Rectangle()
//                        .fill(.secondary)
//                        .opacity(0.7)
//                        .padding(.vertical, recordTextHeight / 2)
//                        .frame(width: 1)
//                    
//                    NBATournamentHBar(width: nbaTournamentStore.hBarWidth)
//                    
//                    if !isFinal {
//                        VStack(spacing: 0) {
//                            Rectangle()
//                                .fill(.secondary)
//                                .opacity(isUp ? 0.7 : 0)
//                                .frame(maxWidth: 1, maxHeight: .infinity)
//                            Rectangle()
//                                .fill(.secondary)
//                                .opacity(isUp ? 0 : 0.7)
//                                .frame(maxWidth: 1, maxHeight: .infinity)
//                        }
//                    }
//                }
//                .frame(height: itemSize.height)
//            } // if isLeft
//
//        }
//    }
//}
//
//struct NBATournamentScoreContainer: View {
//    @Bindable var searchStore: StoreOf<SearchStore>
//    @Bindable var nbaTournamentStore: StoreOf<NBATournamentStore>
//    
//    let index: Int
//    let date: String
//    let firstTeamPts: Int?
//    let secondTeamPts: Int?
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Game \(index) - \(CalendarUtil.formatDate(date: date).split(separator: " ").first ?? "")")
//                .font(.system(size: 12, weight: .light))
//                .padding(.top, 4)
//            
//            HStack(spacing: 0) {
//                if let first = firstTeamPts, let second = secondTeamPts {
//                    Text("\(first)")
//                        .font(.system(size: 14, weight: .medium))
//                        .frame(width: 30)
//                        .foregroundStyle(first >= second ? .moare : .primary)
//                } else {
//                    Text("-")
//                        .font(.system(size: 14, weight: .medium))
//                        .frame(width: 30)
//                        .foregroundStyle(.primary)
//                }
//                
//                Text("vs")
//                
//                if let first = firstTeamPts, let second = secondTeamPts {
//                    Text("\(second)")
//                        .font(.system(size: 14, weight: .medium))
//                        .frame(width: 30)
//                        .foregroundStyle(second >= first ? .moare : .primary)
//                } else {
//                    Text("-")
//                        .font(.system(size: 14, weight: .medium))
//                        .frame(width: 30)
//                        .foregroundStyle(.primary)
//                }
//            }
//        }
//    }
//}
//
//struct NBATournamentFinalContainer: View {
//    @Bindable var searchStore: StoreOf<SearchStore>
//    @Bindable var nbaTournamentStore: StoreOf<NBATournamentStore>
//    
//    let gameList: [NBAGame]?
//    let firstTeamId: Int?
//    let secondTeamId: Int?
//    
//    @State private var isScoreOpened = false
//    
//    var body: some View {
//        let teamNameDic = nbaTournamentStore.teamNameDictionary
//        let seriesGame = gameList?.max(by: {
//            (($0.seasonSeries?.homeTeamWins ?? 0) + ($0.seasonSeries?.homeTeamLosses ?? 0)) < (($1.seasonSeries?.homeTeamWins ?? 0) + ($1.seasonSeries?.homeTeamLosses ?? 0))
//        })
//        let firstTeamRecord: Int? = seriesGame?.seasonSeries?.homeTeamId == firstTeamId ? seriesGame?.seasonSeries?.homeTeamWins : seriesGame?.seasonSeries?.homeTeamLosses
//        let secondTeamRecord: Int? = seriesGame?.seasonSeries?.homeTeamId == secondTeamId ? seriesGame?.seasonSeries?.homeTeamWins : seriesGame?.seasonSeries?.homeTeamLosses
//        
//        VStack(spacing: 0) {
//            HStack(spacing: 0) {
//                VStack(spacing: 0) {
//                    URLImage(
//                        url: NBAUtil.teamLogoURL(id: firstTeamId),
//                        size: .small,
//                        isSvg: true
//                    )
//                    
//                    Text(teamNameDic["short_\(firstTeamId ?? 0)"] ?? "-")
//                        .font(.system(size: 15, weight: .medium))
//                }
//                .frame(width: 80, alignment: .trailing)
//                    
//                if let first = firstTeamRecord, let second = secondTeamRecord {
//                    Text("\(first)")
//                        .fontWeight(.medium)
//                        .frame(width: 30)
//                        .foregroundStyle(first >= second ? .moare : .primary)
//                } else {
//                    Text("-")
//                        .fontWeight(.medium)
//                        .frame(width: 30)
//                        .foregroundStyle(.primary)
//                }
//                
//                Text("vs")
//                    .frame(width: 30)
//                
//                if let first = firstTeamRecord, let second = secondTeamRecord {
//                    Text("\(second)")
//                        .fontWeight(.medium)
//                        .frame(width: 30)
//                        .foregroundStyle(second >= first ? .moare : .primary)
//                } else {
//                    Text("-")
//                        .fontWeight(.medium)
//                        .frame(width: 30)
//                        .foregroundStyle(.primary)
//                }
//                
//                VStack(spacing: 0) {
//                    URLImage(
//                        url: NBAUtil.teamLogoURL(id: secondTeamId),
//                        size: .small,
//                        isSvg: true
//                    )
//                    
//                    Text(teamNameDic["short_\(secondTeamId ?? 0)"] ?? "-")
//                        .font(.system(size: 15, weight: .medium))
//                }
//                .frame(width: 80, alignment: .leading)
//            } // HStack
//            .padding(.bottom, 2)
//
//            if isScoreOpened {
//                if let gameList {
//                    ForEach(gameList.indices, id: \.self) { index in
//                        let game = gameList[index]
//                        let firstTeamPts = game.lineScore.first { $0.teamId == firstTeamId }?.pts
//                        let secondTeamPts = game.lineScore.first { $0.teamId == secondTeamId }?.pts
//                        
//                        if let gameSummary = game.gameSummary {
//                            NBATournamentFinalScoreContainer(
//                                searchStore: searchStore,
//                                nbaTournamentStore: nbaTournamentStore,
//                                index: index + 1,
//                                date: gameSummary.date,
//                                firstTeamPts: firstTeamPts,
//                                secondTeamPts: secondTeamPts
//                            )
//                        }
//                    }
//                }
////                VStack(spacing: 0) {
////                } // VStack
//                
//                Button(action: {
//                    isScoreOpened.toggle()
//                }) {
//                    HStack(spacing: 3) {
//                        Text("경기결과 숨기기")
//                            .font(.system(size: 14))
//                        
//                        Image(systemName: "chevron.up")
//                            .font(.system(size: 14))
//                            .padding(3)
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(.secondary, lineWidth: 1)
//                            }
//                    }
//                }
//                .foregroundStyle(.secondary)
//                .opacity(0.7)
//                .padding(.top, 4)
//            } else {
//                Button(action: {
//                    isScoreOpened.toggle()
//                }) {
//                    HStack(spacing: 3) {
//                        Text("경기결과 보기")
//                            .font(.system(size: 14))
//                        
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 14))
//                            .padding(3)
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(.secondary, lineWidth: 1)
//                            }
//                    }
//                }
//                .foregroundStyle(.secondary)
//                .opacity(0.7)
//                .padding(.top, 4)
//            }
//        } // VStack
//    }
//}
//
//struct NBATournamentFinalScoreContainer: View {
//    @Bindable var searchStore: StoreOf<SearchStore>
//    @Bindable var nbaTournamentStore: StoreOf<NBATournamentStore>
//    
//    let index: Int
//    let date: String
//    let firstTeamPts: Int?
//    let secondTeamPts: Int?
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Game \(index) - \(CalendarUtil.formatDate(date: date).split(separator: " ").first ?? "")")
//                .font(.system(size: 12, weight: .light))
//                .padding(.top, 4)
//            
//            HStack(spacing: 0) {
//                if let first = firstTeamPts, let second = secondTeamPts {
//                    Text("\(first)")
//                        .font(.system(size: 14, weight: .medium))
//                        .padding(.trailing, 10)
//                        .frame(width: 110, alignment: .trailing)
//                        .foregroundStyle(first >= second ? .moare : .primary)
//                } else {
//                    Text("-")
//                        .font(.system(size: 14, weight: .medium))
//                        .padding(.trailing, 10)
//                        .frame(width: 110, alignment: .trailing)
//                        .foregroundStyle(.primary)
//                }
//                
//                Text("vs")
//                    .frame(width: 30)
//                
//                if let first = firstTeamPts, let second = secondTeamPts {
//                    Text("\(second)")
//                        .font(.system(size: 14, weight: .medium))
//                        .padding(.leading, 10)
//                        .frame(width: 110, alignment: .leading)
//                        .foregroundStyle(second >= first ? .moare : .primary)
//                } else {
//                    Text("-")
//                        .font(.system(size: 14, weight: .medium))
//                        .padding(.leading, 10)
//                        .frame(width: 110, alignment: .leading)
//                        .foregroundStyle(.primary)
//                }
//            }
//        }
//    }
//}
//
//struct NBATournamentHBar: View {
//    
//    let width: CGFloat
//    
//    var body: some View {
//        Rectangle()
//            .fill(.secondary)
//            .opacity(0.7)
//            .frame(width: width, height: 1)
//    }
//}


