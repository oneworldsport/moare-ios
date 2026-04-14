//
//  GameStatsViewContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 8/20/25.
//

import Foundation
import SwiftUI

extension GameStatsViewContainer where CustomStatsContent == EmptyView {
    init(
        state: GameStatsContainerState,
        actions: GameStatsContainerActions,
        shouldUseCustomStatsContent: Bool = false,
        @ViewBuilder titleContent: @escaping () -> TitleContent,
        @ViewBuilder gameContent: @escaping () -> GameContent
    ) {
        self.init(
            state: state,
            actions: actions,
            shouldUseCustomStatsContent: shouldUseCustomStatsContent,
            titleContent: titleContent,
            gameContent: gameContent,
            customStatsContent: { EmptyView() }
        )
    }
}

struct GameStatsViewContainer<TitleContent: View, GameContent: View, CustomStatsContent: View>: View {
    let state: GameStatsContainerState
    let actions: GameStatsContainerActions
    let shouldUseCustomStatsContent: Bool
    @ViewBuilder let titleContent: () -> TitleContent
    @ViewBuilder let gameContent: () -> GameContent
    @ViewBuilder let customStatsContent: () -> CustomStatsContent
    
    private let defaultColumnWidth: CGFloat = 100
    private let defaultDataItemHeight: CGFloat = 40
    private let coordinateSpaceName = "GameStatsViewContainer"
    
    @State private var teamButtonWidth: CGFloat = 0
    @State private var teamCategoryBarXOffset: CGFloat = 0
    @State private var firstStatsCategoryBarXOffset: CGFloat = 0
    @State private var secondStatsCategoryBarXOffset: CGFloat = 0
    
    @State private var isGameDetailVisible: Bool = false
    
    init(
        state: GameStatsContainerState,
        actions: GameStatsContainerActions,
        shouldUseCustomStatsContent: Bool = false,
        @ViewBuilder titleContent: @escaping () -> TitleContent,
        @ViewBuilder gameContent: @escaping () -> GameContent,
        @ViewBuilder customStatsContent: @escaping () -> CustomStatsContent
    ) {
        self.state = state
        self.actions = actions
        self.shouldUseCustomStatsContent = shouldUseCustomStatsContent
        self.titleContent = titleContent
        self.gameContent = gameContent
        self.customStatsContent = customStatsContent
    }

    var body: some View {
        let firstStatsColumnWidthList = state.firstStatsColumnWidthList
        let secondStatsColumnWidthList = state.secondStatsColumnWidthList
        
        // TODO: stats화면을 스크롤 올릴때 spacing때문에 생기는 빈공간을 없애야함. 그렇다고 spacing을 없애면 너무 많은걸 수정해야해서, -padding을 주는걸 해봐야할듯
        VStack(spacing: 6) {
            if state.shouldShowTitle {
                titleContent()
            }
            
            if state.shouldShowGameContent {
                gameContent()
            }
            
            HDivider()
            
            ZStack {
                if state.shouldShowStats {
                    ScrollView {
                        VStack(spacing: 0) {
                            HStack {
                                // team button
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 0) {
                                        ForEach(Array(state.teamCategories.enumerated()), id: \.offset) { index, item in
                                            Button(action: {
                                                actions.teamCategoryButtonAction?(index)
                                            }) {
                                                if let imageUrl = item.imageUrl {
                                                    URLImage(url: imageUrl, size: .small)
                                                }
                                                
                                                Text(item.name)
                                                    .font(.system(size: 15, weight: .medium))
                                            }
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity)
                                            .readSize { size in
                                                teamButtonWidth = size.width
                                            }
                                            
                                            if index == 0 {
                                                VCapsuleBar()
                                                    .opacity(0.5)
                                            }
                                        }
                                    }
                                    .frame(height: 38)
                                    
                                    HCapsuleBar()
                                        .offset(x: teamCategoryBarXOffset)
                                }
                                .onChange(of: teamButtonWidth) {
                                    // NOTE: 원래는 onAppear에서 해야하는데, teamButtonWidth가 측정되기 전에 onAppear가 실행되어 초기에 제대로 반영이 안돼서 .onChange(of: teamButtonWidth)으로 바꿔줌.
                                    withAnimation(.spring(duration: 0.5)) {
                                        teamCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: teamButtonWidth)
                                    }
                                }
                                .onChange(of: state.teamCategorySelectedIndex) {
                                    withAnimation(.spring(duration: 0.5)) {
                                        teamCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: teamButtonWidth, index: state.teamCategorySelectedIndex) + 2
                                    }
                                }
                                
                                VStack {
                                    // game detail info button
                                    Button(action: {
                                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                                            isGameDetailVisible = true
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Text("경기 상세 정보")
                                                .font(.system(size: 12))
                                                .foregroundStyle(.secondary)
                                            
                                            Image(systemName: "chevron.left")
                                                .tint(.secondary)
                                                .font(.system(size: 12))
                                        }
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 4)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(.secondary, lineWidth: 1)
                                        }
                                    }
                                    .foregroundStyle(.secondary)
                                    .opacity(isGameDetailVisible ? 0 : 0.6)
                                    
                                    // refresh button
//                                    if state.shouldShowRefreshButton {
//                                        // TODO: Make it component
//                                        Button(action: {
//                                            actions.refreshButtonAction()
//                                        }) {
//                                            Image(systemName: "arrow.clockwise")
//                                                .font(.system(size: 15))
//                                                .frame(width: 18, height: 18)
//                                                .padding(3)
//                                                .overlay {
//                                                    RoundedRectangle(cornerRadius: 10)
//                                                        .stroke(.secondary, lineWidth: 1)
//                                                }
//                                        }
//                                        .foregroundStyle(.secondary)
//                                        .opacity(0.6)                                        
//                                    }
                                }
                            }
                            
                            if shouldUseCustomStatsContent {
                                customStatsContent()
                            } else {
                                if state.shouldShowCoach {
                                    HStack {
                                        Text("감독: ")
                                            .font(.system(size: 15))
                                        
                                        URLImage(
                                            url: state.coachState?.imageUrl,
                                            customSize: CGSize(width: 23, height: 23)
                                        )
                                        
                                        Text(state.coachState?.name ?? "")
                                            .font(.system(size: 15))
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 8)
                                }
                                
                                // player stats
                                if let title = state.firstStatsTitle {
                                    HStack {
                                        VStack(spacing: 2) {
                                            Text(title)
                                                .font(.system(size: 15, weight: .medium))
                                            
                                            HCapsuleBar()
                                        }
                                        .frame(width: 132)
                                        
                                        Spacer()
                                    }
                                }
                                
                                HStack(spacing: 0) {
                                    VStack(spacing: 0) {
                                        StickyHeader(coordinateSpaceName: coordinateSpaceName) {
                                            OptionalButton(action: actions.firstStatsTitleCategoryAction) {
                                                ZStack(alignment: .bottom) {
                                                    StandingsFirstCategoryItem(text: StringConstants.gameStatsFirstCategory, width: state.firstColumnWidth)
                                                    
                                                    HCapsuleBar()
                                                        .opacity(state.firstStatsCategorySelectedIndex < 0 ? 1 : 0)
                                                }
                                            }
                                        }
                                        .frame(width: state.firstColumnWidth ?? 132)
                                        
                                        ForEach(state.firstStatsPlayerList.indices, id:\.self) { index in
                                            let data = state.firstStatsPlayerList[index]
                                            
                                            StandingsRankItem(
                                                id: data.id,
                                                width: state.firstColumnWidth,
                                                shouldShowRank: data.numInfo != nil,
                                                shouldShowExtraInfo: true,
                                                rank: data.numInfo ?? 0,
                                                imageUrl: data.imageUrl,
                                                name: data.name.dropFirstWord,
                                                subName: data.subName,
                                                extraInfo: data.extraInfo,
                                                extraSubInfo: data.extraSubInfo,
                                                action: { _ in }
                                            )
                                        }
                                    }
                                    
                                    ScrollView(.horizontal) {
                                        VStack(spacing: 0) {
                                            StickyHeader(coordinateSpaceName: coordinateSpaceName) {
                                                VStack(alignment: .leading, spacing: 0) {
                                                    // second category
                                                    HStack(spacing: 0) {
                                                        ForEach(state.firstStatsCategories.indices, id:\.self) { index in
                                                            let category = state.firstStatsCategories[index]
                                                            
                                                            Button(action: {
                                                                actions.firstStatsCategoryButtonAction(index)
                                                            }) {
                                                                Text(category)
                                                                    .font(.system(size: 15, weight: .medium))
                                                                    .frame(width: firstStatsColumnWidthList[safe: index] ?? defaultColumnWidth)
                                                            }
                                                            .foregroundStyle(.primary)
                                                            .disabled(category.isEmpty)
                                                            .id(index)
                                                        }
                                                    }
                                                    .frame(height: 38)
                                                    
                                                    HCapsuleBar()
                                                        .offset(x: firstStatsCategoryBarXOffset)
                                                }
                                                .onAppear {
                                                    withAnimation(.spring(duration: 0.5)) {
                                                        if state.firstStatsCategorySelectedIndex < 0 {
                                                            let firstColumnWidth = state.firstColumnWidth ?? 132
                                                            firstStatsCategoryBarXOffset = -(firstColumnWidth / 2) - 10
                                                        } else if !firstStatsColumnWidthList.isEmpty {
                                                            firstStatsCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidths: firstStatsColumnWidthList, index: state.firstStatsCategorySelectedIndex)
                                                        } else {
                                                            firstStatsCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: defaultColumnWidth, index: state.firstStatsCategorySelectedIndex)
                                                        }
                                                    }
                                                }
                                                .onChange(of: state.firstStatsCategorySelectedIndex) {
                                                    withAnimation(.spring(duration: 0.5)) {
                                                        if state.firstStatsCategorySelectedIndex < 0 {
                                                            let firstColumnWidth = state.firstColumnWidth ?? 132
                                                            firstStatsCategoryBarXOffset = -(firstColumnWidth / 2) - 10
                                                        } else if !firstStatsColumnWidthList.isEmpty {
                                                            firstStatsCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidths: firstStatsColumnWidthList, index: state.firstStatsCategorySelectedIndex)
                                                        } else {
                                                            firstStatsCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: defaultColumnWidth, index: state.firstStatsCategorySelectedIndex)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // data items
                                            ForEach(state.firstStatsPlayerList.indices, id:\.self) { index in
                                                let item = state.firstStatsPlayerList[index]
                                                
                                                HStack(spacing: 0) {
                                                    ForEach(item.dataList.indices, id:\.self) { index in
                                                        let data = item.dataList[index]
                                                        
                                                        Text(data)
                                                            .font(.system(size: 15))
                                                            .frame(width: firstStatsColumnWidthList[safe: index] ?? defaultColumnWidth)
                                                    }
                                                }
                                                .frame(height: defaultDataItemHeight)
                                            }
                                        }
                                    } // ScrollView(.horizontal)
                                }
                                
                                // 보여줄 Stats list가 두개인 경우의 두번째 Stats list. ex) KBO, MLB의 투수 기록
                                if let title = state.secondStatsTitle {
                                    HStack {
                                        VStack(spacing: 2) {
                                            Text(title)
                                                .font(.system(size: 15, weight: .medium))
                                            
                                            HCapsuleBar()
                                        }
                                        .frame(width: 132)
                                        
                                        Spacer()
                                    }
                                    //                                .frame(maxWidth: .infinity, alignment: .leading)
                                    // TODO: firstStats의 StickyHeader부분이 해당 뷰에 가려져서 .zIndex(-1)를 추가했는데, StandingsFirstCategoryItem()는 해결됐으나 firstStatsCategories는 여전히 가려짐.
                                    // 테스트 하려면 MLBGameStatsView에서 secondStatsPlayerList: pitcherList + pitcherList
                                    .zIndex(-1)
                                    .padding(.top, 10)
                                }
                                
                                if let secondStatsCategories = state.secondStatsCategories,
                                   let secondStatsPlayerList = state.secondStatsPlayerList {
                                    HStack(spacing: 0) {
                                        VStack(spacing: 0) {
                                            StickyHeader(coordinateSpaceName: coordinateSpaceName) {
                                                StandingsFirstCategoryItem(text: StringConstants.gameStatsFirstCategory)
                                            }
                                            .frame(width: 132)
                                            
                                            ForEach(secondStatsPlayerList.indices, id:\.self) { index in
                                                let data = secondStatsPlayerList[index]
                                                
                                                StandingsRankItem(
                                                    id: data.id,
                                                    shouldShowRank: data.numInfo != nil,
                                                    shouldShowExtraInfo: true,
                                                    rank: data.numInfo ?? 0,
                                                    imageUrl: data.imageUrl,
                                                    name: data.name,
                                                    subName: data.subName,
                                                    extraInfo: data.extraInfo,
                                                    extraSubInfo: data.extraSubInfo,
                                                    action: { _ in }
                                                )
                                            }
                                        }
                                        
                                        ScrollView(.horizontal) {
                                            VStack(spacing: 0) {
                                                StickyHeader(coordinateSpaceName: coordinateSpaceName) {
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        // second category
                                                        HStack(spacing: 0) {
                                                            ForEach(secondStatsCategories.indices, id:\.self) { index in
                                                                let category = secondStatsCategories[index]
                                                                
                                                                Button(action: {
                                                                    actions.secondStatsCategoryButtonAction?(index)
                                                                }) {
                                                                    Text(category)
                                                                        .font(.system(size: 15, weight: .medium))
                                                                        .frame(width: secondStatsColumnWidthList[safe: index] ?? defaultColumnWidth)
                                                                }
                                                                .foregroundStyle(.primary)
                                                                .id(index)
                                                            }
                                                        }
                                                        .frame(height: 38)
                                                        
                                                        HCapsuleBar()
                                                            .offset(x: secondStatsCategoryBarXOffset)
                                                    }
                                                    .onAppear {
                                                        withAnimation(.spring(duration: 0.5)) {
                                                            if !secondStatsColumnWidthList.isEmpty {
                                                                secondStatsCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidths: secondStatsColumnWidthList, index: state.secondStatsCategorySelectedIndex)
                                                            } else {
                                                                secondStatsCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: defaultColumnWidth, index: state.secondStatsCategorySelectedIndex)
                                                            }
                                                        }
                                                    }
                                                    .onChange(of: state.secondStatsCategorySelectedIndex) {
                                                        withAnimation(.spring(duration: 0.5)) {
                                                            if !firstStatsColumnWidthList.isEmpty {
                                                                secondStatsCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidths: secondStatsColumnWidthList, index: state.secondStatsCategorySelectedIndex)
                                                            } else {
                                                                secondStatsCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: defaultColumnWidth, index: state.secondStatsCategorySelectedIndex)
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                // data items
                                                ForEach(secondStatsPlayerList.indices, id:\.self) { index in
                                                    let item = secondStatsPlayerList[index]
                                                    
                                                    HStack(spacing: 0) {
                                                        ForEach(item.dataList.indices, id:\.self) { index in
                                                            let data = item.dataList[index]
                                                            
                                                            Text(data)
                                                                .font(.system(size: 15))
                                                                .frame(width: secondStatsColumnWidthList[safe: index] ?? defaultColumnWidth)
                                                        }
                                                    }
                                                    .frame(height: defaultDataItemHeight)
                                                }
                                            }
                                        }
                                    }
                                }
                            } // if shouldUseCustomStatsContent
                        } // VStack
                    } // ScrollView
                    .coordinateSpace(name: coordinateSpaceName)
                    .refreshableIf(state.shouldShowRefreshButton) {
                        await actions.refreshButtonAction()
                    }
                } else {
                    VStack {
                        Text(state.noStatsText ?? "경기 시작 후 데이터가 업데이트됩니다.")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
//                            .contentShape(Rectangle())
                    }
                }
                
                // game detail info
                if isGameDetailVisible {
                    HStack(alignment: .top, spacing: 0) {
                        Button(action: {
                            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                                isGameDetailVisible = false
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .frame(width: 20, height: 20)
                                .background {
                                    // 뒤에 하얀색 배경을 .overlay와 정확히 일치하게
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundStyle(.white)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.secondary, lineWidth: 1)
                                }
                        }
                        .foregroundStyle(.secondary)
                        
                        HStack(alignment: .top, spacing: 0) {
                            Text(state.gameDetailTitle)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            
                            Text(state.gameDetailContent)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .frame(minHeight: 80, alignment: .top)
                        .background {
                            // 뒤에 하얀색 배경을 .overlay와 정확히 일치하게
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.secondary, lineWidth: 1)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
//                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .transition(.move(edge: .trailing))
                }
            } // ZStack
        }
    }
}

