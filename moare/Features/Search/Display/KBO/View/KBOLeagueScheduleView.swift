//
//  KBOLeagueScheduleView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOLeagueScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var kboLeagueScheduleStore: StoreOf<KBOLeagueScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: KBOLeagueScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let kboLeagueScheduleStore {
                    if searchStore.kboGameStatsData == nil {
                        ScheduleViewContainer(
                            state: ScheduleContainerState(
                                shouldShowCalendar: searchStore.kboGameStatsData == nil,
                                shouldShowAllResultToggleButton: searchStore.kboGameStatsData == nil,
                                displayDataState: kboLeagueScheduleStore.baseSchedule.displayDataState,
                                calendarUiState: CalendarUiState(
                                    yearMonthList: kboLeagueScheduleStore.baseSchedule.yearMonthList,
                                    days: kboLeagueScheduleStore.baseSchedule.days,
                                    selectedYearMonthIndex: kboLeagueScheduleStore.baseSchedule.selectedYearMonthIndex,
                                    selectedDayIndex: kboLeagueScheduleStore.baseSchedule.selectedDayIndex
                                ),
                                isAllResultOpened: kboLeagueScheduleStore.baseSchedule.isAllResultOpened
                            ),
                            actions: ScheduleContainerActions(
                                calendarUiActions: CalendarUiActions(
                                    onSelectYearMonth: { yearMonth, index in
                                        kboLeagueScheduleStore.send(.selectYearMonth(yearMonth: yearMonth, selectedIndex: index))
                                    },
                                    onSelectDay: { day, index in
                                        kboLeagueScheduleStore.send(.baseSchedule(.selectDay(day, index)))
                                    }
                                ),
                                allResultButtonAction: {
                                    kboLeagueScheduleStore.send(.toggleAllResult)
                                }
                            ),
                            titleContent: {},
                            gameListContent: {
                                KBOLeagueScheduleList(
                                    searchStore: searchStore,
                                    kboLeagueScheduleStore: kboLeagueScheduleStore
                                )
                            }
                        )
                    }
                }
            }
            .onAppear {
                // init KBOLeagueScheduleStore
                let kboLeagueScheduleStore: StoreOf<KBOLeagueScheduleStore> = storeManager.getStore(forKey: StoreKeys.kboLeagueScheduleStore) ?? {
                    let newStore = Store(initialState: KBOLeagueScheduleStore.State()) { KBOLeagueScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboLeagueScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.kboLeagueScheduleStore = kboLeagueScheduleStore
                }
                
                if searchStore.poppedView == nil {
                    kboLeagueScheduleStore.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .kboLeagueSchedule = searchStore.poppedView {
                    kboLeagueScheduleStore?.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: searchStore.viewStack) {
                guard let lastItem = searchStore.viewStack.last,
                      case .kboLeagueSchedule = lastItem,
                      let poppedView = searchStore.poppedView,
                      case .kboGameStats = searchStore.poppedView else {
                    return
                }
                
                kboLeagueScheduleStore?.send(.updateGamesData(kboLeagueScheduleData: lastItem, kboGameStatsData: poppedView))
            }
            .onChange(of: kboLeagueScheduleStore?.dataForViewStack) {
                if let data = kboLeagueScheduleStore?.dataForViewStack {
                    searchStore.send(.updateLastViewStack(data: data))
                }
            }
        } // if let searchStore
    }
}

struct KBOLeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboLeagueScheduleStore: StoreOf<KBOLeagueScheduleStore>
    
    @State var gameListToDisplay: [KBOGameForSchedule] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay, id: \.gameId) { item in
                    KBOLeagueScheduleListItem(
                        searchStore: searchStore,
                        kboLeagueScheduleStore: kboLeagueScheduleStore,
                        data: item
                    )
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            gameListToDisplay = kboLeagueScheduleStore.filteredGames[kboLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
        .onChange(of: kboLeagueScheduleStore.baseSchedule.selectedDayIndex) { newValue in
            gameListToDisplay = kboLeagueScheduleStore.filteredGames[newValue] ?? []
        }
        .onChange(of: kboLeagueScheduleStore.filteredGames) {
            // TODO: Has to think about better structure, because 'gameListToDisplay' could be set multiple times.
            // Has to find if there are cases like here from other .onChange()
            gameListToDisplay = kboLeagueScheduleStore.filteredGames[kboLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
    }
}

struct KBOLeagueScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboLeagueScheduleStore: StoreOf<KBOLeagueScheduleStore>
    
    let data: KBOGameForSchedule
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let gameStatus = Int(data.gameStatus)
        let teamNameDic = kboLeagueScheduleStore.baseSchedule.teamNameDictionary
        let kboGameStatsData = searchStore.kboGameStatsData
        
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
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                homeTeamLogo: KBOUtil.teamLogoURL(id: data.homeTeamId),
                homeTeamName: teamNameDic["short_\(homeTeamId)"] ?? "",
                homeTeamScore: data.homeTeamScore,
                awayTeamLogo: KBOUtil.teamLogoURL(id: data.awayTeamId),
                awayTeamName: teamNameDic["short_\(awayTeamId)"] ?? "",
                awayTeamScore: data.awayTeamScore,
                isResultOpened: isResultOpened,
                gameStatusText: gameStatusText,
                gameStatusColor: gameStatusColor,
                isCapsuleButtonDisabled: gameStatus != 3,
                date: data.date,
                venue: teamNameDic["venue\(homeTeamId)"] ?? "",
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    searchStore.send(.selectKBOGame(game: data))
                    
                    // set selected game's isOpened true
                    kboLeagueScheduleStore.send(.updateResultOpenedState(gameId: data.gameId, isOpened: true))
                },
                onCapsuleButtonClick: {
                    kboLeagueScheduleStore.send(.updateResultOpenedState(gameId: data.gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if gameStatus == 3 {
                isResultOpened = kboLeagueScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: kboLeagueScheduleStore.gameResultOpenedStateList) {
            if gameStatus == 3 {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = kboLeagueScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
                }
            }
        }
        .onChange(of: searchStore.kboGameStatsData) {
            if let _ = searchStore.kboGameStatsData {
                isResultOpened = true
            }
        }
    }
}
