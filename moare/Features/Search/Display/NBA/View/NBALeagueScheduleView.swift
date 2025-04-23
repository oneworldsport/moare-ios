//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBALeagueScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var nbaLeagueScheduleStore: StoreOf<NBALeagueScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: NBALeagueScheduleDisplayModel
    
    /* ---------------------
       ui state
       --------------------- */
    @State var shouldScrollCalendar = true
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let nbaLeagueScheduleStore {
                    if searchStore.nbaGameStatsData == nil {
                        /* ---------------------
                           calendar
                           - hides when game selected
                           --------------------- */
                        CalendarList(
                            dateList: nbaLeagueScheduleStore.yearMonthList,
                            calendarType: .yearmonth,
                            selectedIndex: nbaLeagueScheduleStore.selectedYearMonthIndex
                        ) { yearMonth, index in
                            shouldScrollCalendar = true
                            nbaLeagueScheduleStore.send(.selectYearMonth(yearMonth: yearMonth, selectedIndex: index))
                        }
                        .padding(.bottom, 10)
                        
                        CalendarList(
                            dateList: nbaLeagueScheduleStore.days,
                            calendarType: .day,
                            selectedIndex: nbaLeagueScheduleStore.selectedDayIndex,
                            shouldScroll: $shouldScrollCalendar
                        ) { day, index in
                            shouldScrollCalendar = false
                            nbaLeagueScheduleStore.send(.selectDay(day: day, selectedIndex: index))
                        }
                        .padding(.bottom, 6)
                        
                        /* ---------------------
                           all result open button
                           - hides when game selected
                           --------------------- */
                        HStack {
                            Spacer()
                            
                            CapsuleButton(
                                text: nbaLeagueScheduleStore.isAllResultOpened ? StringConstants.resultHide : StringConstants.resultOpen,
                                color: .secondary
                            ) {
                                nbaLeagueScheduleStore.send(.toggleAllResult)
                            }
                            .padding(.trailing)
                        }
                        
                        ZStack {
                            /* ---------------------
                               loading
                               --------------------- */
                            if nbaLeagueScheduleStore.displayDataState == .fetching {
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                    .padding(.top, 8)
                            }
                            
                            /* ---------------------
                               schedule
                               --------------------- */
                            if nbaLeagueScheduleStore.displayDataState == .success {
                                NBALeagueScheduleList(
                                    searchStore: searchStore,
                                    nbaLeagueScheduleStore: nbaLeagueScheduleStore
                                )
                            }
                            
                            /* ---------------------
                               error
                               --------------------- */
                            if case .failure(let message) = nbaLeagueScheduleStore.displayDataState {
                                Text(message)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                    .padding(.top, 8)
                            }
                        }
                    } // if searchStore.nbaGameStatsData == nil
                } // if let nbaLeagueScheduleStore
            } // VStack
            .onAppear {
                // init NBALeagueScheduleStore
                let nbaLeagueScheduleStore: StoreOf<NBALeagueScheduleStore> = storeManager.getStore(forKey: StoreKeys.nbaLeagueScheduleStore) ?? {
                    let newStore = Store(initialState: NBALeagueScheduleStore.State()) { NBALeagueScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.nbaLeagueScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.nbaLeagueScheduleStore = nbaLeagueScheduleStore
                }
                
                if searchStore.poppedView == nil {
                    nbaLeagueScheduleStore.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: displayModel) {
                if case .nbaLeagueSchedule = searchStore.poppedView {
                    nbaLeagueScheduleStore?.send(.initData(displayModel: displayModel))
                }
            }
            .onChange(of: searchStore.viewStack) {
                guard let lastItem = searchStore.viewStack.last,
                      case .nbaLeagueSchedule = lastItem,
                      let poppedView = searchStore.poppedView,
                      case .nbaGameStats = searchStore.poppedView else {
                    return
                }
                
                nbaLeagueScheduleStore?.send(.updateGamesData(nbaLeagueScheduleData: lastItem, nbaGameStatsData: poppedView))
            }
            .onChange(of: nbaLeagueScheduleStore?.dataForViewStack) {
                if let data = nbaLeagueScheduleStore?.dataForViewStack {
                    searchStore.send(.updateLastViewStack(data: data))
                }
            }
        } // if let searchStore
    }
}

struct NBALeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueScheduleStore: StoreOf<NBALeagueScheduleStore>
    
    @State var gameListToDisplay: [NBAGame] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay, id: \.gameSummary?.gameCode) { item in
                    NBALeagueScheduleListItem(
                        searchStore: searchStore,
                        nbaLeagueScheduleStore: nbaLeagueScheduleStore,
                        data: item
                    )
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            gameListToDisplay = nbaLeagueScheduleStore.filteredGames[nbaLeagueScheduleStore.selectedDayIndex] ?? []
        }
        .onChange(of: nbaLeagueScheduleStore.selectedDayIndex) { newValue in
            gameListToDisplay = nbaLeagueScheduleStore.filteredGames[newValue] ?? []
        }
        .onChange(of: nbaLeagueScheduleStore.filteredGames) {
            // TODO: Has to think about better structure, because 'gameListToDisplay' could be set multiple times.
            // Has to find if there are cases like here from other .onChange()
            gameListToDisplay = nbaLeagueScheduleStore.filteredGames[nbaLeagueScheduleStore.selectedDayIndex] ?? []
        }
    }
}

struct NBALeagueScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueScheduleStore: StoreOf<NBALeagueScheduleStore>
    
    let data: NBAGame
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let homeTeamId = data.gameSummary?.homeTeamId
        let awayTeamId = data.gameSummary?.visitorTeamId
        let homeTeamScore = data.lineScore.first { $0.teamId == homeTeamId }?.pts ?? 0
        let awayTeamScore = data.lineScore.first { $0.teamId == awayTeamId }?.pts ?? 0
        let teamNameDic = nbaLeagueScheduleStore.teamNameDictionary
        
        let gameStatusText: String = {
            guard isResultOpened else { return StringConstants.resultOpen }

            switch data.gameSummary?.gameStatusId {
            case 1:
                return StringConstants.gameNotStartedStr
            case 2:
                guard let first = data.lineScore.first else { return "" }
                if first.ptsOt3 != nil {
                    return StringConstants.NBA.gameOt3
                } else if first.ptsOt2 != nil {
                    return StringConstants.NBA.gameOt2
                } else if first.ptsOt1 != nil {
                    return StringConstants.NBA.gameOt1
                } else if first.ptsQtr4 != nil {
                    return StringConstants.NBA.gameQtr4
                } else if first.ptsQtr3 != nil {
                    return StringConstants.NBA.gameQtr3
                } else if first.ptsQtr2 != nil {
                    return StringConstants.NBA.gameQtr2
                } else if first.ptsQtr1 != nil {
                    return StringConstants.NBA.gameQtr1
                } else {
                    return ""
                }
            case 3:
                return StringConstants.gameFinishedStr
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            guard isResultOpened else { return .secondary }
            
            if data.gameSummary?.gameStatusId == 2 {
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
                        url: homeTeamId.map { NBAUtil.teamLogoURL(id: $0) } ?? "", // NOTE: map을 통한 Optional unwrapping
                        size: .small,
                        isSvg: true
                    )
                    
                    Text(teamNameDic["short_\(homeTeamId ?? 0)"] ?? "")
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
            if data.gameSummary?.gameStatusId == 2 ||
                (data.gameSummary?.gameStatusId == 3 && isResultOpened) {
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
                    if let gameSummary = data.gameSummary {
                        nbaLeagueScheduleStore.send(.updateResultOpenedState(gameCode: gameSummary.gameCode, isOpened: !isResultOpened))
                    }
                }
                .disabled(data.gameSummary?.gameStatusId != 3)
                
                // game date
                Text(CalendarUtil.formatDate(date: data.gameSummary?.date, formatType: .ampm))
                    .font(.system(size: 12))
                    .padding(.vertical, 2)
                
                // playoffs info
                if let gameSummary = data.gameSummary, gameSummary.weekName.isEmpty {
                    Text("\(NBAUtil.gameType(gameSummary: data.gameSummary, isShort: true))")
                        .font(.system(size: 11))
                    
                    if let series = data.seasonSeries, !gameSummary.seriesGameNumber.isEmpty {
                        HStack(spacing: 0) {
                            Text("시리즈 스코어: ")
                                .font(.system(size: 11))
                            
                            Text("\(series.homeTeamWins)")
                                .font(.system(size: 11))
                                .foregroundStyle(series.homeTeamWins >= series.homeTeamLosses ? .moare : .primary)
                            
                            Text(" - ")
                                .font(.system(size: 11))
                            
                            Text("\(series.homeTeamLosses)")
                                .font(.system(size: 11))
                                .foregroundStyle(series.homeTeamLosses >= series.homeTeamWins ? .moare : .primary)
                        }
                    }
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
            if data.gameSummary?.gameStatusId == 2 ||
                (data.gameSummary?.gameStatusId == 3 && isResultOpened) {
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
                        url: awayTeamId.map { NBAUtil.teamLogoURL(id: $0) } ?? "",
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
            if let gameSummary = data.gameSummary {
                nbaLeagueScheduleStore.send(.updateResultOpenedState(gameCode: gameSummary.gameCode, isOpened: true))
            }
        }
        .onAppear {
            if data.gameSummary?.gameStatusId == 3 {
                isResultOpened = nbaLeagueScheduleStore.gameResultOpenedStateList[data.gameSummary!.gameCode] ?? false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: nbaLeagueScheduleStore.gameResultOpenedStateList) {
            if data.gameSummary?.gameStatusId == 3 {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = nbaLeagueScheduleStore.gameResultOpenedStateList[data.gameSummary!.gameCode] ?? false
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
