//
//  MLBTeamScheduleView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/22/25.
//

import SwiftUI
import ComposableArchitecture

struct MLBTeamScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var mlbTeamScheduleStore: StoreOf<MLBTeamScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: MLBTeamScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let mlbTeamScheduleStore {
                    ScheduleViewContainer(
                        state: ScheduleContainerState(
                            shouldShowCalendar: false,
                            shouldFetchSchedule: false,
                            isAllResultOpened: mlbTeamScheduleStore.baseSchedule.isAllResultOpened
                        ),
                        actions: ScheduleContainerActions(
                            calendarUiActions: nil,
                            allResultButtonAction: {
                                mlbTeamScheduleStore.send(.toggleAllResult)
                            }
                        ),
                        titleContent: {},
                        gameListContent: {
                            MLBTeamScheduleList(
                                searchStore: searchStore,
                                mlbTeamScheduleStore: mlbTeamScheduleStore
                            )
                        }
                    )
                } // if let mlbTeamScheduleStore
            } // VStack
            .onAppear {
                // init MLBTeamScheduleStore
                let mlbTeamScheduleStore: StoreOf<MLBTeamScheduleStore> = storeManager.getStore(forKey: StoreKeys.mlbTeamScheduleStore) ?? {
                    let newStore = Store(initialState: MLBTeamScheduleStore.State()) { MLBTeamScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.mlbTeamScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.mlbTeamScheduleStore = mlbTeamScheduleStore
                }
                
                if searchStore.poppedView == nil {
                    mlbTeamScheduleStore.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .mlbTeamSchedule = searchStore.poppedView {
                    mlbTeamScheduleStore?.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

struct MLBTeamScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbTeamScheduleStore: StoreOf<MLBTeamScheduleStore>
    
    @State var gameListToDisplay: [MLBGameForSchedule] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay, id: \.gameId) { item in
                    MLBTeamScheduleListItem(
                        searchStore: searchStore,
                        mlbTeamScheduleStore: mlbTeamScheduleStore,
                        data: item
                    )
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            gameListToDisplay = mlbTeamScheduleStore.games
        }
    }
}

struct MLBTeamScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var mlbTeamScheduleStore: StoreOf<MLBTeamScheduleStore>
    
    let data: MLBGameForSchedule
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let gameStatus = data.gameStatus
        let teamNameDic = mlbTeamScheduleStore.baseSchedule.teamNameDictionary
        let mlbGameStatsModel = searchStore.displayModels[.mlbGameStats] as? MLBGameStatsDisplayModel
        
        let gameStatusText: String = {
            switch gameStatus {
            case StringConstants.MLB.gameScheduled:
                return StringConstants.gameNotStartedStr
            case StringConstants.MLB.gameLive:
                return StringConstants.gameLiveStr
            case StringConstants.MLB.gamePostponed:
                return StringConstants.gamePostponedStr
            case let status where StringConstants.MLB.gameFinishedList.contains(status):
                return isResultOpened ? StringConstants.gameFinishedStr : StringConstants.resultOpen
            default:
                return ""
            }
        }()
        
        let gameStatusColor: Color = {
            if gameStatus == StringConstants.MLB.gameLive {
                return .moare
            } else {
                return .secondary
            }
        }()
        
        ScheduleGameItem(
            state:ScheduleGameItemState(
                homeTeamLogo: MLBUtil.teamLogoURL(id: data.homeTeamId),
                homeTeamName: teamNameDic["short_\(homeTeamId)"] ?? "",
                homeTeamScore: data.homeTeamScore,
                awayTeamLogo: MLBUtil.teamLogoURL(id: data.awayTeamId),
                awayTeamName: teamNameDic["short_\(awayTeamId)"] ?? "",
                awayTeamScore: data.awayTeamScore,
                isResultOpened: isResultOpened,
                gameStatusText: gameStatusText,
                gameStatusColor: gameStatusColor,
                isCapsuleButtonDisabled: gameStatus != StringConstants.MLB.gameFinal,
                date: data.date,
                venue: teamNameDic["venue_\(homeTeamId)"] ?? "",
                shouldShowOnlyDateTime: false,
                shouldShowGameType: false,
                isSvgLogo: true
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
//                    searchStore.send(.selectMLBGame(game: data))
                    
                    // set selected game's isOpened true
                    mlbTeamScheduleStore.send(.updateResultOpenedState(gameId: data.gameId, isOpened: true))
                },
                onCapsuleButtonClick: {
                    mlbTeamScheduleStore.send(.updateResultOpenedState(gameId: data.gameId, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if StringConstants.MLB.gameFinishedList.contains(gameStatus) {
                isResultOpened = mlbTeamScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
            } else if gameStatus == StringConstants.MLB.gameScheduled || gameStatus == StringConstants.MLB.gamePostponed {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: mlbTeamScheduleStore.gameResultOpenedStateList) {
            if StringConstants.MLB.gameFinishedList.contains(gameStatus) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = mlbTeamScheduleStore.gameResultOpenedStateList[data.gameId] ?? false
                }
            }
        }
        .onChange(of: mlbGameStatsModel) {
            if let mlbGameStatsModel {
                isResultOpened = true
            }
        }
    }
}
