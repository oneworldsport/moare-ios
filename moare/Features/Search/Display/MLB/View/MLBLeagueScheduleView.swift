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
        let displayModel = store.baseSchedule.displayModel
        
        VStack {
            if show {
                ScheduleViewContainer(
                    state: ScheduleContainerState(
                        leagueId: displayModel.leagueId,
                        shouldShowCalendar: displayModel.scheduleType != .teamFlat,
                        shouldFetchSchedule:  displayModel.scheduleType == ScheduleType.league,
                        displayDataState: store.baseSchedule.displayDataState,
                        calendarUiState: CalendarUiState(
                            yearMonthList: store.baseSchedule.yearMonthList,
                            days: store.baseSchedule.days,
                            selectedYearMonthIndex: store.baseSchedule.selectedYearMonthIndex,
                            selectedDayIndex: store.baseSchedule.selectedDayIndex
                        ),
                        isAllResultOpened: store.baseSchedule.isAllResultOpened,
                        shouldShowTournamentButton: store.baseSchedule.selectedMonth >= 10,
                    ),
                    actions: ScheduleContainerActions(
                        calendarUiActions: CalendarUiActions(
                            onSelectYearMonth: { yearMonth, index in
                                store.send(.baseSchedule(.selectYearMonth(yearMonth: yearMonth, selectedIndex: index)))
                            },
                            onSelectDay: { day, index in
                                store.send(.baseSchedule(.selectDay(day, index)))
                            }
                        ),
                        allResultButtonAction: {
                            store.send(.toggleAllResult)
                        },
                        tournamentOrteamStandingsButtonAction: {
                            store.send(.showTeamStandings)
                        },
                        tournamentButtonAction: {
                            store.send(.showTournament)
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
    
    @State private var pageIdx: Int? = 0
    
    var body: some View {
        let selectedDay = mlbLeagueScheduleStore.baseSchedule.selectedDay?.day
        
        let days = mlbLeagueScheduleStore.baseSchedule.days
        var window: [Int] {
            days.indices.filter { idx in
                !(days[idx].isDataEmpty)
            }
        }
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(window, id: \.self) { day in
                    // GameList
                    let gameListToDisplay = mlbLeagueScheduleStore.filteredGames[day] ?? []
                    let hasLive = gameListToDisplay.contains { game in
                        game.gameStatus == Constants.GameStatus.MLB.live
                    }
                    
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
                    .refreshableIf(hasLive) {
                        await mlbLeagueScheduleStore.send(.refreshGames).finish()
                    }
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    .id(day)
                }
            }
            .scrollTargetLayout() // paging 타겟 레이아웃
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $pageIdx)
        .onAppear {
            // 첫 진입 시 선택 날짜로 스크롤 위치 맞춤
            guard let selectedDay else { return }
            pageIdx = selectedDay - 1
        }
        .onChange(of: pageIdx) {
            guard let pageIdx else { return }
            guard days.indices.contains(pageIdx) else { return }

            mlbLeagueScheduleStore.send(.baseSchedule(.selectDay(days[pageIdx], pageIdx)))
        }
        .onChange(of: selectedDay) {
            guard let selectedDay else { return }
            pageIdx = selectedDay - 1
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
        let displayModel = mlbLeagueScheduleStore.baseSchedule.displayModel
        let gameId = data.gameId
        let gameStatus = data.gameStatus
        let teamNameDic = mlbLeagueScheduleStore.baseSchedule.teamNameDictionary
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                leagueId: Constants.Ids.mlb,
                game: data,
                teamNameDic: teamNameDic,
                isClickEnabled: gameStatus != Constants.GameStatus.MLB.postponed, // 연기된 경기는 클릭 안되게
                isResultOpened: isResultOpened,
                gameStatusContext: .mlb(status: gameStatus, currentInning: data.gameInfo?.currentInning, isResultOpened: isResultOpened),
                isCapsuleButtonDisabled: !Constants.GameStatus.MLB.finishedList.contains(gameStatus),
                gameType: data.gameInfo?.seriesDescription,
                shouldShowOnlyDateTime: displayModel.scheduleType != ScheduleType.teamFlat, // (리그, 팀)일정 화면에서만 true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    mlbLeagueScheduleStore.send(.selectGame(game: data))
                },
                onCapsuleButtonClick: {
                    mlbLeagueScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if Constants.GameStatus.MLB.finishedList.contains(gameStatus) {
                isResultOpened = mlbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
            } else if gameStatus == StringConstants.MLB.gameScheduled || gameStatus == StringConstants.MLB.gamePostponed {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: mlbLeagueScheduleStore.gameResultOpenedStateList) {
            if Constants.GameStatus.MLB.finishedList.contains(gameStatus) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = mlbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
                }
            }
        }
    }
}
