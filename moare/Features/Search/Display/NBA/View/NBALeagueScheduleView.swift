//
//  Untitled.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct NBALeagueScheduleView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<NBALeagueScheduleStore>
    let didPop: Bool
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseSchedule.displayModel
        let tournamentStartDateYearMonth = CalendarUtil.formatDate(date: displayModel.tournamentStartDate, inputFormatType: .dateOnly, outputFormatType: .yearMonth)
        let tournamentStartDateYearMonthInt = Int(tournamentStartDateYearMonth.replacingOccurrences(of: "/", with: "")) ?? 0
        let selectedYearMonthInt = Int(store.baseSchedule.selectedYearMonth.replacingOccurrences(of: "/", with: "")) ?? 0
        
        VStack {
            if show {
                ScheduleViewContainer(
                    state: ScheduleContainerState(
                        leagueId: displayModel.leagueId,
                        shouldShowCalendar: displayModel.scheduleType != ScheduleType.teamFlat,
                        shouldFetchSchedule:  displayModel.scheduleType == ScheduleType.league,
                        displayDataState: store.baseSchedule.displayDataState,
                        calendarUiState: CalendarUiState(
                            yearMonthList: store.baseSchedule.yearMonthList,
                            days: store.baseSchedule.days,
                            selectedYearMonthIndex: store.baseSchedule.selectedYearMonthIndex,
                            selectedDayIndex: store.baseSchedule.selectedDayIndex
                        ),
                        isAllResultOpened: store.baseSchedule.isAllResultOpened,
                        shouldShowTournamentButton: (displayModel.tournamentStartDate != nil) &&
                        (tournamentStartDateYearMonthInt <= selectedYearMonthInt),
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
                        NBALeagueScheduleList(
                            searchStore: searchStore,
                            nbaLeagueScheduleStore: store
                        )
                    }
                )
            }
        } // VStack
        .onAppear {
            if !didPop {
                store.send(.baseSchedule(.initData))
            } else {
                // TODO: NBAGameStatsView에서 뒤로왔을때만 실행하게 개선 필요
                store.send(.updateFilteredGames)
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct NBALeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueScheduleStore: StoreOf<NBALeagueScheduleStore>
    
    @State private var pageIdx: Int? = 0
    
    var body: some View {
        let selectedDay = nbaLeagueScheduleStore.baseSchedule.selectedDay?.day
        
        let days = nbaLeagueScheduleStore.baseSchedule.days
        var window: [Int] {
            days.indices.filter { idx in
                !(days[idx].isDataEmpty)
            }
        }
        
        ScrollView(.horizontal) {
            // NOTE: LazyHStack이어서 그런지 달력에 day 선택으로 이동 시 CapsuleBar가 약간의 버벅임이 있는 것 같음. 그렇다고 HStack으로 바꿔서 해보니 처음 화면 나오는게 엄청 오래 걸림.
            LazyHStack(spacing: 0) {
                ForEach(window, id: \.self) { day in
                    // GameList
                    let gameListToDisplay = nbaLeagueScheduleStore.filteredGames[day] ?? []
                    let hasLive = gameListToDisplay.contains { game in
                        game.gameStatus == String(Constants.GameStatus.NBA.live)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(gameListToDisplay, id: \.itemKey) { item in
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
                    .refreshableIf(hasLive) {
                        await nbaLeagueScheduleStore.send(.refreshGames).finish()
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

            nbaLeagueScheduleStore.send(.baseSchedule(.selectDay(days[pageIdx], pageIdx)))
        }
        .onChange(of: selectedDay) {
            guard let selectedDay else { return }
            pageIdx = selectedDay - 1
        }
    }
}

struct NBALeagueScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueScheduleStore: StoreOf<NBALeagueScheduleStore>
    
    let data: NBAGameForSchedule
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let displayModel = nbaLeagueScheduleStore.baseSchedule.displayModel
        let itemKey = data.itemKey
        let gameStatus = Int(data.gameStatus) ?? 1
        let teamNameDic = nbaLeagueScheduleStore.baseSchedule.teamNameDictionary
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                leagueId: Constants.Ids.nba,
                game: data,
                teamNameDic: teamNameDic,
                isResultOpened: isResultOpened,
                gameStatusContext: .nba(status: gameStatus, period: data.gameInfo?.period, isResultOpened: isResultOpened),
                isCapsuleButtonDisabled: gameStatus != Constants.GameStatus.NBA.finished,
                gameType: NBAUtil.gameType(gameSummary: data.gameInfo),
                shouldShowOnlyDateTime: displayModel.scheduleType != ScheduleType.teamFlat, // (리그, 팀)일정 화면에서만 true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    nbaLeagueScheduleStore.send(.selectGame(game: data))
                },
                onCapsuleButtonClick: {
                    nbaLeagueScheduleStore.send(.updateResultOpenedState(itemKey: itemKey, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if gameStatus == Constants.GameStatus.NBA.finished {
                isResultOpened = nbaLeagueScheduleStore.gameResultOpenedStateList[itemKey] ?? false
            } else if gameStatus == Constants.GameStatus.NBA.notStarted {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: nbaLeagueScheduleStore.gameResultOpenedStateList) {
            if gameStatus == Constants.GameStatus.NBA.finished {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = nbaLeagueScheduleStore.gameResultOpenedStateList[itemKey] ?? false
                }
            }
        }
    }
}

// playoffs info
//if let gameInfo = data.gameInfo, gameInfo.weekName.isEmpty {
//    Text(NBAUtil.gameType(gameSummary: gameInfo, isShort: true))
//        .font(.system(size: 11))
//    
//    if let series = data.seasonSeries, !gameInfo.seriesGameNumber.isEmpty {
//        HStack(spacing: 0) {
//            Text("시리즈 스코어: ")
//                .font(.system(size: 11))
//            
//            Text("\(series.homeTeamWins)")
//                .font(.system(size: 11))
//                .foregroundStyle(series.homeTeamWins >= series.homeTeamLosses ? .moare : .primary)
//            
//            Text(" - ")
//                .font(.system(size: 11))
//            
//            Text("\(series.homeTeamLosses)")
//                .font(.system(size: 11))
//                .foregroundStyle(series.homeTeamLosses >= series.homeTeamWins ? .moare : .primary)
//        }
//    }
//}
