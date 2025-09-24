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
                            HStack {
                                HStack(spacing: 0) {
                                    URLImage(url: league.logo, customSize: CGSize(width: 23, height: 23))
                                        .padding(.trailing, 4)
                                    
                                    // TODO: make season text to use util
                                    Text("\(league.name) \(String(league.season).suffix(2))/25")
                                        .font(.system(size: 14))
                                }
                                
                                Text(" - \(MatchDescriptionConverter.convert(descriptionType: .roundWithoutDash, input: league.round))")
                                    .font(.system(size: 14))
                                
                                Spacer()
                            }
                            .padding(.leading, UIConstants.Padding.defaultHPadding)
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
    
//    @State var gameListToDisplay: [FBGameForSchedule] = []
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
//        .onAppear {
            // TODO: init에서 해도 상관없다. 어디서 하는게 나을까?
//            if let game = fbGameStatsModel?.game {
//                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
//                    gameListToDisplay = [ModelConverter.fbGameToGameScheduleConverter(game: game)]
//                }
//            } else {
//                gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
//            }
//        }
//        .onChange(of: fbGameStatsModel) {
//            if let game = fbGameStatsModel?.game {
//                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
//                    gameListToDisplay = [ModelConverter.fbGameToGameScheduleConverter(game: game)]
//                }
//            } else {
//                gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
//            }
//        }
//        .onChange(of: fbLeagueScheduleStore.baseSchedule.selectedDayIndex) {
//            gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
//        }
//        .onChange(of: fbLeagueScheduleStore.filteredGames) {
            // TODO: Has to think about better structure, because 'gameListToDisplay' could be set multiple times.
            // Has to find if there are cases like here from other .onChange()
//            gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
//        }
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
        let fbGameStatsModel = searchStore.displayModels[.fbGameStats] as? FBGameStatsDisplayModel
        
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
                isClickEnabled: fbGameStatsModel == nil,
                homeTeamLogo: FBUtil.teamLogoURL(id: homeTeamId),
                homeTeamName: teamNameDic["short_\(homeTeamId)"] ?? "",
                homeTeamScore: data.homeTeamScore,
                awayTeamLogo: FBUtil.teamLogoURL(id: awayTeamId),
                awayTeamName: teamNameDic["short_\(awayTeamId)"] ?? "",
                awayTeamScore: data.awayTeamScore,
                isResultOpened: isResultOpened,
                gameStatusText: gameStatusText,
                gameStatusColor: gameStatusColor,
                isCapsuleButtonDisabled: fbGameStatsModel != nil || !StringConstants.Football.gameFinishedList.contains(gameStatus),
                date: data.date,
                venue: teamNameDic["venue_\(homeTeamId)"] ?? "",
                gameType: MatchDescriptionConverter.convert(input: data.gameInfo?.round ?? ""),
                referee: fbGameStatsModel?.game.fixture.referee,
                shouldShowOnlyDateTime: fbGameStatsModel == nil,
                shouldShowGameType: fbGameStatsModel == nil,
                shouldShowHomeLabel: fbGameStatsModel != nil,
                shouldShowAwayLabel: fbGameStatsModel != nil,
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    if let fbLeagueScheduleStore {
                        let displayModel = fbLeagueScheduleStore.baseSchedule.displayModel
                        searchStore.send(.selectFBGame(game: data, season: displayModel.season, leagueId: displayModel.leagueId))
                        
                        fbLeagueScheduleStore.send(.selectGame(game: data))
                        // set selected game's isOpened true
//                        fbLeagueScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: true))
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
        .onChange(of: fbGameStatsModel) {
            if fbGameStatsModel != nil {
                if gameStatus != StringConstants.Football.gameNotStarted {
                    isResultOpened = true
                }
            }
        }
        .onChange(of: fbLeagueScheduleStore?.gameResultOpenedStateList) {
            if let fbLeagueScheduleStore, StringConstants.Football.gameFinishedList.contains(gameStatus) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = fbLeagueScheduleStore.gameResultOpenedStateList[gameId] ?? false
                }
            }
        }
//        .onChange(of: fbGameStatsModel) {
//            if fbGameStatsModel != nil {
//                if gameStatus != StringConstants.Football.gameNotStarted {
//                    isResultOpened = true
//                }
//            }
//        }
    }
}
