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
                if let fbTeamScheduleStore = fbTeamScheduleStore {
                    /* ---------------------
                       game title, info
                       - shows when game selected
                       --------------------- */
                    if let gameStatsData = searchStore.fbGameStatsData {
                        HStack {
                            HStack(spacing: 0) {
                                URLImage(url: gameStatsData.game.league.logo, customSize: CGSize(width: 23, height: 23))
                                    .padding(.trailing, 4)
                                
                                // TODO: make season text to use util
                                Text("\(gameStatsData.game.league.name) \(String(gameStatsData.game.league.season).suffix(2))/25")
                                    .font(.system(size: 14))
                            }
                            
                            Text(" - \(MatchDescriptionConverter.convert(descriptionType: .roundWithoutDash, input: gameStatsData.game.league.round))")
                                .font(.system(size: 14))
                            
                            Spacer()
                        }
                        .padding(.leading, UIConstants.Padding.defaultHPadding)
                    }
                    
                    /* ---------------------
                       all result open button
                       - hides when game selected
                       --------------------- */
                    if searchStore.fbGameStatsData == nil {
                        HStack {
                            Spacer()
                            
                            CapsuleButton(
                                text: fbTeamScheduleStore.isAllResultOpened ? StringConstants.Football.resultHide : StringConstants.Football.resultOpen,
                                color: .secondary
                            ) {
                                fbTeamScheduleStore.send(.toggleAllResult)
                            }
                            .padding(.trailing)
                        }
                    }
                    
                    
                    /* ---------------------
                       schedule
                       --------------------- */
                    FBTeamScheduleList(
                        searchStore: searchStore,
                        fbTeamScheduleStore: fbTeamScheduleStore
                    )
                } // if let fbTeamScheduleStore
            } // VStack
            .onAppear {
                // init FBLeagueScheduleStore
                let fbTeamScheduleStore: StoreOf<FBTeamScheduleStore> = storeManager.getStore(forKey: StoreKeys.fbTeamScheduleStore) ?? {
                    let newStore = Store(initialState: FBTeamScheduleStore.State(
                        displayModel: displayModel, games: displayModel.games
                    )) { FBTeamScheduleStore() }
                    
                    storeManager.setStore(newStore, forKey: StoreKeys.fbTeamScheduleStore)
                    
                    newStore.send(.initData)
                    
                    return newStore
                }()
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    self.fbTeamScheduleStore = fbTeamScheduleStore
                }
            }
        } // if let searchStore
    }
}

struct FBTeamScheduleList: View {
    @ComposableArchitecture.Bindable var searchStore: StoreOf<SearchStore>
    @ComposableArchitecture.Bindable var fbTeamScheduleStore: StoreOf<FBTeamScheduleStore>
    
    @State var gameListToDisplay: [FBGame] = []
    
    var body: some View {
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
        .frame(maxHeight: searchStore.fbGameStatsData == nil ? .infinity : fbTeamScheduleStore.itemHeight)
        .scrollDisabled(searchStore.fbGameStatsData != nil)
        .onAppear {
            // TODO: init에서 해도 상관없다. 어디서 하는게 나을까?
            if let gameStats = searchStore.fbGameStatsData {
                gameListToDisplay = [gameStats.game]
            } else {
                gameListToDisplay = fbTeamScheduleStore.games
            }
        }
        .onChange(of: searchStore.fbGameStatsData) { newValue in
            if let game = newValue?.game {
                gameListToDisplay = [game]
            } else {
                gameListToDisplay = fbTeamScheduleStore.games
            }
        }
    }
}

struct FBTeamScheduleListItem: View {
    @ComposableArchitecture.Bindable var searchStore: StoreOf<SearchStore>
    @ComposableArchitecture.Bindable var fbTeamScheduleStore: StoreOf<FBTeamScheduleStore>
    
    let data: FBGame
    
    /* ---------------------
       ui state
       --------------------- */
    @State private var isResultOpened = false
    @State private var homeTeamKrName = ""
    @State private var awayTeamKrname = ""
    @State private var venueKrName = ""
    @State private var refereeKrName = ""
    
    var body: some View {
        HStack {
            /* ---------------------
             home
             --------------------- */
            Button(action: {
//                searchStore.send(.updateTextField("토트넘"))
//                searchStore.send(.performSearch())
            }) {
                VStack {
                    URLImage(url: data.teams.home.logo, size: .small)
                    
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: homeTeamKrName))
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
            }
            .frame(width: 100)
            .foregroundStyle(.primary)
//            .disabled(searchStore.fbGameStatsData == nil)
            .disabled(true) // TODO: modify when api added
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            // score
            if StringConstants.Football.gameLiveList.contains(data.fixture.status.short) ||
                StringConstants.Football.gameFinishedList.contains(data.fixture.status.short) && isResultOpened {
                Text("\(data.goals.home)")
                    .frame(maxWidth: 20)
                    .foregroundStyle(data.goals.home >= data.goals.away ? .moare : .primary)
            }
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            /* ---------------------
             game info
             --------------------- */
            VStack {
                // game status
                CapsuleButton(
                    text: gameStatusText,
                    color: gameStatusColor
                ) {
                    fbTeamScheduleStore.send(.updateResultOpenedState(fixtureId: data.fixture.id, isOpened: !isResultOpened))
                }
                .disabled(searchStore.fbGameStatsData != nil || !StringConstants.Football.gameFinishedList.contains(data.fixture.status.short))
                
                // game date
                if let fbGameStatsData = searchStore.fbGameStatsData {
                    Text(CalendarUtil.formatDate(date: data.fixture.date, formatType: .ampm))
                        .font(.system(size: 12))
                        .padding(.vertical, 2)
                } else {
                    Text(formatDate())
                        .font(.system(size: 12))
                        .padding(.top, 2)
                    
                    Text(CalendarUtil.formatDate(date: data.fixture.date, formatType: .ampm))
                        .font(.system(size: 12))
                        .padding(.bottom, 2)
                }
                
                // venue
                if let fbGameStatsData = searchStore.fbGameStatsData {
                    Text("장소: \(venueKrName)")
                        .font(.system(size: 12, weight: .light))
                        .lineLimit(1)
                    .padding(.bottom, 2)
                }
                
                // game type or referee
                Text(
                    searchStore.fbGameStatsData != nil ?
                    "심판: \(refereeKrName)"
                    : MatchDescriptionConverter.convert(input: data.league.round)
                )
                .font(.system(size: 12, weight: .light))
            }
            .frame(width: 110)
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            /* ---------------------
             away
             --------------------- */
            // socre
            if StringConstants.Football.gameLiveList.contains(data.fixture.status.short) ||
                StringConstants.Football.gameFinishedList.contains(data.fixture.status.short) && isResultOpened {
                Text("\(data.goals.away)")
                    .frame(maxWidth: 20)
                    .foregroundStyle(data.goals.away >= data.goals.home ? .moare : .primary)
            }
            
            Spacer()
                .frame(maxHeight: 80)
                .contentShape(Rectangle())
            
            Button(action: {
//                searchStore.send(.updateTextField("토트넘"))
//                searchStore.send(.performSearch())
            }) {
                VStack {
                    URLImage(url: data.teams.away.logo, size: .small)
                    
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: awayTeamKrname))
                        .font(.system(size: 13))
                        .lineLimit(2)
                }
            }
            .frame(width: 100)
            .foregroundStyle(.primary)
//            .disabled(searchStore.fbGameStatsData == nil)
            .disabled(true) // TODO: modify when api added
        } // HStack
        .background(Color.clear) // added for tapGesture on Spacer()
        .onTapGesture {
            searchStore.send(.selectFBGame(data))
            
            // set selected game's isOpened true
            fbTeamScheduleStore.send(.updateResultOpenedState(fixtureId: data.fixture.id, isOpened: true))
        }
        .onAppear {
            if StringConstants.Football.gameFinishedList.contains(data.fixture.status.short) {
                isResultOpened = fbTeamScheduleStore.gameResultOpenedStateList[data.fixture.id] ?? false
            } else {
                isResultOpened = true
            }
            
            translate()
        }
        .onChange(of: fbTeamScheduleStore.gameResultOpenedStateList) { newValue in
            if StringConstants.Football.gameFinishedList.contains(data.fixture.status.short) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = fbTeamScheduleStore.gameResultOpenedStateList[data.fixture.id] ?? false
                }
            }
        }
        .onChange(of: searchStore.fbGameStatsData) { newValue in
            if let fbGameStatsData = newValue {
                isResultOpened = true
                
                Task {
                    let venueKrName = await EnNameTranslationUtility.translateByAWS(input: fbGameStatsData.game.fixture.venue.name)
                    self.venueKrName = venueKrName
                }
                
                Task {
                    let refereeKrName = await EnNameTranslationUtility.translateByAWS(input: fbGameStatsData.game.fixture.referee)
                    self.refereeKrName = refereeKrName
                }
            }
        }
        .onChange(of: data) { newValue in
            translate()
        }
    }
    
    private var gameStatusText: String {
        if isResultOpened {
            switch data.fixture.status.short {
            case StringConstants.Football.gameNotStarted: StringConstants.Football.gameNotStartedStr
            case StringConstants.Football.gameFirstHalf: StringConstants.Football.gameFirstHalfStr
            case StringConstants.Football.gameHalftime: StringConstants.Football.gameHalftimeStr
            case StringConstants.Football.gameSecondHalf: StringConstants.Football.gameSecondHalfStr
            case let status where StringConstants.Football.gameFinishedList.contains(status):
                StringConstants.Football.gameFinishedStr
            default: ""
            }
        } else {
            StringConstants.Football.resultOpen
        }
    }
    
    private var gameStatusColor: Color {
        if isResultOpened {
            switch data.fixture.status.short {
            case let status where StringConstants.Football.gameLiveList.contains(status): .moare
            default: .secondary
            }
        } else {
            .secondary
        }
    }
    
    private func translate() {
        Task {
            let homeTeamKrName = await EnNameTranslationUtility.translateByAWS(input: data.teams.home.name)
            self.homeTeamKrName = homeTeamKrName
        }
        
        Task {
            let awayTeamKrName = await EnNameTranslationUtility.translateByAWS(input: data.teams.away.name)
            self.awayTeamKrname = awayTeamKrName
        }
    }
    
    private func formatDate() -> String {
        let splitedDate = CalendarUtil.formatDate(date: data.fixture.date, formatType: .ampmWithDate).split(separator: " ")
        let dateStr = "\(splitedDate[0])"
        
        return dateStr
    }
}
