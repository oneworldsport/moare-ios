//
//  NoticeModel.swift
//  moare
//
//  Created by Mohwa Yoon on 4/15/25.
//

struct NoticeModel: Decodable, Equatable {
    let title: String
    let sports: [SportSection]?
    let content: String?
}

struct SportSection: Decodable, Equatable {
    let category: String
    let content: String
}
