//
//  StandingsContainerState.swift
//  moare
//
//  Created by Mohwa Yoon on 6/8/25.
//

import Foundation

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
    var displayDataState: ApiFetchState? = nil
    var firstColumnWidth: CGFloat? = nil
    var columnWidthList: [CGFloat] = []
    var isGameStats: Bool = false
}

struct StandingsItemState {
    var id: Int = 0
    var isGameStats: Bool = false
    var numInfo: Int? = nil
    var imageUrl: String?
    var name: String
    var subName: String? = nil
    var extraInfo: String? = nil
    var extraSubInfo: String? = nil
    var isSvgLogo: Bool = false
    var dataList: [String]
}

struct StandingsHighlightItemState {
    let itemIndex: Int?
    let standingsStartIndex: Int
    let allStandingsCount: Int // filtered된 Standings말고 전체 Standings의 count. 아래로 showMoreStandings 하기 위한 분기문에서 사용.
}

struct StandingsContainerActions {
    var headerCategoryButtonAction: ((Int) -> Void)? = nil
    var firstCategoryButtonAction: ((Int) -> Void)? = nil
    let secondCategoryButtonAction: (_ index: Int, _ category: String) -> Void
    let itemButtonAction: (Int) -> Void
    var showMoreStandingsAction: ((Bool) -> Void)? = nil
}
