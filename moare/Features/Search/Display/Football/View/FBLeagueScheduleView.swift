//
//  Schedule.swift
//  SportSearchEngine_iOS
//
//  Created by MobulYoon on 10/2/24.
//

import SwiftUI
import ComposableArchitecture

struct FBLeaugScheduleView: View {
    /* ---------------------
       store
       --------------------- */
    @EnvironmentObject var storeManager: StoreManager
    @State var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>? = nil
    
    /* ---------------------
       data
       --------------------- */
    let displayModel: FBLeagueScheduleDisplayModel
    
    /* ---------------------
       ui state
       --------------------- */
    @State var shouldScrollCalendar = true
    
    var body: some View {
        if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
            VStack(spacing: 0) {
                if let fbLeagueScheduleStore = fbLeagueScheduleStore {
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
                       calendar
                       - hides when game selected
                       --------------------- */
                    if searchStore.fbGameStatsData == nil {
                        CalendarList(
                            dateList: fbLeagueScheduleStore.yearMonthList,
                            calendarType: .yearmonth,
                            selectedIndex: fbLeagueScheduleStore.selectedYearMonthIndex
                        ) { yearMonth, index in
                            shouldScrollCalendar = true
                            fbLeagueScheduleStore.send(.selectYearMonth(yearMonth: yearMonth, selectedIndex: index))
                        }
                        .padding(.bottom, 10)
                        
                        CalendarList(
                            dateList: fbLeagueScheduleStore.days,
                            calendarType: .day,
                            selectedIndex: fbLeagueScheduleStore.selectedDayIndex,
                            shouldScroll: $shouldScrollCalendar
                        ) { day, index in
                            shouldScrollCalendar = false
                            fbLeagueScheduleStore.send(.selectDay(day, index))
                        }
                        .padding(.bottom, 6)
                    }

                    /* ---------------------
                       all result open button
                       - hides when game selected
                       --------------------- */
                    if searchStore.fbGameStatsData == nil {
                        HStack {
                            Spacer()
                            
                            CapsuleButton(
                                text: fbLeagueScheduleStore.isAllResultOpened ? StringConstants.Football.resultHide : StringConstants.Football.resultOpen,
                                color: .secondary
                            ) {
                                fbLeagueScheduleStore.send(.toggleAllResult)
                            }
                            .padding(.trailing)
                        }
                    }
                    
                    /* ---------------------
                       schedule
                       --------------------- */
                    FBLeagueScheduleList(
                        searchStore: searchStore,
                        fbLeagueScheduleStore: fbLeagueScheduleStore
                    )
                } // if let fbLeagueScheduleStore
            } // VStack
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
                    fbLeagueScheduleStore.send(.initData(displayModel: displayModel))
                } else if case .fbGameStats = searchStore.poppedView {
                } else {
                    fbLeagueScheduleStore.send(.initData(displayModel: displayModel))                    
                }
            }
            .onChange(of: searchStore.viewStack) { newValue in
                guard let lastItem = newValue.last,
                      case .fbLeagueSchedule = lastItem,
                      let poppedView = searchStore.poppedView,
                      case .fbGameStats = searchStore.poppedView else {
                    return
                }
                
                fbLeagueScheduleStore?.send(.updateGamesData(fbLeagueScheduleData: lastItem, fbGameStatsData: poppedView))
            }
            .onChange(of: fbLeagueScheduleStore?.dataForViewStack) { newValue in
                if let data = newValue {
                    searchStore.send(.updateLastViewStack(data: data))
                }
            }
        } // if let searchStore
    }
}

struct FBLeagueScheduleList: View {
    @ComposableArchitecture.Bindable var searchStore: StoreOf<SearchStore>
    @ComposableArchitecture.Bindable var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>
    
    @State var gameListToDisplay: [FBGame] = []
    
    var body: some View {
        ScrollView {
//            HStack {
//                Spacer()
//            }
            
            LazyVStack(spacing: 8) {
                ForEach(gameListToDisplay, id: \.fixture.id) { value in
                    FBLeagueScheduleListItem(
                        searchStore: searchStore,
                        fbLeagueScheduleStore: fbLeagueScheduleStore,
                        data: value
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
        .frame(maxHeight: searchStore.fbGameStatsData == nil ? .infinity : fbLeagueScheduleStore.itemHeight)
        .scrollDisabled(searchStore.fbGameStatsData != nil)
        .onAppear {
            // TODO: init에서 해도 상관없다. 어디서 하는게 나을까?
            if let gameStats = searchStore.fbGameStatsData {
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    gameListToDisplay = [gameStats.game]
                }
            } else {
                gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.selectedDayIndex] ?? []
            }
        }
        .onChange(of: searchStore.fbGameStatsData) { newValue in
            if let game = newValue?.game {
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    gameListToDisplay = [game]
                }
            } else {
                gameListToDisplay = fbLeagueScheduleStore.filteredGames[fbLeagueScheduleStore.selectedDayIndex] ?? []
            }
        }
        .onChange(of: fbLeagueScheduleStore.selectedDayIndex) { newValue in
            gameListToDisplay = fbLeagueScheduleStore.filteredGames[newValue] ?? []
        }
    }
}

struct FBLeagueScheduleListItem: View {
    @ComposableArchitecture.Bindable var searchStore: StoreOf<SearchStore>
    @ComposableArchitecture.Bindable var fbLeagueScheduleStore: StoreOf<FBLeagueScheduleStore>
    
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
                VStack(spacing: 0) {
                    URLImage(url: data.teams.home.logo, size: .small)
                    
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: homeTeamKrName))
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .padding(.top, 2)
                    
                    if let _ = searchStore.fbGameStatsData {
                        RoundedBorderText(
                            text: "홈",
                            fontSize: 11,
                            textColor: .moare,
                            radius: 4,
                            strokeColor: .moare
                        )
                        .padding(.top, 2)
                    }
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
                    fbLeagueScheduleStore.send(.updateResultOpenedState(fixtureId: data.fixture.id, isOpened: !isResultOpened))
                }
                .disabled(searchStore.fbGameStatsData != nil || !StringConstants.Football.gameFinishedList.contains(data.fixture.status.short))
                
                // game date
                Text(CalendarUtil.formatDate(date: data.fixture.date, formatType: .ampm))
                    .font(.system(size: 12))
                    .padding(.vertical, 2)
                
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
                .lineLimit(1)
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
                VStack(spacing: 0) {
                    URLImage(url: data.teams.away.logo, size: .small)
                    
                    Text(EnNameTranslationUtility.translateByDic(type: .team, input: awayTeamKrname))
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .padding(.top, 2)
                    
                    if let _ = searchStore.fbGameStatsData {
                        RoundedBorderText(
                            text: "원정",
                            fontSize: 11,
                            textColor: .secondary,
                            radius: 4,
                            strokeColor: .secondary
                        )
                        .padding(.top, 2)
                    }
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
            fbLeagueScheduleStore.send(.updateResultOpenedState(fixtureId: data.fixture.id, isOpened: true))
        }
        .onAppear {
            if StringConstants.Football.gameFinishedList.contains(data.fixture.status.short) {
                isResultOpened = fbLeagueScheduleStore.gameResultOpenedStateList[data.fixture.id] ?? false
            } else {
                isResultOpened = true
            }
            
            translate()
        }
        .onChange(of: fbLeagueScheduleStore.gameResultOpenedStateList) { newValue in
            if StringConstants.Football.gameFinishedList.contains(data.fixture.status.short) {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = fbLeagueScheduleStore.gameResultOpenedStateList[data.fixture.id] ?? false
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
}
