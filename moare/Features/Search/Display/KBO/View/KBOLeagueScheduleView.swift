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
            let kboGameStatsModel = searchStore.displayModels[.kboGameStats] as? KBOGameStatsDisplayModel
            
            VStack(spacing: 0) {
                if let kboLeagueScheduleStore {
                    if kboGameStatsModel == nil {
                        ScheduleViewContainer(
                            state: ScheduleContainerState(
                                shouldShowCalendar: kboGameStatsModel == nil,
                                shouldShowAllResultToggleButton: kboGameStatsModel == nil,
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
                ForEach(gameListToDisplay, id: \.itemKey) { item in
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
        let kboGameStatsModel = searchStore.displayModels[.kboGameStats] as? KBOGameStatsDisplayModel
        
        let gameStatusText: String = {
            switch gameStatus {
            case StringConstants.KBO.gameScheduled:
                return StringConstants.gameNotStartedStr
            case StringConstants.KBO.gameLive:
                return StringConstants.gameLiveStr
            case StringConstants.KBO.gameFinal:
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
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
                isCapsuleButtonDisabled: gameStatus != StringConstants.KBO.gameFinal,
                date: data.date,
                venue: teamNameDic["venue_\(homeTeamId)"] ?? "",
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    searchStore.send(.selectKBOGame(game: data))
                    
                    // set selected game's isOpened true
                    kboLeagueScheduleStore.send(.updateResultOpenedState(itemKey: data.itemKey, isOpened: true))
                },
                onCapsuleButtonClick: {
                    kboLeagueScheduleStore.send(.updateResultOpenedState(itemKey: data.itemKey, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if gameStatus == StringConstants.KBO.gameFinal {
                isResultOpened = kboLeagueScheduleStore.gameResultOpenedStateList[data.itemKey] ?? false
            } else if gameStatus == StringConstants.KBO.gameScheduled || gameStatus == StringConstants.KBO.gameCanceled {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: kboLeagueScheduleStore.gameResultOpenedStateList) {
            if gameStatus == StringConstants.KBO.gameFinal {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = kboLeagueScheduleStore.gameResultOpenedStateList[data.itemKey] ?? false
                }
            }
        }
        .onChange(of: kboGameStatsModel) {
            if let kboGameStatsModel {
                isResultOpened = true
            }
        }
    }
}
