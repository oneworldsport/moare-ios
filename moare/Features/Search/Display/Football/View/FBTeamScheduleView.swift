//
//  FBTeamScheduleView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/15/25.
//

import SwiftUI
import ComposableArchitecture

struct FBTeamScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbTeamScheduleStore: StoreOf<FBTeamScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBTeamScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let fbTeamScheduleStore {
                    let fbGameStatsModel = searchStore.displayModels[.fbGameStats] as? FBGameStatsDisplayModel
                    
                    ScheduleViewContainer(
                        state: ScheduleContainerState(
                            shouldShowCalendar: false,
                            shouldShowAllResultToggleButton: fbGameStatsModel == nil,
                            shouldFetchSchedule: false,
                            isAllResultOpened: fbTeamScheduleStore.baseSchedule.isAllResultOpened
                        ),
                        actions: ScheduleContainerActions(
                            calendarUiActions: nil,
                            allResultButtonAction: {
                                fbTeamScheduleStore.send(.toggleAllResult)
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
                            FBTeamScheduleList(
                                searchStore: searchStore,
                                fbTeamScheduleStore: fbTeamScheduleStore
                            )
                        }
                    )
                } // if let fbTeamScheduleStore
            } // VStack
            .onAppear {
                // init FBTeamScheduleStore
                let fbTeamScheduleStore: StoreOf<FBTeamScheduleStore> = storeManager.getStore(forKey: StoreKeys.fbTeamScheduleStore) ?? {
                    let newStore = Store(initialState: FBTeamScheduleStore.State()) { FBTeamScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTeamScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbTeamScheduleStore = fbTeamScheduleStore
                }
                
                if searchStore.poppedView == nil {
                    fbTeamScheduleStore.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .fbTeamSchedule = searchStore.poppedView {
                    fbTeamScheduleStore?.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

struct FBTeamScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbTeamScheduleStore: StoreOf<FBTeamScheduleStore>
    
    @State var gameListToDisplay: [FBGameForSchedule] = []
    
    var body: some View {
        let fbGameStatsModel = searchStore.displayModels[.fbGameStats] as? FBGameStatsDisplayModel
        
        ScrollView {
//            HStack {
//                Spacer()
//            }
            
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay.indices, id: \.self) { index in
                    FBTeamScheduleListItem(
                        searchStore: searchStore,
                        fbTeamScheduleStore: fbTeamScheduleStore,
                        data: gameListToDisplay[index]
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
        .frame(maxHeight: fbGameStatsModel == nil ? .infinity : fbTeamScheduleStore.itemHeight)
        .scrollDisabled(fbGameStatsModel != nil)
        .onAppear {
            // TODO: init에서 해도 상관없다. 어디서 하는게 나을까?
            if let game = fbGameStatsModel?.game {
                gameListToDisplay = [ModelConverter.fbGameToGameScheduleConverter(game: game)]
            } else {
                gameListToDisplay = fbTeamScheduleStore.games
            }
        }
        .onChange(of: fbGameStatsModel) {
            if let game = fbGameStatsModel?.game {
                gameListToDisplay = [ModelConverter.fbGameToGameScheduleConverter(game: game)]
            } else {
                gameListToDisplay = fbTeamScheduleStore.games
            }
        }
    }
}

struct FBTeamScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var fbTeamScheduleStore: StoreOf<FBTeamScheduleStore>
    
    let data: FBGameForSchedule
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let gameId = data.gameId
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let gameStatus = data.gameStatus
        let teamNameDic = fbTeamScheduleStore.baseSchedule.teamNameDictionary
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
                shouldShowOnlyDateTime: false,
                shouldShowVenue: fbGameStatsModel != nil,
                shouldShowGameType: fbGameStatsModel == nil,
                shouldShowReferee: fbGameStatsModel != nil,
                shouldShowHomeLabel: fbGameStatsModel != nil,
                shouldShowAwayLabel: fbGameStatsModel != nil,
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    searchStore.send(.selectFBGame(game: data, leagueId: fbTeamScheduleStore.baseSchedule.displayModel?.leagueId))
                    
                    // set selected game's isOpened true
                    fbTeamScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: true))
                },
                onCapsuleButtonClick: {
                    fbTeamScheduleStore.send(.updateResultOpenedState(gameId: gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if StringConstants.Football.gameFinishedList.contains(gameStatus) {
                isResultOpened = fbTeamScheduleStore.gameResultOpenedStateList[gameId] ?? false
            } else if gameStatus == StringConstants.Football.gameNotStarted {
                isResultOpened = true
            }
        }
        .onChange(of: fbTeamScheduleStore.gameResultOpenedStateList) {
            if StringConstants.Football.gameFinishedList.contains(gameStatus) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = fbTeamScheduleStore.gameResultOpenedStateList[gameId] ?? false
                }
            }
        }
        .onChange(of: fbGameStatsModel) {
            if fbGameStatsModel != nil {
                isResultOpened = true
            }
        }
    }
}
