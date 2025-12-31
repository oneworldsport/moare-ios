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
    
    private let defaultColumnWidth: CGFloat = 100
    private let defaultDataItemHeight: CGFloat = 40
    
    @State private var oldHOffset: CGFloat = 0
    @State private var totalHScrollDistance: CGFloat = 0
    @State private var headerCategoryBarXOffset: CGFloat = 0
    @State private var secondCategoryBarXOffset: CGFloat = 0
    
    // properties for player standings
    @State private var oldVOffset: CGFloat = 0
    @State private var canShowMoreStandings = true
    @State private var totalVScrollDistance: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    
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
        let columnWidthList = state.columnWidthList
        let columnTotalWidth: CGFloat = !columnWidthList.isEmpty ? columnWidthList.reduce(0, +) :
        defaultColumnWidth * CGFloat(state.secondCategories.count)
        let standingsCount = state.standings.count
        
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
                        headerCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: UIConstants.Width.screenWidth / CGFloat(categoryCount), index: state.headerCategorySelectedIndex)
                    }
                }
                .onChange(of: state.headerCategorySelectedIndex) {
                    withAnimation(.spring(duration: 0.5)) {
                        // CGFloat((state.headerCategorySelectedIndex * 2))는 카테고리 사이에 HCapsuleBar() widths
                        // TODO: 더 정확히 하려면 screenWidth에서 먼저 HCapsuleBar() widths를 뺴야함..
                        headerCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: UIConstants.Width.screenWidth / CGFloat(categoryCount), index: state.headerCategorySelectedIndex) + CGFloat((state.headerCategorySelectedIndex * 2))
                    }
                }
            }
            
            ScrollView(.horizontal) {
                VStack(spacing: 0) {
                    // categories
                    HStack(spacing: 0) {
                        StandingsFirstCategoryItem(text: state.firstCategoryText, width: state.firstColumnWidth)
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
                                            actions.secondCategoryButtonAction(index, category)
                                        }) {
                                            Text(category)
                                                .font(.system(size: 15, weight: .medium))
                                                .frame(width: columnWidthList[safe: index] ?? defaultColumnWidth)
                                        }
                                        .foregroundStyle(.primary)
                                        .id(index)
                                    }
                                }
                                .frame(height: 38)
                                .onAppear {
                                    // scroll to category that matches with the keyword on first open
                                    withAnimation {
                                        // NOTE: StandingsFirstCategoryItem 때문에 state.secondCategorySelectedIndex로 scrollTo하면 해당 아이템이 뒤로 숨어서 보이지 않아 -3 index 만큼 덜 스크롤 한다.
                                        // STUDY: scrollTo에 없는 값이 들어가면 오류나지 않고 그냥 아무 동작 없음(스크롤 안됨).
                                        proxy.scrollTo(state.secondCategorySelectedIndex - 3, anchor: .leading)
                                    }
                                }
                            } // ScrollViewReader
                            
                            HCapsuleBar()
                                .offset(x: secondCategoryBarXOffset)
                        }
                        .onAppear {
                            withAnimation(.spring(duration: 0.5)) {
                                if !columnWidthList.isEmpty {
                                    secondCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidths: columnWidthList, index: state.secondCategorySelectedIndex)
                                } else {
                                    secondCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: defaultColumnWidth, index: state.secondCategorySelectedIndex)
                                }
                            }
                        }
                        .onChange(of: state.secondCategorySelectedIndex) {
                            withAnimation(.spring(duration: 0.5)) {
                                if !columnWidthList.isEmpty {
                                    secondCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidths: columnWidthList, index: state.secondCategorySelectedIndex)
                                } else {
                                    secondCategoryBarXOffset = getOffsetOfAniCapsuleBar(itemWidth: defaultColumnWidth, index: state.secondCategorySelectedIndex)
                                }
                            }
                        }
                    }
                    
                    // standings
                    ScrollView {
                        if shouldUseCustomListContent {
                            customListContent(totalHScrollDistance)
                        } else {
                            ScrollViewReader { proxy in
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
                                                id: data.id,
                                                width: state.firstColumnWidth,
                                                rank: state.highlightState != nil ? (state.highlightState!.standingsStartIndex + index + 1) : data.rank != nil ? data.rank! : (index + 1),
                                                imageUrl: data.imageUrl,
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
                                            
                                            if let highlightState = state.highlightState, highlightState.itemIndex == highlightState.standingsStartIndex + index {
                                                Rectangle()
                                                    .fill(.moare)
                                                    .frame(width: columnTotalWidth, height: 1)
                                            }
                                            
                                            HStack(spacing: 0) {
                                                ForEach(item.dataList.indices, id:\.self) { index in
                                                    let data = item.dataList[index]
                                                    
                                                    Text(data)
                                                        .font(.system(size: 15))
                                                        .frame(width: columnWidthList[safe: index] ?? defaultColumnWidth)
                                                }
                                            }
                                            .frame(height: defaultDataItemHeight)
                                            
                                            if let highlightState = state.highlightState, highlightState.itemIndex == highlightState.standingsStartIndex + index {
                                                Rectangle()
                                                    .fill(.moare)
                                                    .frame(width: columnTotalWidth, height: 1)
                                            }
                                        }
                                    }
                                } // HStack
                                .background(
                                    GeometryReader { geometry in
                                        if let showMoreStandingsAction = actions.showMoreStandingsAction {
                                            let newOffset = geometry.frame(in: .named(coordinateSpaceName)).minY
                                            
                                            Color.clear
                                                .onAppear {
                                                    oldVOffset = newOffset
                                                    
                                                    contentHeight = CGFloat(standingsCount) * defaultDataItemHeight
                                                }
                                                .onChange(of: standingsCount) {
                                                    contentHeight = CGFloat(standingsCount) * defaultDataItemHeight
                                                    
                                                    // 추가로 10개의 standings가 나오고 다시 상단/하단으로 이동하는데 시간이 걸리기때문에, 다시 showMoreStandings를 가능하게 하는데 1초 delay를 주는건 괜찮아 보인다.
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                        canShowMoreStandings = true
                                                    }
                                                }
                                                .onChange(of: newOffset) {
                                                    let delta = oldVOffset - newOffset
                                                    totalVScrollDistance += delta
                                                    oldVOffset = newOffset
                                                    
                                                    let scrollableDistance = contentHeight - scrollViewHeight
                                                    
                                                    if canShowMoreStandings {
                                                        if state.highlightState?.standingsStartIndex != 0 && totalVScrollDistance <= 0 {
                                                            canShowMoreStandings = false
                                                            showMoreStandingsAction(true)
                                                            print("tooooppppp")
                                                        } else if (state.highlightState?.allStandingsCount != standingsCount) &&
                                                                    (totalVScrollDistance >= (scrollableDistance - 2)) { // give extra space for possible difference
                                                            canShowMoreStandings = false
                                                            showMoreStandingsAction(false)
                                                            print("botttttooom")
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                ) // .background()
                                .onChange(of: state.highlightState?.standingsStartIndex) {
                                    if let showMoreStandingsAction = actions.showMoreStandingsAction {
                                        if standingsCount == 20 {
                                            proxy.scrollTo(1, anchor: .top)
                                        } else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                proxy.scrollTo(10, anchor: .top)
                                            }
                                        }
                                    }
                                }
                            } // ScrollViewReader
                        }
                    } // ScrollView
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    scrollViewHeight = geometry.size.height
                                }
                        }
                    )
                }
                .background {
                    GeometryReader { geometryProxy in
                        let newOffset = geometryProxy.frame(in: .named(coordinateSpaceName)).minX
                        
                        Color.clear
                            .onAppear {
                                oldHOffset = newOffset
                            }
                            .onChange(of: newOffset) {
                                let delta = oldHOffset - newOffset
                                totalHScrollDistance += delta
                                oldHOffset = newOffset
                            }
                    }
                }
            }
            .coordinateSpace(name: coordinateSpaceName)
        }
    }
}
