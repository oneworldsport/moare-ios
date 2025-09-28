//
//  NoticeModel.swift
//  moare
//
//  Created by Mohwa Yoon on 4/15/25.
//

struct NoticeModel: Decodable {
    let title: String
    let sports: [SportSection]?
    let content: String?
}

struct SportSection: Decodable {
    let category: String
    let content: String
}
