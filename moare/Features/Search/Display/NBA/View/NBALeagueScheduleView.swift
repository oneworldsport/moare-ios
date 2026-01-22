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
                        shouldShowTournamentButton: store.baseSchedule.selectedMonth >= 4 && store.baseSchedule.selectedMonth <= 6,
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
    
    var body: some View {
        let gameListToDisplay = nbaLeagueScheduleStore.filteredGames[nbaLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        let hasLive = gameListToDisplay.contains { game in
            game.gameStatus == String(Constants.GameStatus.NBA.live)
        }
        
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay, id: \.gameId) { item in
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
        let gameStatus = Int(data.gameStatus)
        let teamNameDic = nbaLeagueScheduleStore.baseSchedule.teamNameDictionary
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                leagueId: Constants.Ids.nba,
                game: data,
                teamNameDic: teamNameDic,
                isResultOpened: isResultOpened,
                gameStatusText: Constants.GameStatus.nbaGameStatusText(status: data.gameStatus, period: data.gameInfo?.period, isResultOpened: isResultOpened),
                gameStatusColor: Constants.GameStatus.gameStatusColor(leagueId: Constants.Ids.nba, status: data.gameStatus),
                isCapsuleButtonDisabled: gameStatus != StringConstants.NBA.gameFinal,
                gameType: NBAUtil.gameType(gameSummary: data.gameInfo),
                shouldShowOnlyDateTime: displayModel.scheduleType != ScheduleType.teamFlat, // (리그, 팀)일정 화면에서만 true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    nbaLeagueScheduleStore.send(.selectGame(game: data))
                },
                onCapsuleButtonClick: {
                    nbaLeagueScheduleStore.send(.updateResultOpenedState(gameId: data.gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if gameStatus == StringConstants.NBA.gameFinal {
                isResultOpened = nbaLeagueScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
            } else if gameStatus == StringConstants.NBA.gameScheduled {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: nbaLeagueScheduleStore.gameResultOpenedStateList) {
            if gameStatus == StringConstants.NBA.gameFinal {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = nbaLeagueScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
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
