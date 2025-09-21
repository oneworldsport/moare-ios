//
//  Schedule.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import SwiftUI
import ComposableArchitecture

struct FBLeaugeScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBLeagueScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            let fbGameStatsModel = searchStore.displayModels[.fbGameStats] as? FBGameStatsDisplayModel
            
            VStack(spacing: 0) {
                if let fbLeagueScheduleStore {
                    ScheduleViewContainer(
                        state: ScheduleContainerState(
                            shouldShowCalendar: fbGameStatsModel == nil,
                            shouldShowAllResultToggleButton: fbGameStatsModel == nil,
                            displayDataState: fbLeagueScheduleStore.baseSchedule.displayDataState,
                            calendarUiState: CalendarUiState(
                                yearMonthList: fbLeagueScheduleStore.baseSchedule.yearMonthList,
                                days: fbLeagueScheduleStore.baseSchedule.days,
                                selectedYearMonthIndex: fbLeagueScheduleStore.baseSchedule.selectedYearMonthIndex,
                                selectedDayIndex: fbLeagueScheduleStore.baseSchedule.selectedDayIndex
                            ),
                            isAllResultOpened: fbLeagueScheduleStore.baseSchedule.isAllResultOpened
                        ),
                        actions: ScheduleContainerActions(
                            calendarUiActions: CalendarUiActions(
                                onSelectYearMonth: { yearMonth, index in
                                    fbLeagueScheduleStore.send(.selectYearMonth(yearMonth: yearMonth, selectedIndex: index))
                                },
                                onSelectDay: { day, index in
                                    fbLeagueScheduleStore.send(.baseSchedule(.selectDay(day, index)))
                                }
                            ),
                            allResultButtonAction: {
                                fbLeagueScheduleStore.send(.toggleAllResult)
                            }
                        ),
                        titleContent: {
                            if let fbGameStatsModel {
                                HStack {
                                    HStack(spacing: 0) {
                                        URLImage(url: fbGameStatsModel.game.league.logo, customSize: CGSize(width: 23, height: 23))
                                            .padding(.trailing, 4)
                                        
                                        // TODO: make season text to use util
                                        Text("\(fbGameStatsModel.game.league.name) \(String(fbGameStatsModel.game.league.season).suffix(2))/25")
                                            .font(.system(size: 14))
                                    }
                                    
                                    Text(" - \(MatchDescriptionConverter.convert(descriptionType: .roundWithoutDash, input: fbGameStatsModel.game.league.round))")
                                        .font(.system(size: 14))
                                    
                                    Spacer()
                                }
                                .padding(.leading, UIConstants.Padding.defaultHPadding)
                            }
                        },
                        gameListContent: {
                            FBLeagueScheduleList(
                                searchStore: searchStore,
                                fbLeagueScheduleStore: fbLeagueScheduleStore
                            )
                        }
                    )
                }
            }
            .onAppear {
                // init FBLeagueScheduleStore
                let fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore> = storeManager.getStore(forKey: StoreKeys.fbLeagueScheduleStore) ?? {
                    let newStore = Store(initialState: FBLeagueScheduleStore.State()) { FBLeagueScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbLeagueScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbLeagueScheduleStore = fbLeagueScheduleStore
                }
                
                if searchStore.poppedView == nil {
                    fbLeagueScheduleStore.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .fbLeagueSchedule = searchStore.poppedView {
                    fbLeagueScheduleStore?.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: searchStore.viewStack) {
                guard let lastItem = searchStore.viewStack.last,
                      case .fbLeagueSchedule = lastItem,
                      let poppedView = searchStore.poppedView,
                      case .fbGameStats = searchStore.poppedView else {
                    return
                }
                
                fbLeagueScheduleStore?.send(.updateGamesData(fbLeagueScheduleData: lastItem, fbGameStatsData: poppedView))
            }
            .onChange(of: fbLeagueScheduleStore?.dataForViewStack) {
                if let data = fbLeagueScheduleStore?.dataForViewStack {
                    searchStore.send(.updateLastViewStack(data: data))
                }
            }
        } // if let searchStore
    }
}

struct FBLeagueScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>
    
    @State var gameListToDisplay: [FBGameForSchedule] = []
    
    var body: some View {
        let fbGameStatsModel = searchStore.displayModels[.fbGameStats] as? FBGameStatsDisplayModel
        let teamNameDic = fbLeagueScheduleStore.baseSchedule.teamNameDictionary
        
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
        .frame(maxHeight: fbGameStatsModel == nil ? .infinity : fbLeagueScheduleStore.itemHeight)
        .scrollDisabled(fbGameStatsModel != nil)
        .onAppear {
            // TODO: init에서 해도 상관없다. 어디서 하는게 나을까?
            if let game = fbGameStatsModel?.game {
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    gameListToDisplay = [ModelConverter.fbGameToGameScheduleConverter(game: game)]
                }
            } else {
                gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
            }
        }
        .onChange(of: fbGameStatsModel) {
            if let game = fbGameStatsModel?.game {
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    gameListToDisplay = [ModelConverter.fbGameToGameScheduleConverter(game: game)]
                }
            } else {
                gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
            }
        }
        .onChange(of: fbLeagueScheduleStore.baseSchedule.selectedDayIndex) {
            gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
        .onChange(of: fbLeagueScheduleStore.filteredGames) {
            // TODO: Has to think about better structure, because 'gameListToDisplay' could be set multiple times.
            // Has to find if there are cases like here from other .onChange()
            gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.baseSchedule.selectedDayIndex] ?? []
        }
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
                shouldShowVenue: fbGameStatsModel != nil,
                shouldShowGameType: fbGameStatsModel == nil,
                shouldShowHomeLabel: fbGameStatsModel != nil,
                shouldShowAwayLabel: fbGameStatsModel != nil,
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    if let fbLeagueScheduleStore {
                        if let displayModel = fbLeagueScheduleStore.baseSchedule.displayModel {
                            searchStore.send(.selectFBGame(game: data, season: displayModel.season, leagueId: displayModel.leagueId))
                        }
                        
                        // set selected game's isOpened true
                        fbLeagueScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: true))
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
