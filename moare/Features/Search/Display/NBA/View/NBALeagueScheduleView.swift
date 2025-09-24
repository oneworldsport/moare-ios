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
    
    @State private var show = false
    
    var body: some View {
        let displayModel = store.baseSchedule.displayModel
        
        VStack {
            if show {
                ScheduleViewContainer(
                    state: ScheduleContainerState(
                        shouldShowCalendar: displayModel.scheduleType != ScheduleType.teamFlat,
                        shouldFetchSchedule:  displayModel.scheduleType == ScheduleType.league,
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
                        NBALeagueScheduleList(
                            searchStore: searchStore,
                            nbaLeagueScheduleStore: store
                        )
                    }
                )
            }
        } // VStack
        .onAppear {
            store.send(.baseSchedule(.initData))
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
        .onChange(of: searchStore.viewStack) {
            guard let lastItem = searchStore.viewStack.last,
                  case .nbaLeagueSchedule = lastItem,
                  let poppedView = searchStore.poppedView,
                  case .nbaGameStats = searchStore.poppedView else {
                return
            }
            
            store.send(.updateGamesData(nbaLeagueScheduleData: lastItem, nbaGameStatsData: poppedView))
        }
        .onChange(of: store.dataForViewStack) {
            if let data = store.dataForViewStack {
                searchStore.send(.updateLastViewStack(data: data))
            }
        }
    }
}

struct NBALeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var nbaLeagueScheduleStore: StoreOf<NBALeagueScheduleStore>
    
    @State var gameListToDisplay: [NBAGameForSchedule] = []
    
    var body: some View {
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
        .onAppear {
            gameListToDisplay = nbaLeagueScheduleStore.filteredGames[nbaLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
        .onChange(of: nbaLeagueScheduleStore.baseSchedule.selectedDayIndex) {
            gameListToDisplay = nbaLeagueScheduleStore.filteredGames[nbaLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
        .onChange(of: nbaLeagueScheduleStore.filteredGames) {
            // TODO: Has to think about better structure, because 'gameListToDisplay' could be set multiple times.
            // Has to find if there are cases like here from other .onChange()
            gameListToDisplay = nbaLeagueScheduleStore.filteredGames[nbaLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
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
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let gameStatus = Int(data.gameStatus)
        let teamNameDic = nbaLeagueScheduleStore.teamNameDictionary
        
        let gameStatusText: String = {
            guard isResultOpened else { return StringConstants.resultOpen }

            switch gameStatus {
            case StringConstants.NBA.gameScheduled:
                return StringConstants.gameNotStartedStr
            case StringConstants.NBA.gameLive:
                return StringConstants.gameLiveStr
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
            case StringConstants.NBA.gameFinal:
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            if gameStatus == StringConstants.NBA.gameLive {
                return .moare
            } else {
                return .secondary
            }
        }()
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                homeTeamLogo: NBAUtil.teamLogoURL(id: homeTeamId),
                homeTeamName: teamNameDic["short_\(homeTeamId)"] ?? "",
                homeTeamScore: data.homeTeamScore,
                awayTeamLogo: NBAUtil.teamLogoURL(id: awayTeamId),
                awayTeamName: teamNameDic["short_\(awayTeamId)"] ?? "",
                awayTeamScore: data.awayTeamScore,
                isResultOpened: isResultOpened,
                gameStatusText: gameStatusText,
                gameStatusColor: gameStatusColor,
                isCapsuleButtonDisabled: gameStatus != StringConstants.NBA.gameFinal,
                date: data.date,
                venue: teamNameDic["venue_\(homeTeamId)"] ?? "",
                shouldShowOnlyDateTime: displayModel.scheduleType != ScheduleType.teamFlat, // (리그, 팀)일정 화면에서만 true
                isSvgLogo: true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    searchStore.send(.selectNBAGame(game: data, season: displayModel.season))
                    
                    // set selected game's isOpened true
                    nbaLeagueScheduleStore.send(.updateResultOpenedState(gameCode: data.gameId, isOpened: true))
                },
                onCapsuleButtonClick: {
                    nbaLeagueScheduleStore.send(.updateResultOpenedState(gameCode: data.gameId, isOpened: !isResultOpened))
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
