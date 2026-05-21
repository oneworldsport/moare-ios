//
//  SearchClient.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/6/24.
//

import Foundation
import ComposableArchitecture

struct SearchClient {
    var fetchDataByQuery: @Sendable (_ query: String) async throws -> DataModel
    var fetchDataByKeyword: @Sendable (_ keyword: KeywordInfo, _ season: Int?) async throws -> DataModel
    var fetchLeagueSchedule: @Sendable (_ entity: EntityInfo, _ season: Int?, _ yearMonth: String?, _ day: Int?) async throws -> DataModel
    var fetchById: @Sendable (_ season: Int?, _ category: String, _ date: String?, _ dataType: String, _ leagueId: Int, _ id: String) async throws -> DataModel
    
    //    func fetchDataByQuery(query: String) async throws -> DataModel {
    ////        return try await apiClient.fetchData(endpoint: .searchByQuery(query: query), testQuery: query)
    ////        return String(decoding: data, as: UTF8.self)
    //
    //        let raw: RawDataModel = try await apiClient.fetchData(endpoint: .searchByQuery(query: query), testQuery: query)
    //        return try DataModel.from(raw: raw)
    //    }
    //
    //    func fetchDataByKeyword(keyword: KeywordInfo, season: Int? = nil) async throws -> DataModel {
    //        let raw: RawDataModel = try await apiClient.fetchData(endpoint: .searchByKeyword(keyword: keyword, season: season))
    //        return try DataModel.from(raw: raw)
    //    }
    //
    //    func fetchLeagueSchedule(entity: EntityInfo, season: Int?, yearMonth: String?, day: Int? = nil) async throws -> DataModel {
    //        let raw: RawDataModel = try await apiClient.fetchData(endpoint: .getLeagueSchedule(entity: entity, season: season ?? CalendarUtil.currentYear, yearMonth: yearMonth, day: day))
    //        return try DataModel.from(raw: raw)
    //    }
    //
    //    func fetchById(season: Int?, category: String, date: String? = nil, dataType:String, leagueId: Int, id: String) async throws -> DataModel {
    //        let raw: RawDataModel = try await apiClient.fetchData(endpoint: .searchById(season: season ?? CalendarUtil.currentYear, category: category, date: date, dataType: dataType, leagueId: leagueId, id: id))
    //        return try DataModel.from(raw: raw)
    //    }
    
}
 
extension SearchClient: DependencyKey {
    static let liveValue = Self(
        fetchDataByQuery: { query in
            let raw: RawDataModel = try await APIClient().fetchData(
                endpoint: .searchByQuery(query: query),
                testQuery: query
            )
            return try DataModel.from(raw: raw)
        },
        fetchDataByKeyword: { keyword, season in
            let raw: RawDataModel = try await APIClient().fetchData(
                endpoint: .searchByKeyword(keyword: keyword, season: season)
            )
            return try DataModel.from(raw: raw)
        },
        fetchLeagueSchedule: { entity, season, yearMonth, day in
            let raw: RawDataModel = try await APIClient().fetchData(
                endpoint: .getLeagueSchedule(
                    entity: entity,
                    season: season ?? CalendarUtil.currentYear,
                    yearMonth: yearMonth,
                    day: day
                )
            )
            return try DataModel.from(raw: raw)
        },
        fetchById: { season, category, date, dataType, leagueId, id in
            let raw: RawDataModel = try await APIClient().fetchData(
                endpoint: .searchById(
                    season: season ?? CalendarUtil.currentYear,
                    category: category,
                    date: date,
                    dataType: dataType,
                    leagueId: leagueId,
                    id: id
                )
            )
            return try DataModel.from(raw: raw)
        }
    )
}
