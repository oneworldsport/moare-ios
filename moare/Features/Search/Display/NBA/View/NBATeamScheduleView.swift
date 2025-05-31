//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBATeamScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaTeamScheduleStore: StoreOf<NBATeamScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBATeamScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let nbaTeamScheduleStore {
                    if searchStore.nbaGameStatsData == nil {
                        /* ---------------------
                           all result open button
                           - hides when game selected
                           --------------------- */
                        HStack {
                            Spacer()
                            
                            CapsuleButton(
                                text: nbaTeamScheduleStore.isAllResultOpened ? StringConstants.resultHide : StringConstants.resultOpen,
                                color: .secondary
                            ) {
                                nbaTeamScheduleStore.send(.toggleAllResult)
                            }
                            .padding(.trailing)
                        }
                        
                        /* ---------------------
                           schedule
                           --------------------- */
                        NBATeamScheduleList(
                            searchStore: searchStore,
                            nbaTeamScheduleStore: nbaTeamScheduleStore
                        )
                    }
                } // if let nbaTeamScheduleStore
            } // VStack
            .onAppear {
                // init NBATeamScheduleStore
                let nbaTeamScheduleStore: StoreOf<NBATeamScheduleStore> = storeManager.getStore(forKey: StoreKeys.nbaTeamScheduleStore) ?? {
                    let newStore = Store(initialState: NBATeamScheduleStore.State()) { NBATeamScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaTeamScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaTeamScheduleStore = nbaTeamScheduleStore
                }
                
                if searchStore.poppedView == nil {
                    nbaTeamScheduleStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .nbaTeamSchedule = searchStore.poppedView {
                    nbaTeamScheduleStore?.send(.initData(displayModel: displayModel))
                }
            }
        } // if let searchStore
    }
}

struct NBATeamScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaTeamScheduleStore: StoreOf<NBATeamScheduleStore>
    
    @State var gameListToDisplay: [NBAGameForSchedule] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay.indices, id: \.self) { index in
                    NBATeamScheduleListItem(
                        searchStore: searchStore,
                        nbaTeamScheduleStore: nbaTeamScheduleStore,
                        data: gameListToDisplay[index]
                    )
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            gameListToDisplay = nbaTeamScheduleStore.games
        }
    }
}

struct NBATeamScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaTeamScheduleStore: StoreOf<NBATeamScheduleStore>
    
    let data: NBAGameForSchedule
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let homeTeamScore = data.homeTeamScore
        let awayTeamScore = data.awayTeamScore
        let gameStatus = Int(data.gameStatus)
        let teamNameDic = nbaTeamScheduleStore.teamNameDictionary
        
        let gameStatusText: String = {
            guard isResultOpened else { return StringConstants.resultOpen }

            switch gameStatus {
            case 1:
                return StringConstants.gameNotStartedStr
            case 2:
                return "경기중"
//                guard let first = data.lineScore.first else { return "" }
//                if first.ptsOt3 != nil {
//                    return StringConstants.NBA.gameOt3
//                } else if first.ptsOt2 != nil {
//                    return StringConstants.NBA.gameOt2
//                } else if first.ptsOt1 != nil {
//                    return StringConstants.NBA.gameOt1
//                } else if first.ptsQtr4 != nil {
//                    return StringConstants.NBA.gameQtr4
//                } else if first.ptsQtr3 != nil {
//                    return StringConstants.NBA.gameQtr3
//                } else if first.ptsQtr2 != nil {
//                    return StringConstants.NBA.gameQtr2
//                } else if first.ptsQtr1 != nil {
//                    return StringConstants.NBA.gameQtr1
//                } else {
//                    return ""
//                }
            case 3:
                return StringConstants.gameFinishedStr
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            guard isResultOpened else { return .secondary }
            
            if gameStatus == 2 {
                return .moare
            } else {
                return .secondary
            }
        }()
        
        HStack {
            /* ---------------------
               home
               --------------------- */
            Button(action: {
//                searchStore.send(.updateTextField("토트넘"))
//                searchStore.send(.performSearch())
            }) {
                VStack(spacing: 2) {
                    URLImage(
                        url: NBAUtil.teamLogoURL(id: homeTeamId),
                        size: .small,
                        isSvg: true
                    )
                    
                    Text(teamNameDic["short_\(homeTeamId)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
            }
            .frame(width: 90)
            .foregroundStyle(.primary)
            .disabled(true) // TODO: modify when api added
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            // score
            if gameStatus == 2 ||
                (gameStatus == 3 && isResultOpened) {
                Text("\(homeTeamScore)")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(homeTeamScore >= awayTeamScore ? .moare : .primary)
            }
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            /* ---------------------
               game info
               --------------------- */
            VStack {
                // game status
                CapsuleButton(
                    text: gameStatusText,
                    color: gameStatusColor
                ) {
                    nbaTeamScheduleStore.send(.updateResultOpenedState(gameCode: data.gameId, isOpened: !isResultOpened))
                }
                .disabled(gameStatus != 3)
                
                // game date
                Text(CalendarUtil.formatDate(date: data.date).split(separator: " ").first ?? "")
                    .font(.system(size: 12))
                    .padding(.top, 2)
                
                Text(CalendarUtil.formatDate(date: data.date, formatType: .ampm))
                    .font(.system(size: 12))
                    .padding(.bottom, 2)
                
                // playoffs info
                if let gameInfo = data.gameInfo, gameInfo.weekName.isEmpty {
                    Text("\(NBAUtil.gameType(gameSummary: gameInfo, isShort: true))")
                        .font(.system(size: 11))
                    
//                    if let series = data.seasonSeries, !gameInfo.seriesGameNumber.isEmpty {
//                        HStack(spacing: 0) {
//                            Text("시리즈 스코어: ")
//                                .font(.system(size: 11))
//                            
//                            Text("\(series.homeTeamWins)")
//                                .font(.system(size: 11))
//                                .foregroundStyle(series.homeTeamWins >= series.homeTeamLosses ? .moare : .primary)
//                            
//                            Text(" - ")
//                                .font(.system(size: 11))
//                            
//                            Text("\(series.homeTeamLosses)")
//                                .font(.system(size: 11))
//                                .foregroundStyle(series.homeTeamLosses >= series.homeTeamWins ? .moare : .primary)
//                        }
//                    }
                }
            }
            .frame(width: 100)
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            /* ---------------------
               away
               --------------------- */
            // socre
            if gameStatus == 2 ||
                (gameStatus == 3 && isResultOpened) {
                Text("\(awayTeamScore)")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(awayTeamScore >= homeTeamScore ? .moare : .primary)
            }
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            Button(action: {
//                searchStore.send(.updateTextField("토트넘"))
//                searchStore.send(.performSearch())
            }) {
                VStack(spacing: 2) {
                    URLImage(
                        url: NBAUtil.teamLogoURL(id: awayTeamId),
                        size: .small,
                        isSvg: true
                    )
                    
                    Text(teamNameDic["short_\(awayTeamId ?? 0)"] ?? "")
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
            }
            .frame(width: 90)
            .foregroundStyle(.primary)
            .disabled(true) // TODO: modify when api added
        } // HStack
        .background(Color.clear) // added for tapGesture on Spacer()
        .onTapGesture {
            searchStore.send(.selectNBAGame(game: data))
            
            // set selected game's isOpened true
            nbaTeamScheduleStore.send(.updateResultOpenedState(gameCode: data.gameId, isOpened: true))
        }
        .onAppear {
            if gameStatus == 3 {
                isResultOpened = nbaTeamScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: nbaTeamScheduleStore.gameResultOpenedStateList) {
            if gameStatus == 3 {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = nbaTeamScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
                }
            }
        }
        .onChange(of: searchStore.nbaGameStatsData) {
            if let _ = searchStore.nbaGameStatsData {
                isResultOpened = true
            }
        }
    }
}
