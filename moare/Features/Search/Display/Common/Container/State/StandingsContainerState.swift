//
//  StandingsContainerState.swift
//  moare
//
//  Created by Mohwa Yoon on 6/8/25.
//

struct StandingsContainerState {
    var firstCategoryText: String = StringConstants.standingsFirstCategory
    var headerCategories: [String]? = nil
    var firstCategories: [String]? = nil
    let secondCategories: [String]
    let standings: [StandingsItemState]
    var headerCategorySelectedIndex: Int = 0
    var firstCategorySelectedIndex: Int = 0
    var secondCategorySelectedIndex: Int = 0
    var highlightState: StandingsHighlightItemState? = nil
}

struct StandingsItemState {
    var isGameStats: Bool = false
    var imageUrl: String?
    var name: String
    var subName: String? = nil
    var extraInfo: String? = nil
    var extraSubInfo: String? = nil
    var isSvgLogo: Bool = false
    var dataList: [String]
}

struct StandingsHighlightItemState {
    let itemIndex: Int
    let standingsStartIndex: Int
}

struct StandingsContainerActions {
    var headerCategoryButtonAction: ((Int) -> Void)? = nil
    var firstCategoryButtonAction: ((Int) -> Void)? = nil
    let secondCategoryButtonAction: (Int) -> Void
    let itemButtonAction: () -> Void
}
