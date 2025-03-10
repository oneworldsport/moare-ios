//
//  FootballPlayer.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 11/10/24.
//

import Foundation

struct FBPlayer: Decodable, Equatable {
    let player: FBPlayerInfo
    var statistics: [FBPlayerStats] = []
}

struct FBPlayerInfo: Decodable, Equatable {
    private let _id: Int?
    private let _name: String?
    private let _krname: String?
    private let _firstname: String?
    private let _lastname: String?
    private let _age: Int?
    let birth: FBPlayerBirth
    private let _nationality: String?
    private let _height: String?
    private let _weight: String?
    private let _injured: Bool?
    private let _photo: String?
    
    var id: Int {
        return _id ?? 0
    }
    var name: String {
        return _name ?? ""
    }
    var krname: String {
        return _krname ?? ""
    }
    var firstname: String {
        return _firstname ?? ""
    }
    var lastname: String {
        return _lastname ?? ""
    }
    var age: Int {
        return _age ?? 0
    }
    var nationality: String {
        return _nationality ?? ""
    }
    var height: String {
        return _height ?? ""
    }
    var weight: String {
        return _weight ?? ""
    }
    var injured: Bool {
        return _injured ?? false
    }
    var photo: String {
        return _photo ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _krname = "krname"
        case _firstname = "firstname"
        case _lastname = "lastname"
        case _age = "age"
        case birth
        case _nationality = "nationality"
        case _height = "height"
        case _weight = "weight"
        case _injured = "injured"
        case _photo = "photo"
    }
}

struct FBPlayerBirth: Decodable, Equatable {
    private let _date: String?
    private let _place: String?
    private let _country: String?
    
    var date: String {
        return _date ?? ""
    }
    var place: String {
        return _place ?? ""
    }
    var country: String {
        return _country ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case _date = "date"
        case _place = "place"
        case _country = "country"
    }
}


struct FBPlayerStats: Decodable, Equatable {
    let team: FBTeamInfo
    let league: FBLeague
    let games: FBPlayerStatsGames
    let substitutes: FBPlayerStatsSubstitutes
    let shots: FBPlayerStatsShots
    let goals: FBPlayerStatsGoals
    let passes: FBPlayerStatsPasses
    let tackles: FBPlayerStatsTackles
    let duels: FBPlayerStatsDuels
    let dribbles: FBPlayerStatsDribbles
    let fouls: FBPlayerStatsFouls
    let cards: FBPlayerStatsCards
    let penalty: FBPlayerStatsPenalty
}

struct FBPlayerStatsGames: Decodable, Equatable {
    private let _appearences: Int?
    private let _lineups: Int?
    private let _minutes: Int?
    private let _number: Int?
    private let _position: String?
    private let _rating: String?
    private let _captain: Bool?
    
    var appearences: Int {
        return _appearences ?? 0
    }
    var lineups: Int {
        return _lineups ?? 0
    }
    var minutes: Int {
        return _minutes ?? 0
    }
    var number: Int {
        return _number ?? 0
    }
    var position: String {
        return _position ?? ""
    }
    var rating: String {
        return _rating ?? "0"
    }
    var captain: Bool {
        return _captain ?? false
    }
    
    private enum CodingKeys: String, CodingKey {
        case _appearences = "appearences"
        case _lineups = "lineups"
        case _minutes = "minutes"
        case _number = "number"
        case _position = "position"
        case _rating = "rating"
        case _captain = "captain"
    }
}

struct FBPlayerStatsSubstitutes: Decodable, Equatable {
    private let _substituteIn: Int?
    private let _substituteOut: Int?
    private let _bench: Int?
    
    var substituteIn: Int {
        return _substituteIn ?? 0
    }
    var substituteOut: Int {
        return _substituteOut ?? 0
    }
    var bench: Int {
        return _bench ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _substituteIn = "in"
        case _substituteOut = "out"
        case _bench = "bench"
    }
}

struct FBPlayerStatsShots: Decodable, Equatable {
    private let _total: Int?
    private let _on: Int?
    
    var total: Int {
        return _total ?? 0
    }
    var on: Int {
        return _on ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _total = "total"
        case _on = "on"
    }
    
    init(total: Int = 0, on: Int = 0) {
        self._total = total
        self._on = on
    }
}

struct FBPlayerStatsGoals: Decodable, Equatable {
    private let _total: Int?
    private let _conceded: Int?
    private let _assists: Int?
    private let _saves: Int?
    
    var total: Int {
        return _total ?? 0
    }
    var conceded: Int {
        return _conceded ?? 0
    }
    var assists: Int {
        return _assists ?? 0
    }
    var saves: Int {
        return _saves ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _total = "total"
        case _conceded = "conceded"
        case _assists = "assists"
        case _saves = "saves"
    }
    
    init(total: Int = 0, conceded: Int = 0, assists: Int = 0, saves: Int = 0) {
        self._total = total
        self._conceded = conceded
        self._assists = assists
        self._saves = saves
    }
}

struct FBPlayerStatsPasses: Decodable, Equatable {
    private let _total: Int?
    private let _key: Int?
    private let _accuracy: Int?
    
    var total: Int {
        return _total ?? 0
    }
    var key: Int {
        return _key ?? 0
    }
    var accuracy: Int {
        return _accuracy ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _total = "total"
        case _key = "key"
        case _accuracy = "accuracy"
    }
    
    init(total: Int = 0, key: Int = 0, accuracy: Int = 0) {
        self._total = total
        self._key = key
        self._accuracy = accuracy
    }
}

struct FBPlayerStatsTackles: Decodable, Equatable {
    private let _total: Int?
    private let _blocks: Int?
    private let _interceptions: Int?
    
    var total: Int {
        return _total ?? 0
    }
    var blocks: Int {
        return _blocks ?? 0
    }
    var interceptions: Int {
        return _interceptions ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _total = "total"
        case _blocks = "blocks"
        case _interceptions = "interceptions"
    }
    
    init(total: Int = 0, blocks: Int? = nil, interceptions: Int = 0) {
        self._total = total
        self._blocks = blocks
        self._interceptions = interceptions
    }
}

struct FBPlayerStatsDuels: Decodable, Equatable {
    private let _total: Int?
    private let _won: Int?
    
    var total: Int {
        return _total ?? 0
    }
    var won: Int {
        return _won ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _total = "total"
        case _won = "won"
    }
    
    init(total: Int = 0, won: Int = 0) {
        self._total = total
        self._won = won
    }
}

struct FBPlayerStatsDribbles: Decodable, Equatable {
    private let _attempts: Int?
    private let _success: Int?
    private let _past: Int?
    
    var attempts: Int {
        return _attempts ?? 0
    }
    var success: Int {
        return _success ?? 0
    }
    var past: Int {
        return _past ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _attempts = "attempts"
        case _success = "success"
        case _past = "past"
    }
    
    init(attempts: Int = 0, success: Int = 0, past: Int? = nil) {
        self._attempts = attempts
        self._success = success
        self._past = past
    }
}

struct FBPlayerStatsFouls: Decodable, Equatable {
    private let _drawn: Int?
    private let _committed: Int?
    
    var drawn: Int {
        return _drawn ?? 0
    }
    var committed: Int {
        return _committed ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _drawn = "drawn"
        case _committed = "committed"
    }
    
    init(drawn: Int = 0, committed: Int = 0) {
        self._drawn = drawn
        self._committed = committed
    }
}

struct FBPlayerStatsCards: Decodable, Equatable {
    private let _yellow: Int?
    private let _yellowred: Int?
    private let _red: Int?
    
    var yellow: Int {
        return _yellow ?? 0
    }
    var yellowred: Int {
        return _yellowred ?? 0
    }
    var red: Int {
        return _red ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _yellow = "yellow"
        case _yellowred = "yellowred"
        case _red = "red"
    }
    
    init(yellow: Int = 0, yellowred: Int? = nil, red: Int = 0) {
        self._yellow = yellow
        self._yellowred = yellowred
        self._red = red
    }
}

struct FBPlayerStatsPenalty: Decodable, Equatable {
    private let _won: Int?
    private let _commited: Int?
    private let _scored: Int?
    private let _missed: Int?
    private let _saved: Int?
    
    var won: Int {
        return _won ?? 0
    }
    var commited: Int {
        return _commited ?? 0
    }
    var scored: Int {
        return _scored ?? 0
    }
    var missed: Int {
        return _missed ?? 0
    }
    var saved: Int {
        return _saved ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case _won = "won"
        case _commited = "commited"
        case _scored = "scored"
        case _missed = "missed"
        case _saved = "saved"
    }
    
    init(won: Int? = nil, commited: Int? = nil, scored: Int = 0, missed: Int? = nil, saved: Int? = nil) {
        self._won = won
        self._commited = commited
        self._scored = scored
        self._missed = missed
        self._saved = saved
    }
}

