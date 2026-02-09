//
//  TennisCommonModels.swift
//  moare
//
//  Created by Mohwa Yoon on 1/28/26.
//

struct TennisCountry: Decodable, Equatable {
    private let _alpha3: String?
    private let _name: String?
    private let _slug: String?
    
    var alpha3: String { _alpha3 ?? "" }
    var name: String { _name ?? "" }
    var slug: String { _slug ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case _alpha3 = "alpha3"
        case _name = "name"
        case _slug = "slug"
    }
}

struct TennisName: Decodable, Equatable {
    private let _name: String?
    
    var name: String { _name ?? "" }
    
    private enum CodingKeys: String, CodingKey {
        case _name = "name"
    }
}
