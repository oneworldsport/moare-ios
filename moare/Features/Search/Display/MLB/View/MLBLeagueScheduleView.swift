//
//  MLBLeagueScheduleView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBLeagueScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var mlbLeagueScheduleStore: StoreOf<MLBLeagueScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: MLBLeagueScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let mlbLeagueScheduleStore {
                    if searchStore.mlbGameStatsData == nil {
                        ScheduleViewContainer(
                            state: ScheduleContainerState(
                                shouldShowCalendar: searchStore.mlbGameStatsData == nil,
                                shouldShowAllResultToggleButton: searchStore.mlbGameStatsData == nil,
                                displayDataState: mlbLeagueScheduleStore.baseSchedule.displayDataState,
                                calendarUiState: CalendarUiState(
                                    yearMonthList: mlbLeagueScheduleStore.baseSchedule.yearMonthList,
                                    days: mlbLeagueScheduleStore.baseSchedule.days,
                                    selectedYearMonthIndex: mlbLeagueScheduleStore.baseSchedule.selectedYearMonthIndex,
                                    selectedDayIndex: mlbLeagueScheduleStore.baseSchedule.selectedDayIndex
                                ),
                                isAllResultOpened: mlbLeagueScheduleStore.baseSchedule.isAllResultOpened
                            ),
                            actions: ScheduleContainerActions(
                                calendarUiActions: CalendarUiActions(
                                    onSelectYearMonth: { yearMonth, index in
                                        mlbLeagueScheduleStore.send(.selectYearMonth(yearMonth: yearMonth, selectedIndex: index))
                                    },
                                    onSelectDay: { day, index in
                                        mlbLeagueScheduleStore.send(.baseSchedule(.selectDay(day, index)))
                                    }
                                ),
                                allResultButtonAction: {
                                    mlbLeagueScheduleStore.send(.toggleAllResult)
                                }
                            ),
                            titleContent: {},
                            gameListContent: {
                                MLBLeagueScheduleList(
                                    searchStore: searchStore,
                                    mlbLeagueScheduleStore: mlbLeagueScheduleStore
                                )
                            }
                        )
                    }
                }
            }
            .onAppear {
                // init MLBLeagueScheduleStore
                let mlbLeagueScheduleStore: StoreOf<MLBLeagueScheduleStore> = storeManager.getStore(forKey: StoreKeys.mlbLeagueScheduleStore) ?? {
                    let newStore = Store(initialState: MLBLeagueScheduleStore.State()) { MLBLeagueScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.mlbLeagueScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.mlbLeagueScheduleStore = mlbLeagueScheduleStore
                }
                
                if searchStore.poppedView == nil {
                    mlbLeagueScheduleStore.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .mlbLeagueSchedule = searchStore.poppedView {
                    mlbLeagueScheduleStore?.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: searchStore.viewStack) {
                guard let lastItem = searchStore.viewStack.last,
                      case .mlbLeagueSchedule = lastItem,
                      let poppedView = searchStore.poppedView,
                      case .mlbGameStats = searchStore.poppedView else {
                    return
                }
                
                mlbLeagueScheduleStore?.send(.updateGamesData(mlbLeagueScheduleData: lastItem, mlbGameStatsData: poppedView))
            }
            .onChange(of: mlbLeagueScheduleStore?.dataForViewStack) {
                if let data = mlbLeagueScheduleStore?.dataForViewStack {
                    searchStore.send(.updateLastViewStack(data: data))
                }
            }
        } // if let searchStore
    }
}

struct MLBLeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbLeagueScheduleStore: StoreOf<MLBLeagueScheduleStore>
    
    @State var gameListToDisplay: [MLBGameForSchedule] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay, id: \.gameId) { item in
                    MLBLeagueScheduleListItem(
                        searchStore: searchStore,
                        mlbLeagueScheduleStore: mlbLeagueScheduleStore,
                        data: item
                    )
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            gameListToDisplay = mlbLeagueScheduleStore.filteredGames[mlbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
        .onChange(of: mlbLeagueScheduleStore.baseSchedule.selectedDayIndex) {
            gameListToDisplay = mlbLeagueScheduleStore.filteredGames[mlbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
        .onChange(of: mlbLeagueScheduleStore.filteredGames) {
            // TODO: Has to think about better structure, because 'gameListToDisplay' could be set multiple times.
            // Has to find if there are cases like here from other .onChange()
            gameListToDisplay = mlbLeagueScheduleStore.filteredGames[mlbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
    }
}

struct MLBLeagueScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbLeagueScheduleStore: StoreOf<MLBLeagueScheduleStore>
    
    let data: MLBGameForSchedule
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let gameStatus = data.gameStatus
        let teamNameDic = mlbLeagueScheduleStore.baseSchedule.teamNameDictionary
        let mlbGameStatsData = searchStore.mlbGameStatsData
        
        let gameStatusText: String = {
//            guard isResultOpened else { return StringConstants.resultOpen }

            switch gameStatus {
            case "S":
                return StringConstants.gameNotStartedStr
            case "I":
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
            case "F":
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            guard isResultOpened else { return .secondary }
            
            if gameStatus == "I" {
                return .moare
            } else {
                return .secondary
            }
        }()
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                homeTeamLogo: MLBUtil.teamLogoURL(id: data.homeTeamId),
                homeTeamName: teamNameDic["short_\(homeTeamId)"] ?? "",
                homeTeamScore: data.homeTeamScore,
                awayTeamLogo: MLBUtil.teamLogoURL(id: data.awayTeamId),
                awayTeamName: teamNameDic["short_\(awayTeamId)"] ?? "",
                awayTeamScore: data.awayTeamScore,
                isResultOpened: isResultOpened,
                gameStatusText: gameStatusText,
                gameStatusColor: gameStatusColor,
                isCapsuleButtonDisabled: gameStatus != "F",
                date: data.date,
                venue: teamNameDic["venue\(homeTeamId)"] ?? "",
                isSvgLogo: true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    searchStore.send(.selectMLBGame(game: data))
                    
                    // set selected game's isOpened true
                    mlbLeagueScheduleStore.send(.updateResultOpenedState(gameId: data.gameId, isOpened: true))
                },
                onCapsuleButtonClick: {
                    mlbLeagueScheduleStore.send(.updateResultOpenedState(gameId: data.gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if gameStatus == "F" {
                isResultOpened = mlbLeagueScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
            } else if gameStatus == "S" {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: mlbLeagueScheduleStore.gameResultOpenedStateList) {
            if gameStatus == "F" {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = mlbLeagueScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
                }
            }
        }
        .onChange(of: searchStore.mlbGameStatsData) {
            if let _ = searchStore.mlbGameStatsData {
                isResultOpened = true
            }
        }
    }
}
