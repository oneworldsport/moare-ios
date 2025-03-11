//
//  FootballCommonModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/4/24.
//

import Foundation

struct FBPerson: Decodable, Equatable {
    private let _id: Int?
    private let _name: String?
    private let _photo: String?
    
    var id: Int {
        return _id ?? 0
    }
    var name: String {
        return _name ?? ""
    }
    var photo: String {
        return _photo ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _photo = "photo"
    }
}

struct FBTeamInfo: Decodable, Equatable {
    private let _id: Int?
    private let _name: String?
    private let _logo: String?
    private let _winner: Bool?
    private let _update: String?
    private let _code: String?
    private let _country: String?
    private let _founded: Int?
    private let _national: Bool?
    let colors: FBGameColors?
    
    var id: Int {
        return _id ?? 0
    }
    var name: String {
        return _name ?? ""
    }
    var logo: String {
        return _logo ?? ""
    }
    var winner: Bool {
        return _winner ?? false
    }
    var update: String {
        return _update ?? ""
    }
    var code: String {
        return _code ?? ""
    }
    var country: String {
        return _country ?? ""
    }
    var founded: Int {
        return _founded ?? 0
    }
    var national: Bool {
        return _national ?? false
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _logo = "logo"
        case _winner = "winner"
        case _update = "update"
        case _code = "code"
        case _country = "country"
        case _founded = "founded"
        case _national = "national"
        case colors
    }
}

struct FBVenue: Decodable, Equatable {
    private let _id: Int?
    private let _name: String?
    private let _address: String?
    private let _city: String?
    private let _capacity: Int?
    private let _surface: String?
    private let _image: String?
    
    var id: Int {
        return _id ?? 0
    }
    var name: String {
        return _name ?? ""
    }
    var address: String {
        return _address ?? ""
    }
    var city: String {
        return _city ?? ""
    }
    var capacity: Int {
        return _capacity ?? 0
    }
    var surface: String {
        return _surface ?? ""
    }
    var image: String {
        return _image ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _address = "address"
        case _city = "city"
        case _capacity = "capacity"
        case _surface = "surface"
        case _image = "image"
    }
}

struct FBLeague: Decodable, Equatable {
    private let _id: Int?
    private let _name: String?
    private let _country: String?
    private let _logo: String?
    private let _flag: String?
    private let _season: Int?
    private let _round: String?
    
    var id: Int {
        return _id ?? 0
    }
    var name: String {
        return _name ?? ""
    }
    var country: String {
        return _country ?? ""
    }
    var logo: String {
        return _logo ?? ""
    }
    var flag: String {
        return _flag ?? ""
    }
    var season: Int {
        return _season ?? 0
    }
    var round: String {
        return _round ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _country = "country"
        case _logo = "logo"
        case _flag = "flag"
        case _season = "season"
        case _round = "round"
    }
    
    // NOTE: 시즌이 String으로 오는 아이템이 딱 하나 있음...
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(Int.self, forKey: ._id)
        _name = try container.decodeIfPresent(String.self, forKey: ._name)
        _country = try container.decodeIfPresent(String.self, forKey: ._country)
        _logo = try container.decodeIfPresent(String.self, forKey: ._logo)
        _flag = try container.decodeIfPresent(String.self, forKey: ._flag)
        _round = try container.decodeIfPresent(String.self, forKey: ._round)
        
        // `_season` 값을 단일 값으로 처리
        if let seasonValue = try? container.decodeIfPresent(Int.self, forKey: ._season) {
            _season = seasonValue
        } else if let seasonValue = try? container.decodeIfPresent(String.self, forKey: ._season) {
            _season = Int(seasonValue) // String -> Int 변환
        } else {
            _season = nil // 값이 없는 경우
        }
    }
}

struct FBHomeAwayIntStats: Decodable, Equatable {
    private let _home: Int?
    private let _away: Int?
    private let _total: Int?
    
    var home: Int {
        return _home ?? 0
    }
    var away: Int {
        return _away ?? 0
    }
    var total: Int {
        return _total ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _home = "home"
        case _away = "away"
        case _total = "total"
    }
}

struct FBHomeAwayStringStats: Decodable, Equatable {
    private let _home: String?
    private let _away: String?
    private let _total: String?
    
    var home: String {
        return _home ?? ""
    }
    var away: String {
        return _away ?? ""
    }
    var total: String {
        return _total ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case _home = "home"
        case _away = "away"
        case _total = "total"
    }
}


