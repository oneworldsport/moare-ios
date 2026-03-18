//
//  TennisLeagueScheduleView.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

import SwiftUI
import ComposableArchitecture

struct TennisLeagueScheduleView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<TennisLeagueScheduleStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseSchedule.displayModel
        
        VStack {
            if show {
                ScheduleViewContainer(
                    state: ScheduleContainerState(
                        leagueId: displayModel.leagueId,
                        displayDataState: store.baseSchedule.displayDataState,
                        calendarUiState: CalendarUiState(
                            yearMonthList: store.baseSchedule.yearMonthList,
                            days: store.baseSchedule.days,
                            selectedYearMonthIndex: store.baseSchedule.selectedYearMonthIndex,
                            selectedDayIndex: store.baseSchedule.selectedDayIndex
                        ),
                        isAllResultOpened: store.baseSchedule.isAllResultOpened,
                        shouldShowTournamentOrTeamStandingsButton: false,
                        startDate: displayModel.startDate,
                        endDate: displayModel.endDate,
                        relatedLeagues: displayModel.relatedLeaguesKrname,
                        selectedRelatedLeagueIndex: store.baseSchedule.selectedRelatedLeagueIndex
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
                            store.send(.showTournament)
                        },
                        relatedLeagueButtonAction: { index in
                            store.send(.baseSchedule(.selectRelatedLeague(index: index)))
                        }
                    ),
                    titleContent: {
                        TennisTournamentTitle(leagueId: displayModel.leagueId, season: displayModel.season)
                    },
                    gameListContent: {
                        TennisLeagueScheduleList(
                            searchStore: searchStore,
                            tennisLeagueScheduleStore: store
                        )
                    }
                )
            }
        }
        .onAppear {
            if !didPop {
                store.send(.baseSchedule(.initData))
            } else {
                // TODO: TennisGameStatsView에서 뒤로왔을때만 실행하게 개선 필요
//                store.send(.updateFilteredGames)
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct TennisLeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var tennisLeagueScheduleStore: StoreOf<TennisLeagueScheduleStore>
    
    @State private var pageIdx: Int? = 0
    
    var body: some View {
        let selectedDay = tennisLeagueScheduleStore.baseSchedule.selectedDay?.day
        
        let days = tennisLeagueScheduleStore.baseSchedule.days
        var window: [Int] {
            days.indices.filter { idx in
                !(days[idx].isDataEmpty)
            }
        }
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(window, id: \.self) { day in
                    // GameList
                    let gameListToDisplay = tennisLeagueScheduleStore.filteredGames[day] ?? []
                    let hasLive = gameListToDisplay.contains { game in
                        Constants.GameStatus.Tennis.liveList.contains(Int(game.gameStatus) ?? 0)
                    }
                
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(gameListToDisplay, id: \.gameId) { item in
                                TennisLeagueScheduleListItem(
                                    searchStore: searchStore,
                                    tennisLeagueScheduleStore: tennisLeagueScheduleStore,
                                    data: item
                                )
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .refreshableIf(hasLive) {
                        await tennisLeagueScheduleStore.send(.refreshGames).finish()
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

            tennisLeagueScheduleStore.send(.baseSchedule(.selectDay(days[pageIdx], pageIdx)))
        }
        .onChange(of: selectedDay) {
            guard let selectedDay else { return }
            pageIdx = selectedDay - 1
        }
    }
}

struct TennisLeagueScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var tennisLeagueScheduleStore: StoreOf<TennisLeagueScheduleStore>
    
    let data: TennisGameForSchedule
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let displayModel = tennisLeagueScheduleStore.baseSchedule.displayModel
        let leagueId = displayModel.leagueId
        let gameId = data.gameId
        let gameStatus = Int(data.gameStatus) ?? 0
        let teamNameDic = tennisLeagueScheduleStore.baseSchedule.teamNameDictionary
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                leagueId: leagueId,
                game: data,
                teamNameDic: teamNameDic,
                isResultOpened: isResultOpened,
                gameStatusContext: .tennis(status: gameStatus, isResultOpened: isResultOpened),
                isCapsuleButtonDisabled: !Constants.GameStatus.Tennis.finishedList.contains(gameStatus),
                gameType: data.gameInfo?.roundInfo?.name,
                shouldShowWinner: data.gameInfo?.isGameFinished ?? false,
                isHomeWinner: data.gameInfo?.isHomeWinner ?? true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    tennisLeagueScheduleStore.send(.selectGame(game: data))
                },
                onCapsuleButtonClick: {
                    tennisLeagueScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if Constants.GameStatus.Tennis.finishedList.contains(gameStatus) {
                isResultOpened = tennisLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
            } else if gameStatus == Constants.GameStatus.Tennis.notStarted {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: tennisLeagueScheduleStore.gameResultOpenedStateList) {
            if Constants.GameStatus.Tennis.finishedList.contains(gameStatus) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = tennisLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
                }
            }
        }
    }
}
