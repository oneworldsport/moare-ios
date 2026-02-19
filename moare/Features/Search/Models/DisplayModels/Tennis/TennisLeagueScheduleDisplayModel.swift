//
//  TennisLeagueScheduleDisplayModel.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

struct TennisLeagueScheduleDisplayModel: SportDisplayModel {
    let leagueId: Int
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let season: Int
    let scheduleType: ScheduleType
    let yearMonthList: [String]
    let startDate: String?
    let endDate: String?
    let relatedLeagueIds: [Int]?
    var games: [TennisGameForSchedule]
    
    var sortedRelatedLeagues: [Int]? {
        relatedLeagueIds?.sorted {
            StringConstants.Tennis.relatedLeagueRank(leagueId: $0) < StringConstants.Tennis.relatedLeagueRank(leagueId: $1)
        }
    }
    var relatedLeaguesKrname: [String] {
        (sortedRelatedLeagues ?? [])
            .compactMap {
                leagueId in StringConstants.Tennis.relatedLeaguesKrName(leagueId: leagueId)
            }
    }
}
