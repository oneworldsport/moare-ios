//
//  KBOLeagueScheduleView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOLeagueScheduleView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<KBOLeagueScheduleStore>
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
                        KBOLeagueScheduleList(
                            searchStore: searchStore,
                            kboLeagueScheduleStore: store
                        )
                    }
                )
            }
        }
        .onAppear {
            if !didPop {
                store.send(.baseSchedule(.initData))
            } else {
                // TODO: KBOGameStatsView에서 뒤로왔을때만 실행하게 개선 필요
                store.send(.updateFilteredGames)
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct KBOLeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboLeagueScheduleStore: StoreOf<KBOLeagueScheduleStore>
    
    @State private var pageIdx: Int? = 0
    
    var body: some View {
        let selectedDay = kboLeagueScheduleStore.baseSchedule.selectedDay?.day
        
        let days = kboLeagueScheduleStore.baseSchedule.days
        var window: [Int] {
            days.indices.filter { idx in
                !(days[idx].isDataEmpty)
            }
        }
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(window, id: \.self) { day in
                    // GameList
                    let gameListToDisplay = kboLeagueScheduleStore.filteredGames[day] ?? []
                    let hasLive = gameListToDisplay.contains { game in
                        game.gameStatus == Constants.GameStatus.KBO.live
                    }
                    
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
                    .refreshableIf(hasLive) {
                        await kboLeagueScheduleStore.send(.refreshGames).finish()
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

            kboLeagueScheduleStore.send(.baseSchedule(.selectDay(days[pageIdx], pageIdx)))
        }
        .onChange(of: selectedDay) {
            guard let selectedDay else { return }
            pageIdx = selectedDay - 1
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
        let displayModel = kboLeagueScheduleStore.baseSchedule.displayModel
        let itemKey = data.itemKey
        let gameStatus = Int(data.gameStatus) // TODO: String으로 사용
        let teamNameDic = kboLeagueScheduleStore.baseSchedule.teamNameDictionary
        
        let gameStatusText: String = {
            switch gameStatus {
            case StringConstants.KBO.gameScheduled:
                return StringConstants.gameNotStartedStr
            case StringConstants.KBO.gameLive:
                return data.gameInfo?.currentInning ?? StringConstants.gameLiveStr
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
                leagueId: Constants.Ids.kbo,
                game: data,
                teamNameDic: teamNameDic,
                isClickEnabled: data.gameStatus != Constants.GameStatus.KBO.canceled, // 취소된 경기는 클릭 안되게
                isResultOpened: isResultOpened,
                gameStatusText: gameStatusText,
                gameStatusColor: gameStatusColor,
                isCapsuleButtonDisabled: gameStatus != StringConstants.KBO.gameFinal,
                gameType: data.gameInfo?.seriesDescription,
                shouldShowOnlyDateTime: displayModel.scheduleType != ScheduleType.teamFlat, // (리그, 팀)일정 화면에서만 true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    kboLeagueScheduleStore.send(.selectGame(game: data))
                },
                onCapsuleButtonClick: {
                    kboLeagueScheduleStore.send(.updateResultOpenedState(itemKey: itemKey, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if gameStatus == StringConstants.KBO.gameFinal {
                isResultOpened = kboLeagueScheduleStore.gameResultOpenedStateList[itemKey] ?? false
            } else if gameStatus == StringConstants.KBO.gameScheduled || gameStatus == StringConstants.KBO.gameCanceled {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: kboLeagueScheduleStore.gameResultOpenedStateList) {
            if gameStatus == StringConstants.KBO.gameFinal {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = kboLeagueScheduleStore.gameResultOpenedStateList[itemKey] ?? false
                }
            }
        }
    }
}
