//
//  FBPlayerStatsView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import SwiftUI
import ComposableArchitecture

struct FBPlayerStatsView: View {
    let searchStore: StoreOf<SearchStore>
    let store: StoreOf<FBPlayerStatsStore>
    
    var startOffset = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    @State private var show = false
    
    var body: some View {
        ScrollView {
            InfoViewContainer(
                itemCount: store.baseStats.displayModel.stats.count + 1,
                shouldShowMeasureContent: true,
                measureContent: { scope in
                    // NOTE: if let fbPlayerStatsStore {} 를 InfoViewContainer 바깥에서 선언하는 것보다 안에서 선언하는게 초기 에니메이션이 더 자연스러움.
                    if show {
                        FBPlayerStatsPlayerInfoItem(fbPlayerStatsStore: store)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        scope.updateItemFrame(index: 0, geometry: geometry)
                                    }
                                    Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                                        scope.updateItemFrame(index: 0, geometry: geometry)
                                    }
                                }
                            )
                        
                        FBPlayerStatsList(fbPlayerStatsStore: store, scope: scope)
                    }
                }, displayContent: { scope in
                    if show {
                        // player info
                        FBPlayerStatsPlayerInfoItem(
                            fbPlayerStatsStore: store,
                            isAniItem: true,
                            //                            itemSize: scope.itemSizes[0],
                            itemOffset: scope.computedOffset(for: 0, startOffset: startOffset),
                            showContents: scope.showContents
                        )
                        
                        // stats list
                        FBPlayerStatsList(
                            fbPlayerStatsStore: store,
                            isAniItem: true,
                            scope: scope
                        )
                    }
                }
            )
        } // ScrollView
        .onAppear {
            store.send(.baseStats(.initData))
            
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                show = true
            }
        }
    }
}

struct FBPlayerStatsPlayerInfoItem: View {
    @Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let isAniItem: Bool
    let itemOffset: CGSize?
    let showContents: Bool

    init(
        fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>,
        isAniItem: Bool = false,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.isAniItem = isAniItem
        self.itemOffset = itemOffset
        self.showContents = showContents
    }
    
    var body: some View {
        let playerNameDic = fbPlayerStatsStore.baseStats.playerNameDictionary
        let teamNameDic = fbPlayerStatsStore.baseStats.teamNameDictionary
        let player = fbPlayerStatsStore.baseStats.displayModel.player
        
        MovingCapsuleItemContainer(
            isAniItem: isAniItem,
            itemOffset: itemOffset
        ) {
            HStack {
                URLImage(url: player.photo)
                
                VStack(alignment: .leading) {
                    Text(playerNameDic["\(player.id)"] ?? (player.name))
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    
                    Text("\(player.name)")
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .lineLimit(2)
                }
                
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("국적: ")
                            .font(.system(size: 15))
                            
                        Text(player.nationality)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                    }
                    
                    if let team = fbPlayerStatsStore.baseStats.displayModel.team {
                        HStack(spacing: 0) {
                            Text("소속팀: ")
                                .font(.system(size: 15))
                            
                            URLImage(url: team.logo, customSize: CGSize(width: 24, height: 24))
                                .padding(.trailing, 6)
                            
                            Text(teamNameDic["full_\(team.id)"] ?? team.name)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
    }
}

struct FBPlayerStatsList: View {
    @Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let isAniItem: Bool
    let scope: InfoViewScope
    
    var startOffset = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    
    init(
        fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>,
        isAniItem: Bool = false,
        scope: InfoViewScope,
    ) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.isAniItem = isAniItem
        self.scope = scope
    }
    
    var body: some View {
        ForEach(fbPlayerStatsStore.statsList.indices, id: \.self) { index in
            let stats = fbPlayerStatsStore.statsList[index]
            let itemIndex = index + 1
            
            FBPlayerStatsListItem(
                fbPlayerStatsStore: fbPlayerStatsStore,
                stats: stats,
                isAniItem: isAniItem,
                itemSize: scope.itemSizes[itemIndex],
                itemOffset: scope.computedOffset(for: itemIndex, startOffset: startOffset),
                showContents: scope.showContents
            )
            .background(
                GeometryReader { geometry in
                    if !isAniItem {
                        // 1) 최초 한 번은 무조건 측정 - gpt
                        // NOTE: Color.clear.onChange()만 했을때는 update가 안돼서 Color.clear.onAppear 추가해줌
                        Color.clear.onAppear {
                            scope.updateItemFrame(index: itemIndex, geometry: geometry)
                        }
                        // 2) 위치 변하면 - gpt
                        Color.clear.onChange(of: geometry.frame(in: .named(scope.coordinateSpaceName)).origin) {
                            scope.updateItemFrame(index: itemIndex, geometry: geometry)
                        }
                        // 3) 사이즈 변하면 - gpt
//                        Color.clear.onChange(of: geometry.size) { _ in
//                            scope.updateItemFrame(index: itemIndex, geometry: geometry)
//                        }
                    }
                }
            )
        }
    }
}

struct FBPlayerStatsListItem: View {
    @Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let stats: FBPlayerStats
    let isAniItem: Bool
    let itemSize: CGSize?
    let itemOffset: CGSize?
    let showContents: Bool
    
    init(
        fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>,
        stats: FBPlayerStats,
        isAniItem: Bool = false,
        itemSize: CGSize? = nil,
        itemOffset: CGSize? = nil,
        showContents: Bool = true
    ) {
        self.fbPlayerStatsStore = fbPlayerStatsStore
        self.stats = stats
        self.isAniItem = isAniItem
        
        if isAniItem {
            self.itemSize = itemSize
            self.itemOffset = itemOffset
            self.showContents = showContents
        } else {
            self.itemSize = nil
            self.itemOffset = nil
            self.showContents = true
        }
    }
    
    var body: some View {
        MovingCapsuleItemContainer(
            isButton: false,
            isAniItem: isAniItem,
            itemOffset: itemOffset,
        ) {
            FBPlayerStatsItem(
                fbPlayerStatsStore: fbPlayerStatsStore,
                stats: stats
            )
            .opacity(showContents ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, UIConstants.Padding.defaultHPadding)
        .padding(.bottom, UIConstants.Padding.defalutVPadding)
    }
}

struct FBPlayerStatsItem: View {
    @Bindable var fbPlayerStatsStore: StoreOf<FBPlayerStatsStore>
    
    let stats: FBPlayerStats
    
    @State private var isAttackStatsOpened = true
    @State private var isDefendStatsOpened = false
    @State private var isCommonStatsOpened = false
    
    var body: some View {
        let teamNameDic = fbPlayerStatsStore.baseStats.teamNameDictionary
        
        // league / team
        HStack {
            LeagueTitle(
                url: stats.league.logo,
                leagueName: stats.league.name,
                leagueSeason: stats.league.season
            )
            
            Text(" - ")
                .fontWeight(.medium)
            
            URLImage(url: stats.team.logo, customSize: CGSize(width: 24, height: 24))
            
            Text(teamNameDic["short_\(stats.team.id)"] ?? stats.team.name)
                .font(.system(size: 16))
                .fontWeight(.medium)
        }
        
        // stats
        // TODO: 수비수, 골기퍼, 공격수 별로 데이터 노출 다르게
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isAttackStatsOpened.toggle()
            }
        }) {
            Text("공격 기록")
            
            Image(systemName: "chevron.\(isAttackStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isAttackStatsOpened {
            HStack {
                FBStatDataItem(
                    category: "골",
                    data: "\(stats.goals.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "도움",
                    data: "\(stats.goals.assists)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "패널티 골",
                    data: "\(stats.penalty.scored)",
                    customWidth: 70
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "슈팅",
                    data: "\(stats.shots.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "유효 슈팅",
                    data: "\(stats.shots.on)",
                    customWidth: 70
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "드리블",
                    data: "\(stats.dribbles.attempts)",
                    customWidth: 60
                )
                .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isDefendStatsOpened.toggle()
            }
        }) {
            Text("수비 기록")
            
            Image(systemName: "chevron.\(isDefendStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isDefendStatsOpened {
            HStack {
                FBStatDataItem(
                    category: "태클",
                    data: "\(stats.tackles.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "파울",
                    data: "\(stats.fouls.committed)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "경고",
                    data: "\(stats.cards.yellow)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "퇴장",
                    data: "\(stats.cards.red)"
                )
                .frame(maxWidth: .infinity)
            }
        }
        
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                isCommonStatsOpened.toggle()
            }
        }) {
            Text("공통 기록")
            
            Image(systemName: "chevron.\(isCommonStatsOpened ? "up" : "down")")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        
        if isCommonStatsOpened {
            HStack {
                FBStatDataItem(
                    category: "출전 경기수",
                    data: "\(stats.games.appearences)",
                    customWidth: 70
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "패스",
                    data: "\(stats.passes.total)"
                )
                .frame(maxWidth: .infinity)
                StatsDivider()
                FBStatDataItem(
                    category: "평균 평점",
                    data: "\(stats.games.rating.prefix(3))",
                    customWidth: 70
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}
