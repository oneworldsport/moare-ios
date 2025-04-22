//
//  NBALeagueTournamentView.swift
//  moare
//
//  Created by Mohwa Yoon on 4/21/25.
//

import SwiftUI
import ComposableArchitecture

struct NBALeagueTournamentView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaLeagueTournamentStore: StoreOf<NBALeagueTournamentStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBALeagueScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            ScrollView(.horizontal) {
                ScrollView(.vertical) {
                    if let nbaLeagueTournamentStore {
                        NBALeagueTournamentMainContainer(
                            searchStore: searchStore,
                            nbaLeagueTournamentStore: nbaLeagueTournamentStore
                        )
                        .padding(.horizontal, 10)
                    } // if let nbaLeagueTournamentStore
                } // ScrollView(.vertical)
            } // ScrollView(.horizontal)
            .onAppear {
                // init NBALeagueTournamentStore
                let nbaLeagueTournamentStore: StoreOf<NBALeagueTournamentStore> = storeManager.getStore(forKey: StoreKeys.nbaLeagueTournamentStore) ?? {
                    let newStore = Store(initialState: NBALeagueTournamentStore.State()) { NBALeagueTournamentStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaLeagueTournamentStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaLeagueTournamentStore = nbaLeagueTournamentStore
                }
                
                if searchStore.poppedView == nil {
                    nbaLeagueTournamentStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .nbaLeagueTournament = searchStore.poppedView {
                    nbaLeagueTournamentStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
}

struct NBALeagueTournamentMainContainer: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueTournamentStore: StoreOf<NBALeagueTournamentStore>
    
    // 130 + 30 + 1 + 30 + 1 = 192
    // 192 - 65 = 127
    // 127 * 2 = 254
    private let infoContainerWidth: CGFloat = 130
    private let hBarWidth: CGFloat = 30
    private let barThickness: CGFloat = 1
    
    var body: some View {
        let secondRoundContainerSpace = (infoContainerWidth + (hBarWidth * 2) + (barThickness * 2)) - (infoContainerWidth / 2)
        let finalRoundContainerSpace = secondRoundContainerSpace * 2
        
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // western 1 round - first game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.westFirstRoundFirstGameList,
                        firstTeamId: nbaLeagueTournamentStore.westFirstRoundFirstGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.westFirstRoundFirstGameSecondTeamId,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth
                    )
                }
                
                // western 2 round - first game
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: secondRoundContainerSpace)
                    
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.westSecondRoundFirstGameList,
                        firstTeamId: nbaLeagueTournamentStore.westSecondRoundFirstGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.westSecondRoundFirstGameSecondTeamId,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth
                    )
                }
                
                // western 1 round - second game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.westFirstRoundSecondGameList,
                        firstTeamId: nbaLeagueTournamentStore.westFirstRoundSecondGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.westFirstRoundSecondGameSecondTeamId,
                        isUp: true,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
                
                // western final round
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: finalRoundContainerSpace)
                    
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.westFinalRoundGameList,
                        firstTeamId: nbaLeagueTournamentStore.westFinalRoundGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.westFinalRoundGameSecondTeamId,
                        isUp: true,
                        isFinal: true,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
                
                // western 1 round - third game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.westFirstRoundThirdGameList,
                        firstTeamId: nbaLeagueTournamentStore.westFirstRoundThirdGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.westFirstRoundThirdGameSecondTeamId,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
                
                // western 2 round - second game
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: secondRoundContainerSpace)
                    
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.westSecondRoundSecondGameList,
                        firstTeamId: nbaLeagueTournamentStore.westSecondRoundSecondGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.westSecondRoundSecondGameSecondTeamId,
                        isUp: true,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
                
                // western 1 round - fourth game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.westFirstRoundFourthGameList,
                        firstTeamId: nbaLeagueTournamentStore.westFirstRoundFourthGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.westFirstRoundFourthGameSecondTeamId,
                        isUp: true,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
            } // VStack
            
            // final round
            NBALeagueTournamentFinalContainer(
                searchStore: searchStore,
                nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                gameList: nbaLeagueTournamentStore.finalRoundGameList,
                firstTeamId: nbaLeagueTournamentStore.finalRoundGameFirstTeamId,
                secondTeamId: nbaLeagueTournamentStore.finalRoundGameFirstTeamId,
            )
            
            VStack(alignment: .trailing, spacing: 0) {
                // eastern 1 round - first game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.eastFirstRoundFirstGameList,
                        firstTeamId: nbaLeagueTournamentStore.eastFirstRoundFirstGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.eastFirstRoundFirstGameSecondTeamId,
                        isLeft: false,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
                
                // eastern 2 round - first game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.eastSecondRoundFirstGameList,
                        firstTeamId: nbaLeagueTournamentStore.eastSecondRoundFirstGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.eastSecondRoundFirstGameSecondTeamId,
                        isLeft: false,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                    
                    Spacer()
                        .frame(width: secondRoundContainerSpace)
                }
                
                // eastern 1 round - second game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.eastFirstRoundSecondGameList,
                        firstTeamId: nbaLeagueTournamentStore.eastFirstRoundSecondGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.eastFirstRoundSecondGameSecondTeamId,
                        isUp: true,
                        isLeft: false,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
                
                // eastern final round
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.eastFinalRoundGameList,
                        firstTeamId: nbaLeagueTournamentStore.eastFinalRoundGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.eastFinalRoundGameSecondTeamId,
                        isUp: true,
                        isLeft: false,
                        isFinal: true,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                    
                    Spacer()
                        .frame(width: finalRoundContainerSpace)
                }
                
                // eastern 1 round - third game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.eastFirstRoundThirdGameList,
                        firstTeamId: nbaLeagueTournamentStore.eastFirstRoundThirdGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.eastFirstRoundThirdGameSecondTeamId,
                        isLeft: false,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
                
                // eastern 2 round - second game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.eastSecondRoundSecondGameList,
                        firstTeamId: nbaLeagueTournamentStore.eastSecondRoundSecondGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.eastSecondRoundSecondGameSecondTeamId,
                        isUp: true,
                        isLeft: false,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                    
                    Spacer()
                        .frame(width: secondRoundContainerSpace)
                }
                
                // eastern 1 round - fourth game
                HStack(spacing: 0) {
                    NBALeagueTournamentRoundContainer(
                        searchStore: searchStore,
                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                        gameList: nbaLeagueTournamentStore.eastFirstRoundFourthGameList,
                        firstTeamId: nbaLeagueTournamentStore.eastFirstRoundFourthGameFirstTeamId,
                        secondTeamId: nbaLeagueTournamentStore.eastFirstRoundFourthGameSecondTeamId,
                        isUp: true,
                        isLeft: false,
                        infoContainerWidth: infoContainerWidth,
                        hBarWidth: hBarWidth,
                    )
                }
            } // VStack
        } // HStack
    }
}

struct NBALeagueTournamentRoundContainer: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueTournamentStore: StoreOf<NBALeagueTournamentStore>
    
    let gameList: [NBAGame]?
    let firstTeamId: Int?
    let secondTeamId: Int?
    
    let isUp: Bool
    let isLeft: Bool
    let isFinal: Bool
    let infoContainerWidth: CGFloat
    let hBarWidth: CGFloat
    
    @State private var itemSize: CGSize = .zero
    @State private var isScoreOpened = false
    
    private let recordTextHeight: CGFloat = 30
    
    init(
        searchStore: StoreOf<SearchStore>,
        nbaLeagueTournamentStore: StoreOf<NBALeagueTournamentStore>,
        gameList: [NBAGame]?,
        firstTeamId: Int?,
        secondTeamId: Int?,
        isUp: Bool = false,
        isLeft: Bool = true,
        isFinal: Bool = false,
        infoContainerWidth: CGFloat,
        hBarWidth: CGFloat,
    ) {
        self.searchStore = searchStore
        self.nbaLeagueTournamentStore = nbaLeagueTournamentStore
        self.gameList = gameList
        self.firstTeamId = firstTeamId
        self.secondTeamId = secondTeamId
        self.isUp = isUp
        self.isLeft = isLeft
        self.isFinal = isFinal
        self.infoContainerWidth = infoContainerWidth
        self.hBarWidth = hBarWidth
    }
    
    var body: some View {
        let teamNameDic = nbaLeagueTournamentStore.teamNameDictionary
        let seriesGame = gameList?.max(by: {
            (($0.seasonSeries?.homeTeamWins ?? 0) + ($0.seasonSeries?.homeTeamLosses ?? 0)) < (($1.seasonSeries?.homeTeamWins ?? 0) + ($1.seasonSeries?.homeTeamLosses ?? 0))
        })
        let firstTeamRecord: Int? = seriesGame?.seasonSeries?.homeTeamId == firstTeamId ? seriesGame?.seasonSeries?.homeTeamWins : seriesGame?.seasonSeries?.homeTeamLosses
        let secondTeamRecord: Int? = seriesGame?.seasonSeries?.homeTeamId == secondTeamId ? seriesGame?.seasonSeries?.homeTeamWins : seriesGame?.seasonSeries?.homeTeamLosses
        
        HStack(spacing: 0) {
            if !isLeft {
                HStack(spacing: 0) {
                    if !isFinal {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(.secondary)
                                .opacity(isUp ? 0.7 : 0)
                                .frame(maxWidth: 1, maxHeight: .infinity)
                            Rectangle()
                                .fill(.secondary)
                                .opacity(isUp ? 0 : 0.7)
                                .frame(maxWidth: 1, maxHeight: .infinity)
                        }
                    }
                    
                    NBALeagueTournamentHBar(width: hBarWidth)
                    
                    Rectangle()
                        .fill(.secondary)
                        .opacity(0.7)
                        .padding(.vertical, recordTextHeight / 2)
                        .frame(width: 1)
                    
                    VStack(spacing: 0) {
                        HStack {
                            NBALeagueTournamentHBar(width: hBarWidth)
                            
                            if let first = firstTeamRecord, let second = secondTeamRecord {
                                Text("\(first)")
                                    .foregroundStyle(first >= second ? .moare : .primary)
                            } else {
                                Text("-")
                                    .foregroundStyle(.primary)
                            }
                        }
                        .frame(height: recordTextHeight)
                        
                        Spacer()
                        
                        HStack {
                            NBALeagueTournamentHBar(width: hBarWidth)
                            
                            if let first = firstTeamRecord, let second = secondTeamRecord {
                                Text("\(second)")
                                    .foregroundStyle(second >= first ? .moare : .primary)
                            } else {
                                Text("-")
                                    .foregroundStyle(.primary)
                            }
                        }
                        .frame(height: recordTextHeight)
                    }
                } // HStack
                .frame(height: itemSize.height)
            } // if !isLeft
            
            Button(action: {
                if let gameList {
                    searchStore.send(.selectNBATournamentRound(gameList: gameList))                    
                }
            }) {
                VStack(spacing: 0) {
                    HStack {
                        Text(teamNameDic["short_\(firstTeamId ?? 0)"] ?? "-")
                            .font(.system(size: 15, weight: .medium))
                        
                        URLImage(
                            url: NBAUtil.teamLogoURL(id: firstTeamId),
                            size: .small,
                            isSvg: true
                        )
                    }
                    .padding(.bottom, 2)
                    
                    if isScoreOpened {
                        if let gameList {
                            ForEach(gameList.indices, id: \.self) { index in
                                let game = gameList[index]
                                let firstTeamPts = game.lineScore.first { $0.teamId == firstTeamId }?.pts
                                let secondTeamPts = game.lineScore.first { $0.teamId == secondTeamId }?.pts
                                
                                if let gameSummary = game.gameSummary {
                                    NBALeagueTournamentScoreContainer(
                                        searchStore: searchStore,
                                        nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                                        index: index + 1,
                                        date: gameSummary.date,
                                        firstTeamPts: firstTeamPts,
                                        secondTeamPts: secondTeamPts
                                    )
                                }
                            }
                        }
                        
                        Button(action: {
                            isScoreOpened.toggle()
                        }) {
                            HStack(spacing: 3) {
                                Text("경기결과 숨기기")
                                    .font(.system(size: 14))
                                
                                Image(systemName: "chevron.up")
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
                        .padding(.top, 4)
                    } else {
                        Button(action: {
                            isScoreOpened.toggle()
                        }) {
                            HStack(spacing: 3) {
                                Text("경기결과 보기")
                                    .font(.system(size: 14))
                                
                                Image(systemName: "chevron.down")
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
                        .padding(.top, 4)
                    }
                    
                    HStack {
                        Text(teamNameDic["short_\(secondTeamId ?? 0)"] ?? "-")
                            .font(.system(size: 15, weight: .medium))
                        
                        URLImage(
                            url: NBAUtil.teamLogoURL(id: secondTeamId),
                            size: .small,
                            isSvg: true
                        )
                    }
                    .padding(.top, 6)
                } // VStack
                .frame(width: infoContainerWidth)
                .background(
                    GeometryReader { proxy in
                        DispatchQueue.main.async {
                            itemSize = proxy.size
                        }
                        return Color.clear
                    }
                )
            } // Button
            .foregroundStyle(.primary)
            
            if isLeft {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            if let first = firstTeamRecord, let second = secondTeamRecord {
                                Text("\(first)")
                                    .foregroundStyle(first >= second ? .moare : .primary)
                            } else {
                                Text("-")
                                    .foregroundStyle(.primary)
                            }
                            
                            NBALeagueTournamentHBar(width: hBarWidth)
                        }
                        .frame(height: recordTextHeight)
                        
                        Spacer()
                        
                        HStack {
                            if let first = firstTeamRecord, let second = secondTeamRecord {
                                Text("\(second)")
                                    .foregroundStyle(second >= first ? .moare : .primary)
                            } else {
                                Text("-")
                                    .foregroundStyle(.primary)
                            }
                            
                            NBALeagueTournamentHBar(width: hBarWidth)
                        }
                        .frame(height: recordTextHeight)
                    }
                    
                    Rectangle()
                        .fill(.secondary)
                        .opacity(0.7)
                        .padding(.vertical, recordTextHeight / 2)
                        .frame(width: 1)
                    
                    NBALeagueTournamentHBar(width: hBarWidth)
                    
                    if !isFinal {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(.secondary)
                                .opacity(isUp ? 0.7 : 0)
                                .frame(maxWidth: 1, maxHeight: .infinity)
                            Rectangle()
                                .fill(.secondary)
                                .opacity(isUp ? 0 : 0.7)
                                .frame(maxWidth: 1, maxHeight: .infinity)
                        }
                    }
                }
                .frame(height: itemSize.height)
            } // if isLeft

        }
    }
}

struct NBALeagueTournamentScoreContainer: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueTournamentStore: StoreOf<NBALeagueTournamentStore>
    
    let index: Int
    let date: String
    let firstTeamPts: Int?
    let secondTeamPts: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Game \(index) - \(CalendarUtil.formatDate(date: date).split(separator: " ").first ?? "")")
                .font(.system(size: 12, weight: .light))
                .padding(.top, 4)
            
            HStack(spacing: 0) {
                if let first = firstTeamPts, let second = secondTeamPts {
                    Text("\(first)")
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 30)
                        .foregroundStyle(first >= second ? .moare : .primary)
                } else {
                    Text("-")
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 30)
                        .foregroundStyle(.primary)
                }
                
                Text("vs")
                
                if let first = firstTeamPts, let second = secondTeamPts {
                    Text("\(second)")
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 30)
                        .foregroundStyle(second >= first ? .moare : .primary)
                } else {
                    Text("-")
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 30)
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

struct NBALeagueTournamentFinalContainer: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueTournamentStore: StoreOf<NBALeagueTournamentStore>
    
    let gameList: [NBAGame]?
    let firstTeamId: Int?
    let secondTeamId: Int?
    
    @State private var isScoreOpened = false
    
    var body: some View {
        let teamNameDic = nbaLeagueTournamentStore.teamNameDictionary
//        let teamId = getOrderedTeamIds(homeTeamId: gameList?.first?.gameSummary?.homeTeamId, awayTeamId: gameList?.first?.gameSummary?.visitorTeamId)
        let seriesGame = gameList?.max(by: {
            (($0.seasonSeries?.homeTeamWins ?? 0) + ($0.seasonSeries?.homeTeamLosses ?? 0)) < (($1.seasonSeries?.homeTeamWins ?? 0) + ($1.seasonSeries?.homeTeamLosses ?? 0))
        })
        let firstTeamRecord: Int? = seriesGame?.seasonSeries?.homeTeamId == firstTeamId ? seriesGame?.seasonSeries?.homeTeamWins : seriesGame?.seasonSeries?.homeTeamLosses
        let secondTeamRecord: Int? = seriesGame?.seasonSeries?.homeTeamId == secondTeamId ? seriesGame?.seasonSeries?.homeTeamWins : seriesGame?.seasonSeries?.homeTeamLosses
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    URLImage(
                        url: NBAUtil.teamLogoURL(id: firstTeamId),
                        size: .small,
                        isSvg: true
                    )
                    
                    Text(teamNameDic["short_\(firstTeamId ?? 0)"] ?? "-")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(width: 80, alignment: .trailing)
                    
                if let first = firstTeamRecord, let second = secondTeamRecord {
                    Text("\(first)")
                        .fontWeight(.medium)
                        .frame(width: 30)
                        .foregroundStyle(first >= second ? .moare : .primary)
                } else {
                    Text("-")
                        .fontWeight(.medium)
                        .frame(width: 30)
                        .foregroundStyle(.primary)
                }
                
                Text("vs")
                    .frame(width: 30)
                
                if let first = firstTeamRecord, let second = secondTeamRecord {
                    Text("\(second)")
                        .fontWeight(.medium)
                        .frame(width: 30)
                        .foregroundStyle(second >= first ? .moare : .primary)
                } else {
                    Text("-")
                        .fontWeight(.medium)
                        .frame(width: 30)
                        .foregroundStyle(.primary)
                }
                
                VStack(spacing: 0) {
                    URLImage(
                        url: NBAUtil.teamLogoURL(id: secondTeamId),
                        size: .small,
                        isSvg: true
                    )
                    
                    Text(teamNameDic["short_\(secondTeamId ?? 0)"] ?? "-")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(width: 80, alignment: .leading)
            } // HStack
            .padding(.bottom, 2)

            if isScoreOpened {
                VStack(spacing: 0) {
                    if let gameList {
                        ForEach(gameList.indices, id: \.self) { index in
                            let game = gameList[index]
                            let firstTeamPts = game.lineScore.first { $0.teamId == firstTeamId }?.pts
                            let secondTeamPts = game.lineScore.first { $0.teamId == secondTeamId }?.pts
                            
                            if let gameSummary = game.gameSummary {
                                NBALeagueTournamentFinalScoreContainer(
                                    searchStore: searchStore,
                                    nbaLeagueTournamentStore: nbaLeagueTournamentStore,
                                    index: index + 1,
                                    date: gameSummary.date,
                                    firstTeamPts: firstTeamPts,
                                    secondTeamPts: secondTeamPts
                                )
                            }
                        }
                    }
                } // VStack
                
                Button(action: {
                    isScoreOpened.toggle()
                }) {
                    HStack(spacing: 3) {
                        Text("경기결과 숨기기")
                            .font(.system(size: 14))
                        
                        Image(systemName: "chevron.up")
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
                .padding(.top, 4)
            } else {
                Button(action: {
                    isScoreOpened.toggle()
                }) {
                    HStack(spacing: 3) {
                        Text("경기결과 보기")
                            .font(.system(size: 14))
                        
                        Image(systemName: "chevron.down")
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
                .padding(.top, 4)
            }
        } // VStack
    }
    
//    func getOrderedTeamIds(homeTeamId: Int?, awayTeamId: Int?) -> (firstTeamId: Int?, secondTeamId: Int?) {
//        if let homeTeamId, let awayTeamId {
//            let homePriority = nbaLeagueTournamentStore.priorityList.firstIndex(of: homeTeamId) ?? Int.max
//            let awayPriority = nbaLeagueTournamentStore.priorityList.firstIndex(of: awayTeamId) ?? Int.max
//
//            if homePriority <= awayPriority {
//                return (firstTeamId: homeTeamId, secondTeamId: awayTeamId)
//            } else {
//                return (firstTeamId: awayTeamId, secondTeamId: homeTeamId)
//            }
//        } else {
//            return (firstTeamId: nil, secondTeamId: nil)
//        }
//    }
}

struct NBALeagueTournamentFinalScoreContainer: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueTournamentStore: StoreOf<NBALeagueTournamentStore>
    
    let index: Int
    let date: String
    let firstTeamPts: Int?
    let secondTeamPts: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Game \(index) - \(CalendarUtil.formatDate(date: date).split(separator: " ").first ?? "")")
                .font(.system(size: 12, weight: .light))
                .padding(.top, 4)
            
            HStack(spacing: 0) {
                if let first = firstTeamPts, let second = secondTeamPts {
                    Text("\(first)")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.trailing, 10)
                        .frame(width: 110, alignment: .trailing)
                        .foregroundStyle(first >= second ? .moare : .primary)
                } else {
                    Text("-")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.trailing, 10)
                        .frame(width: 110, alignment: .trailing)
                        .foregroundStyle(.primary)
                }
                
                Text("vs")
                    .frame(width: 30)
                
                if let first = firstTeamPts, let second = secondTeamPts {
                    Text("\(second)")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.leading, 10)
                        .frame(width: 110, alignment: .leading)
                        .foregroundStyle(second >= first ? .moare : .primary)
                } else {
                    Text("-")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.leading, 10)
                        .frame(width: 110, alignment: .leading)
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

struct NBALeagueTournamentHBar: View {
    
    let width: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(.secondary)
            .opacity(0.7)
            .frame(width: width, height: 1)
    }
}


