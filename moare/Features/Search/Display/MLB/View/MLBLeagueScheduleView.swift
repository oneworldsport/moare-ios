//
//  MLBLeagueScheduleView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBLeagueScheduleView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<MLBLeagueScheduleStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        VStack {
            if show {
                ScheduleViewContainer(
                    state: ScheduleContainerState(
                        displayDataState: store.baseSchedule.displayDataState,
                        calendarUiState: CalendarUiState(
                            yearMonthList: store.baseSchedule.yearMonthList,
                            days: store.baseSchedule.days,
                            selectedYearMonthIndex: store.baseSchedule.selectedYearMonthIndex,
                            selectedDayIndex: store.baseSchedule.selectedDayIndex
                        ),
                        isAllResultOpened: store.baseSchedule.isAllResultOpened
                    ),
                    actions: ScheduleContainerActions(
                        calendarUiActions: CalendarUiActions(
                            onSelectYearMonth: { yearMonth, index in
                                store.send(.selectYearMonth(yearMonth: yearMonth, selectedIndex: index))
                            },
                            onSelectDay: { day, index in
                                store.send(.baseSchedule(.selectDay(day, index)))
                            }
                        ),
                        allResultButtonAction: {
                            store.send(.toggleAllResult)
                        }
                    ),
                    titleContent: {},
                    gameListContent: {
                        MLBLeagueScheduleList(
                            searchStore: searchStore,
                            mlbLeagueScheduleStore: store
                        )
                    }
                )
            }
        }
        .onAppear {
            if !didPop {
                store.send(.baseSchedule(.initData))
            } else {
                // TODO: MLBGameStatsView에서 뒤로왔을때만 실행하게 개선 필요
                store.send(.updateFilteredGames)
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct MLBLeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbLeagueScheduleStore: StoreOf<MLBLeagueScheduleStore>
    
    var body: some View {
        let gameListToDisplay = mlbLeagueScheduleStore.filteredGames[mlbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        
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
        let gameId = data.gameId
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let gameStatus = data.gameStatus
        let teamNameDic = mlbLeagueScheduleStore.baseSchedule.teamNameDictionary
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                isClickEnabled: gameStatus != Constants.GameStatus.MLB.postponed, // 연기된 경기는 클릭 안되게
                homeTeamLogo: MLBUtil.teamLogoURL(id: homeTeamId),
                homeTeamName: teamNameDic["short_\(homeTeamId)"] ?? "",
                homeTeamScore: data.homeTeamScore,
                awayTeamLogo: MLBUtil.teamLogoURL(id: awayTeamId),
                awayTeamName: teamNameDic["short_\(awayTeamId)"] ?? "",
                awayTeamScore: data.awayTeamScore,
                isResultOpened: isResultOpened,
                gameStatusText: Constants.GameStatus.mlbGameStatusText(status: gameStatus, currentInning: data.gameInfo?.currentInning, isResultOpened: isResultOpened),
                gameStatusColor: Constants.GameStatus.gameStatusColor(leagueId: Constants.Ids.mlb, status: gameStatus),
                isCapsuleButtonDisabled: !StringConstants.MLB.gameFinishedList.contains(gameStatus),
                date: data.date,
                venue: teamNameDic["venue_\(homeTeamId)"] ?? "",
                isSvgLogo: true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    searchStore.send(.selectMLBGame(game: data, season: mlbLeagueScheduleStore.baseSchedule.displayModel.season))
                    
                    // set selected game's isOpened true
                    mlbLeagueScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: true))
                },
                onCapsuleButtonClick: {
                    mlbLeagueScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if StringConstants.MLB.gameFinishedList.contains(gameStatus) {
                isResultOpened = mlbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
            } else if gameStatus == StringConstants.MLB.gameScheduled || gameStatus == StringConstants.MLB.gamePostponed {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: mlbLeagueScheduleStore.gameResultOpenedStateList) {
            if StringConstants.MLB.gameFinishedList.contains(gameStatus) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = mlbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
                }
            }
        }
    }
}
