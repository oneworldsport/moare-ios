//
//  StandingsViewContainer.swift
//  moare
//
//  Created by Mohwa Yoon on 6/8/25.
//

import SwiftUI

struct StandingsViewContainer<TitleContent: View, CustomListContent: View>: View {
    let state: StandingsContainerState
    let actions: StandingsContainerActions
    let shouldUseCustomListContent: Bool
    @ViewBuilder let titleContent: () -> TitleContent
    @ViewBuilder let customListContent: (_ totalHScrollDistance: CGFloat) -> CustomListContent
    
    private let secondCategoryItemWidth: CGFloat = 100
    
    @State private var oldOffset: CGFloat = 0
    @State private var totalHScrollDistance: CGFloat = 0
    @State private var headerCategoryBarXOffset: CGFloat = 0
    @State private var secondCategoryBarXOffset: CGFloat = 0
    
    @Namespace var coordinateSpaceName: Namespace.ID
    
    init(
        state: StandingsContainerState,
        actions: StandingsContainerActions,
        shouldUseCustomListContent: Bool = false,
        @ViewBuilder titleContent: @escaping () -> TitleContent,
        @ViewBuilder customListContent: @escaping (_ totalHScrollDistance: CGFloat) -> CustomListContent // TODO: Has to give default value
    ) {
        self.state = state
        self.actions = actions
        self.shouldUseCustomListContent = shouldUseCustomListContent
        self.titleContent = titleContent
        self.customListContent = customListContent
    }

    var body: some View {
        VStack(spacing: 0) {
            // league title
            titleContent()
            
            // header category
            if let headerCategories = state.headerCategories {
                let categoryCount = headerCategories.count
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(Array(headerCategories.enumerated()), id: \.offset) { index, item in
                            Button(action: {
                                actions.headerCategoryButtonAction?(index)
                            }) {
                                Text(item)
                                    .font(.system(size: 15, weight: .medium))
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundStyle(.primary)
                            
                            if index == 0 {
                                Rectangle()
                                    .frame(width: 2)
                                    .foregroundStyle(.secondary)
                                    .opacity(0.5)
                            }
                        }
                    }
                    .frame(height: 38)
                    
                    HCapsuleBar()
                        .offset(x: headerCategoryBarXOffset)
                }
                .onAppear {
                    withAnimation(.spring(duration: 0.5)) {
                        headerCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: UIConstants.Width.screenWidth / CGFloat(categoryCount), index: 0)
                    }
                }
                .onChange(of: state.headerCategorySelectedIndex) {
                    withAnimation(.spring(duration: 0.5)) {
                        headerCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: UIConstants.Width.screenWidth / CGFloat(categoryCount), index: state.headerCategorySelectedIndex) + CGFloat((state.headerCategorySelectedIndex * 2))
                    }
                }
            }
            
            ScrollView(.horizontal) {
                VStack(spacing: 0) {
                    // categories
                    HStack(spacing: 0) {
                        StandingsFirstCategoryItem(text: state.firstCategoryText)
                            .frame(height: 40)
                            .background(.white)
                            .zIndex(1)
                            .offset(x: totalHScrollDistance < 0 ? 0 : totalHScrollDistance)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            ScrollViewReader { proxy in
//                                if let firstCategories = state.firstCategories {
//                                    HStack(spacing: 0) {
//                                        ForEach(firstCategories.indices, id:\.self) { index in
//                                            let category = state.secondCategories[index]
//                                            
//                                            Button(action: {
//                                                actions.firstCategoryButtonAction?(index)
//                                            }) {
//                                                Text(category)
//                                                    .font(.system(size: 15, weight: .medium))
//                                                    .frame(width: 100)
//                                            }
//                                            .foregroundStyle(.primary)
//                                            .id(index)
//                                        }
//                                    }
//                                    .frame(height: 38)
//                                }
                                
                                // second category
                                HStack(spacing: 0) {
                                    ForEach(state.secondCategories.indices, id:\.self) { index in
                                        let category = state.secondCategories[index]
                                        
                                        Button(action: {
                                            actions.secondCategoryButtonAction(index)
                                        }) {
                                            Text(category)
                                                .font(.system(size: 15, weight: .medium))
                                                .frame(width: secondCategoryItemWidth)
                                        }
                                        .foregroundStyle(.primary)
                                        .id(index)
                                    }
                                }
                                .frame(height: 38)
                                .onAppear {
                                    // TODO: should decide animation type
                                    // scroll and move bar to category that matches with the keyword
                                    //                                moveBar(index: fbTeamStandingsStore.selectedIndex)
                                    //
                                    //                                withAnimation {
                                    //                                    proxy.scrollTo(fbTeamStandingsStore.selectedIndex, anchor: .leading)
                                    //                                }
                                }
                            } // ScrollViewReader
                            
                            HCapsuleBar()
                                .offset(x: secondCategoryBarXOffset)
                        }
                        .onAppear {
                            withAnimation(.spring(duration: 0.5)) {
                                secondCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: secondCategoryItemWidth, index: 0)
                            }
                        }
                        .onChange(of: state.secondCategorySelectedIndex) {
                            withAnimation(.spring(duration: 0.5)) {
                                secondCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: secondCategoryItemWidth, index: state.secondCategorySelectedIndex)
                            }
                        }
                    }
                    
                    // standings
                    ScrollView {
                        if shouldUseCustomListContent {
                            customListContent(totalHScrollDistance)
                        } else {
                            HStack(spacing: 0) {
                                // rank items
                                VStack(spacing: 0) {
                                    ForEach(state.standings.indices, id:\.self) { index in
                                        let data = state.standings[index]
                                        
                                        if let highlightState = state.highlightState, highlightState.itemIndex == highlightState.standingsStartIndex + index {
                                            Rectangle()
                                                .fill(.moare)
                                                .frame(height: 1)
                                        }
                                        
                                        StandingsRankItem(
                                            isGameStats: data.isGameStats,
                                            rank: index + 1,
                                            imageUrl: data.imageUrl,
                                            isSvgLogo: data.isSvgLogo,
                                            name: data.name,
                                            subName: data.subName,
                                            extraInfo: data.extraInfo,
                                            extraSubInfo: data.extraSubInfo,
                                            action: actions.itemButtonAction
                                        )
                                        
                                        if let highlightState = state.highlightState, highlightState.itemIndex == highlightState.standingsStartIndex + index {
                                            Rectangle()
                                                .fill(.moare)
                                                .frame(height: 1)
                                        }
                                    }
                                }
                                .background(.white)
                                .zIndex(1)
                                .offset(x: totalHScrollDistance < 0 ? 0 : totalHScrollDistance)
                                
                                // data items
                                VStack(spacing: 0) {
                                    ForEach(state.standings.indices, id:\.self) { index in
                                        let item = state.standings[index]
                                        
                                        HStack(spacing: 0) {
                                            ForEach(item.dataList.indices, id:\.self) { index in
                                                let data = item.dataList[index]
                                                
                                                Text(data)
                                                    .font(.system(size: 15))
                                                    .frame(width: 100)
                                            }
                                        }
                                        .frame(height: 40)
                                    }
                                }
                            } // HStack
                        }
                    } // ScrollView
                }
                .background {
                    GeometryReader { geometryProxy in
                        let newOffset = geometryProxy.frame(in: .named(coordinateSpaceName)).minX
                        
                        Color.clear
                            .onAppear {
                                oldOffset = newOffset
                            }
                            .onChange(of: newOffset) {
                                let delta = oldOffset - newOffset
                                totalHScrollDistance += delta
                                oldOffset = newOffset
                            }
                    }
                }
            }
            .coordinateSpace(name: coordinateSpaceName)
        }
    }
    
    private func moveBar() {
        
    }
}
