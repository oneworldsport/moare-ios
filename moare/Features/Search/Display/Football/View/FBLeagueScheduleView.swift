//
//  Schedule.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import SwiftUI
import ComposableArchitecture

struct FBLeagueScheduleView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<FBLeagueScheduleStore>
    let didPop: Bool
    let isCombinedView: Bool
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseSchedule.displayModel
        let leagueId = displayModel.leagueId
        let tournamentStartDateYearMonth = CalendarUtil.formatDate(date: displayModel.tournamentStartDate, inputFormatType: .dateOnly, outputFormatType: .yearMonth)
        let tournamentStartDateYearMonthInt = Int(tournamentStartDateYearMonth.replacingOccurrences(of: "/", with: "")) ?? 0
        let selectedYearMonthInt = Int(store.baseSchedule.selectedYearMonth.replacingOccurrences(of: "/", with: "")) ?? 0
        
        VStack {
            if show {
                ScheduleViewContainer(
                    state: ScheduleContainerState(
                        leagueId: leagueId,
                        shouldShowCalendar: (displayModel.scheduleType != .teamFlat) && (store.selectedGame == nil),
                        shouldShowAllResultToggleButton: store.selectedGame == nil,
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
                            if Constants.Ids.footballDrawTournamentLeagues.contains(leagueId) {
                                store.send(.showTournament)
                            } else {
                                store.send(.showTeamStandings)
                            }
                        },
                        tournamentButtonAction: {
                            store.send(.showTournament)
                        }
                    ),
                    titleContent: {
                        if let league = store.league, store.selectedGame != nil {
                            FBLeagueTitleForGameStats(
                                url: league.logo,
                                leagueName: league.name,
                                leagueSeason: league.season,
                                description: league.round
                            )
                        }
                    },
                    gameListContent: {
                        FBLeagueScheduleList(
                            searchStore: searchStore,
                            fbLeagueScheduleStore: store
                        )
                    }
                )
            }
        }
        .onAppear {
            if !isCombinedView {
                if !didPop {
                    store.send(.baseSchedule(.initData))
                } else {
                    // TODO: FBGameStatsView에서 뒤로왔을때만 실행하게 개선 필요
                    store.send(.updateFilteredGames)
                }
            }
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
        .onChange(of: store.baseSchedule.displayModel) {
            // FBGameStatsView에서 새로고침 후 AppStore에서 FBLeagueScheduleDisplayModel이 업데이트 됐을때 해당 .onChange 실행
            store.send(.updateSelectedGame)
        }
    }
}

struct FBLeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>

    @State var itemHeight: CGFloat? = nil
    @State private var pageIdx: Int? = 0
    
    var body: some View {
        let selectedDay = fbLeagueScheduleStore.baseSchedule.selectedDay?.day
        let isCollapsed = fbLeagueScheduleStore.selectedGame != nil
        let teamNameDic = fbLeagueScheduleStore.baseSchedule.teamNameDictionary
        
        let days = fbLeagueScheduleStore.baseSchedule.days
        var window: [Int] {
            days.indices.filter { idx in
                !(days[idx].isDataEmpty)
            }
        }
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(window, id: \.self) { day in
                    // GameList
                    let gameListToDisplay = fbLeagueScheduleStore.filteredGames[day] ?? []
                    let singleId = gameListToDisplay.first?.gameId
                    let hasLive = gameListToDisplay.contains { game in
                        Constants.GameStatus.Football.liveList.contains(game.gameStatus)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(gameListToDisplay, id: \.gameId) { value in
                                FBLeagueScheduleListItem(
                                    searchStore: searchStore,
                                    fbLeagueScheduleStore: fbLeagueScheduleStore,
                                    data: value,
                                    leagueId: fbLeagueScheduleStore.baseSchedule.displayModel.leagueId,
                                    teamNameDic: teamNameDic
                                )
                                .background(
                                    // NOTE: .readSize가 안먹혀서 아래 코드로 적용
                                    Group {
                                        if isCollapsed && value.gameId == singleId {
                                            GeometryReader { proxy in
                                                Color.clear
                                                    .onAppear { itemHeight = proxy.size.height }
                                                    .onChange(of: proxy.size.height) { itemHeight = proxy.size.height }
                                            }
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .frame(height: isCollapsed ? itemHeight : nil)
                    .scrollDisabled(isCollapsed)
                    .refreshableIf(hasLive) {
                        await fbLeagueScheduleStore.send(.refreshGames).finish()
                    }
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    .id(day)
                }
            }
            .scrollTargetLayout() // paging 타겟 레이아웃
        }
        .frame(height: isCollapsed ? itemHeight : nil)
        .scrollDisabled(isCollapsed)
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

            fbLeagueScheduleStore.send(.baseSchedule(.selectDay(days[pageIdx], pageIdx)))
        }
        .onChange(of: selectedDay) {
            guard let selectedDay else { return }
            pageIdx = selectedDay - 1
        }
    }
}

struct FBLeagueScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    // STUDY: @Bindable을 써야할때가 따로 있음. 더 알아보고 제대로 사용해야 할듯..
//    @Bindable var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>
    let fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>?
    
    let data: FBGameForSchedule
    let leagueId: Int
    // FBLeagueScheduleStore이 한번도 초기화 된적 없이 FBGameStatsView에서 해당 구조체가 호출될때 teamNameDictionary를 fbLeagueScheduleStore에서 가져올수가 없어 추가.
    let teamNameDic: [String: String]
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let gameId = data.gameId
        let gameStatus = data.gameStatus
        // FBLeagueScheduleView가 아닌 FBPlayerInfoView나 FBTeamInfoView 등에서 보여질때 사용되는 flag
        let isFromSchedule = fbLeagueScheduleStore != nil
        let displayModel = fbLeagueScheduleStore?.baseSchedule.displayModel
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                leagueId: leagueId,
                game: data,
                teamNameDic: teamNameDic,
                isClickEnabled: isFromSchedule ? fbLeagueScheduleStore?.selectedGame == nil : false,
                isResultOpened: isResultOpened,
                gameStatusContext: .football(status: data.gameStatus, elapsed: data.gameInfo?.status?.elapsed, extra: data.gameInfo?.status?.extra, isResultOpened: isResultOpened),
                isCapsuleButtonDisabled: (isFromSchedule ? fbLeagueScheduleStore?.selectedGame != nil : true) || !Constants.GameStatus.Football.finishedList.contains(gameStatus),
                gameType: MatchDescriptionConverter.convert(input: data.gameInfo?.round ?? ""),
                shouldShowOnlyDateTime: isFromSchedule ? (
                    (displayModel?.scheduleType != ScheduleType.teamFlat) && (fbLeagueScheduleStore?.selectedGame == nil)
                ) : false, // Schedule일때는 (리그, 팀)일정 화면이고 selectedGame이 없을때만 true
                shouldShowGameType: isFromSchedule ? fbLeagueScheduleStore?.selectedGame == nil : false,
                shouldShowHomeLabel: isFromSchedule ? fbLeagueScheduleStore?.selectedGame != nil : true,
                shouldShowAwayLabel: isFromSchedule ? fbLeagueScheduleStore?.selectedGame != nil : true,
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    fbLeagueScheduleStore?.send(.selectGame(game: data))
                },
                onCapsuleButtonClick: {
                    fbLeagueScheduleStore?.send(.updateResultOpenedState(gameId: gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if let fbLeagueScheduleStore {
                if Constants.GameStatus.Football.finishedList.contains(gameStatus) {
                    isResultOpened = fbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
                } else if gameStatus == Constants.GameStatus.Football.notStarted ||
                            gameStatus == Constants.GameStatus.Football.cancelled ||
                            gameStatus == Constants.GameStatus.Football.postponed {
                    isResultOpened = false
                } else {
                    isResultOpened = true
                }
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: fbLeagueScheduleStore?.gameResultOpenedStateList) {
            if let fbLeagueScheduleStore, Constants.GameStatus.Football.finishedList.contains(gameStatus) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = fbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
                }
            }
        }
    }
}
