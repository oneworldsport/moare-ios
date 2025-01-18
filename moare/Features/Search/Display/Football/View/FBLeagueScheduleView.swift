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
                            
                            Text(" - \(MatchDescriptionConverter.convert(input: gameStatsData.game.league.round))")
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
                            fbLeagueScheduleStore.send(.selectYearMonth(yearMonth, index))
                        }
                        .padding(.bottom, 10)
                        
                        CalendarList(
                            dateList: fbLeagueScheduleStore.days,
                            calendarType: .day,
                            selectedIndex: fbLeagueScheduleStore.selectedDayIndex,
                            shouldScroll: $shouldScrollCalendar
                        ) { day, index in
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
                storeManager.setStore(
                    Store(initialState: FBLeagueScheduleStore.State(
                        displayModel: displayModel, yearMonthList: displayModel.yearMonthList
                    )) { FBLeagueScheduleStore() },
                    forKey: StoreKeys.fbLeagueScheduleStore
                )
                
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    fbLeagueScheduleStore = storeManager.getStore(forKey: StoreKeys.fbLeagueScheduleStore)
                }
                
                fbLeagueScheduleStore?.send(.initData)
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
                ForEach(gameListToDisplay.indices, id: \.self) { index in
                    FBLeagueScheduleListItem(
                        searchStore: searchStore,
                        fbLeagueScheduleStore: fbLeagueScheduleStore,
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
            if isResultOpened && data.fixture.status.short == "FT" {
                Text("\(data.goals.home)")
                    .frame(maxWidth: 20)
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
                    withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                        isResultOpened.toggle()
                    }
                }
                .disabled(searchStore.fbGameStatsData != nil || data.fixture.status.short != "FT")
                
                // game date
                Text(CalendarUtil.formatDate(date: data.fixture.date, formatType: .ampm))
                    .font(.system(size: 12))
                    .padding(.vertical, 2)
                
                // venue
                if let fbGameStatsData = searchStore.fbGameStatsData {
                    Text("장소: \(fbGameStatsData.game.fixture.venue.name)")
                        .font(.system(size: 12, weight: .light))
                        .lineLimit(1)
                    .padding(.bottom, 2)
                }
                
                // game type or referee
                Text(
                    searchStore.fbGameStatsData != nil ?
                    "심판: \(searchStore.fbGameStatsData!.game.fixture.referee)"
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
            if isResultOpened && data.fixture.status.short == "FT" {
                Text("\(data.goals.away)")
                    .frame(maxWidth: 20)
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
        }
        .onAppear {
            if data.fixture.status.short == "FT" {
                isResultOpened = fbLeagueScheduleStore.isAllResultOpened
            } else {
                isResultOpened = true
            }
            
            translate()
        }
        .onChange(of: fbLeagueScheduleStore.isAllResultOpened) { newValue in
            if data.fixture.status.short == "FT" {
                withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                    isResultOpened = fbLeagueScheduleStore.isAllResultOpened
                }
            }
        }
        .onChange(of: searchStore.fbGameStatsData) { newValue in
            if let _ = newValue {
                isResultOpened = true
            }
        }
        .onChange(of: data) { newValue in
            translate()
        }
    }
    
    private var gameStatusText: String {
        if isResultOpened {
            switch data.fixture.status.short {
            case "NS": StringConstants.Football.gameNotStarted
            case "1H": StringConstants.Football.gameFirstHalf
            case "HT": StringConstants.Football.gameHalftime
            case "2H": StringConstants.Football.gameSecondHalf
            case "FT", "AET", "PEN": StringConstants.Football.gameFinished
            default: ""
            }
        } else {
            StringConstants.Football.resultOpen
        }
    }
    
    private var gameStatusColor: Color {
        if isResultOpened {
            switch data.fixture.status.short {
            case "1H", "HT", "2H": .moare
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
