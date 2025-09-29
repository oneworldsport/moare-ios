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
        VStack {
            if show {
                ScheduleViewContainer(
                    state: ScheduleContainerState(
                        shouldShowCalendar: store.selectedGame == nil,
                        shouldShowAllResultToggleButton: store.selectedGame == nil,
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
    
    var body: some View {
        let gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        let isCollapsed = fbLeagueScheduleStore.selectedGame != nil && gameListToDisplay.count == 1
        let teamNameDic = fbLeagueScheduleStore.baseSchedule.teamNameDictionary
        let singleId = gameListToDisplay.first?.gameId
        
        ScrollView {
//            HStack {
//                Spacer()
//            }
            
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay, id: \.gameId) { value in
                    FBLeagueScheduleListItem(
                        searchStore: searchStore,
                        fbLeagueScheduleStore: fbLeagueScheduleStore,
                        data: value,
                        teamNameDic: teamNameDic
                    )
                    .padding(.vertical, 8)
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
//                    .vSequentialListAni(
//                        index: index,
//                        itemCount: gameListToDisplay.count,
//                        itemHeight: 53,
//                        aniDelay: 0.1,
//                        aniDuration: 0.5
//                    )
                }
            }
        }
        .frame(height: isCollapsed ? itemHeight : nil)
        .scrollDisabled(isCollapsed)
    }
}

struct FBLeagueScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    // STUDY: @Bindable을 써야할때가 따로 있음. 더 알아보고 제대로 사용해야 할듯..
//    @Bindable var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>
    let fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>?
    
    let data: FBGameForSchedule
    // FBLeagueScheduleStore이 한번도 초기화 된적 없이 FBGameStatsView에서 해당 구조체가 호출될때 teamNameDictionary를 fbLeagueScheduleStore에서 가져올수가 없어 추가.
    // TODO: 그러면 결국 fbLeagueScheduleStore는 Optional이어도 된다는건데..?
    let teamNameDic: [String: String]
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let gameId = data.gameId
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let gameStatus = data.gameStatus
        // FBLeagueScheduleView가 아닌 FBPlayerInfoView나 FBTeamInfoView 등에서 보여질때 사용되는 flag
        let isFromSchedule = fbLeagueScheduleStore != nil
        
        let gameStatusText: String = {
            switch gameStatus {
            case StringConstants.Football.gameNotStarted:
                return StringConstants.gameNotStartedStr
            case StringConstants.Football.gameFirstHalf:
                return StringConstants.Football.gameFirstHalfStr
            case StringConstants.Football.gameHalftime:
                return StringConstants.Football.gameHalftimeStr
            case StringConstants.Football.gameSecondHalf:
                return StringConstants.Football.gameSecondHalfStr
            case let status where StringConstants.Football.gameFinishedList.contains(status):
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            switch gameStatus {
            case let status where StringConstants.Football.gameLiveList.contains(status):
                return .moare
            default:
                return .secondary
            }
        }()
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                leagueId: Constants.Ids.epl, // TODO: 임시
                isClickEnabled: isFromSchedule ? fbLeagueScheduleStore?.selectedGame == nil : false,
                homeTeamLogo: FBUtil.teamLogoURL(id: homeTeamId),
                homeTeamName: teamNameDic["short_\(homeTeamId)"] ?? "",
                homeTeamScore: data.homeTeamScore,
                awayTeamLogo: FBUtil.teamLogoURL(id: awayTeamId),
                awayTeamName: teamNameDic["short_\(awayTeamId)"] ?? "",
                awayTeamScore: data.awayTeamScore,
                isResultOpened: isResultOpened,
                gameStatusText: gameStatusText,
                gameStatusColor: gameStatusColor,
                isCapsuleButtonDisabled: (isFromSchedule ? fbLeagueScheduleStore?.selectedGame != nil : true) || !StringConstants.Football.gameFinishedList.contains(gameStatus),
                date: data.date,
                gameType: MatchDescriptionConverter.convert(input: data.gameInfo?.round ?? ""),
                shouldShowOnlyDateTime: isFromSchedule ? fbLeagueScheduleStore?.selectedGame == nil : false,
                shouldShowGameType: isFromSchedule ? fbLeagueScheduleStore?.selectedGame == nil : false,
                shouldShowHomeLabel: isFromSchedule ? fbLeagueScheduleStore?.selectedGame != nil : true,
                shouldShowAwayLabel: isFromSchedule ? fbLeagueScheduleStore?.selectedGame != nil : true,
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    if let fbLeagueScheduleStore {
                        let displayModel = fbLeagueScheduleStore.baseSchedule.displayModel
                        searchStore.send(.selectFBGame(game: data, season: displayModel.season, leagueId: displayModel.leagueId))
                        
                        fbLeagueScheduleStore.send(.selectGame(game: data))
                    }
                },
                onCapsuleButtonClick: {
                    if let fbLeagueScheduleStore {
                        fbLeagueScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: !isResultOpened))
                    }
                }
            )
        )
        .onAppear {
            if StringConstants.Football.gameFinishedList.contains(gameStatus) {
                if let fbLeagueScheduleStore {
                    isResultOpened = fbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
                }
            } else if gameStatus == StringConstants.Football.gameNotStarted {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: fbLeagueScheduleStore?.gameResultOpenedStateList) {
            if let fbLeagueScheduleStore, StringConstants.Football.gameFinishedList.contains(gameStatus) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = fbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
                }
            }
        }
    }
}
