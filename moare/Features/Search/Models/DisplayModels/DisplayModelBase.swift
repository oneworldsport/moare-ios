//
//  DisplayModelBase.swift
//  moare
//
//  Created by Mohwa Yoon on 5/22/25.
//

protocol DisplayModelBase: Equatable {
    var leagueId: Int { get }
    var keywords: [Keyword] { get }
    var entityInfo: [EntityInfo] { get }
}
