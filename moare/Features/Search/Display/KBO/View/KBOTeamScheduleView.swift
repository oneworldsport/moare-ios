//
//  KBOTeamScheduleView.swift
//  moare
//
//  Created by Mohwa Yoon on 6/22/25.
//

import SwiftUI
import ComposableArchitecture

struct KBOTeamScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var kboTeamScheduleStore: StoreOf<KBOTeamScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: KBOTeamScheduleDisplayModel
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let kboTeamScheduleStore {
                    ScheduleViewContainer(
                        state: ScheduleContainerState(
                            shouldShowCalendar: false,
                            shouldFetchSchedule: false,
                            isAllResultOpened: kboTeamScheduleStore.baseSchedule.isAllResultOpened
                        ),
                        actions: ScheduleContainerActions(
                            calendarUiActions: nil,
                            allResultButtonAction: {
                                kboTeamScheduleStore.send(.toggleAllResult)
                            }
                        ),
                        titleContent: {},
                        gameListContent: {
                            KBOTeamScheduleList(
                                searchStore: searchStore,
                                kboTeamScheduleStore: kboTeamScheduleStore
                            )
                        }
                    )
                } // if let kboTeamScheduleStore
            } // VStack
            .onAppear {
                // init KBOTeamScheduleStore
                let kboTeamScheduleStore: StoreOf<KBOTeamScheduleStore> = storeManager.getStore(forKey: StoreKeys.kboTeamScheduleStore) ?? {
                    let newStore = Store(initialState: KBOTeamScheduleStore.State()) { KBOTeamScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.kboTeamScheduleStore)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.kboTeamScheduleStore = kboTeamScheduleStore
                }
                
                if searchStore.poppedView == nil {
                    kboTeamScheduleStore.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
            .onChange(of: displayModel) {
                if case .kboTeamSchedule = searchStore.poppedView {
                    kboTeamScheduleStore?.send(.baseSchedule(.initData(displayModel: displayModel)))
                }
            }
        } // if let searchStore
    }
}

struct KBOTeamScheduleList: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboTeamScheduleStore: StoreOf<KBOTeamScheduleStore>
    
    @State var gameListToDisplay: [KBOGameForSchedule] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay, id: \.itemKey) { item in
                    KBOTeamScheduleListItem(
                        searchStore: searchStore,
                        kboTeamScheduleStore: kboTeamScheduleStore,
                        data: item
                    )
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            gameListToDisplay = kboTeamScheduleStore.games
        }
    }
}

struct KBOTeamScheduleListItem: View {
    @Bindable var searchStore: StoreOf<SearchStore>
    @Bindable var kboTeamScheduleStore: StoreOf<KBOTeamScheduleStore>
    
    let data: KBOGameForSchedule
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    
    var body: some View {
        let homeTeamId = data.homeTeamId
        let awayTeamId = data.awayTeamId
        let gameStatus = Int(data.gameStatus)
        let teamNameDic = kboTeamScheduleStore.baseSchedule.teamNameDictionary
        let kboGameStatsModel = searchStore.displayModels[.kboGameStats] as? KBOGameStatsDisplayModel
        
        let gameStatusText: String = {
            switch gameStatus {
            case StringConstants.KBO.gameScheduled:
                return StringConstants.gameNotStartedStr
            case StringConstants.KBO.gameLive:
                return StringConstants.gameLiveStr
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
                homeTeamLogo: KBOUtil.teamLogoURL(id: data.homeTeamId),
                homeTeamName: teamNameDic["short_\(homeTeamId)"] ?? "",
                homeTeamScore: data.homeTeamScore,
                awayTeamLogo: KBOUtil.teamLogoURL(id: data.awayTeamId),
                awayTeamName: teamNameDic["short_\(awayTeamId)"] ?? "",
                awayTeamScore: data.awayTeamScore,
                isResultOpened: isResultOpened,
                gameStatusText: gameStatusText,
                gameStatusColor: gameStatusColor,
                isCapsuleButtonDisabled: gameStatus != StringConstants.KBO.gameFinal,
                date: data.date,
                venue: teamNameDic["venue_\(homeTeamId)"] ?? "",
                shouldShowOnlyDateTime: false,
                shouldShowGameType: false
            ),
            actions: ScheduleGameItemActions(
                onGameItemClick: {
                    searchStore.send(.selectKBOGame(game: data))
                    
                    // set selected game's isOpened true
                    kboTeamScheduleStore.send(.updateResultOpenedState(itemKey: data.itemKey, isOpened: true))
                },
                onCapsuleButtonClick: {
                    kboTeamScheduleStore.send(.updateResultOpenedState(itemKey: data.itemKey, isOpened: !isResultOpened))
                }
            )
        )
        .onAppear {
            if gameStatus == StringConstants.KBO.gameFinal {
                isResultOpened = kboTeamScheduleStore.gameResultOpenedStateList[data.itemKey] ?? false
            } else if gameStatus == StringConstants.KBO.gameScheduled || gameStatus == StringConstants.KBO.gameCanceled {
                isResultOpened = false
            } else {
                isResultOpened = true
            }
        }
        .onChange(of: kboTeamScheduleStore.gameResultOpenedStateList) {
            if gameStatus == StringConstants.KBO.gameFinal {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = kboTeamScheduleStore.gameResultOpenedStateList[data.itemKey] ?? false
                }
            }
        }
        .onChange(of: kboGameStatsModel) {
            if let kboGameStatsModel {
                isResultOpened = true
            }
        }
    }
}
