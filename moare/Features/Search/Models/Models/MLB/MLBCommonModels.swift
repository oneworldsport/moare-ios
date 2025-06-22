//
//  MLBCommonModels.swift
//  moare
//
//  Created by Mohwa Yoon on 6/4/25.
//

import Foundation

struct MLBNameObj: Decodable, Equatable {
    private let _id: Int?
    private let _link: String?
    private let _name: String?

    var id: Int { _id ?? 0 }
    var link: String { _link ?? "" }
    var name: String { _name ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _link = "link"
        case _name = "name"
    }
}

struct MLBFullNameObj: Decodable, Equatable {
    private let _fullName: String?
    private let _id: Int?
    private let _link: String?

    var fullName: String { _fullName ?? "" }
    var id: Int { _id ?? 0 }
    var link: String { _link ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _fullName = "fullName"
        case _id = "id"
        case _link = "link"
    }
}

struct MLBCodeObj: Decodable, Equatable {
    private let _code: String?
    private let _description: String?

    var code: String { _code ?? "" }
    var description: String { _description ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _code = "code"
        case _description = "description"
    }
}

struct MLBAbbreviationIdObj: Decodable, Equatable {
    private let _abbreviation: String?
    private let _id: Int?
    private let _link: String?
    private let _name: String?

    var abbreviation: String { _abbreviation ?? "" }
    var id: Int { _id ?? 0 }
    var link: String { _link ?? "" }
    var name: String { _name ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _abbreviation = "abbreviation"
        case _id = "id"
        case _link = "link"
        case _name = "name"
    }
}

struct MLBAbbreviationCodeObj: Decodable, Equatable {
    private let _abbreviation: String?
    private let _code: String?
    private let _name: String?
    private let _type: String?

    var abbreviation: String { _abbreviation ?? "" }
    var code: String { _code ?? "" }
    var name: String { _name ?? "" }
    var type: String { _type ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _abbreviation = "abbreviation"
        case _code = "code"
        case _name = "name"
        case _type = "type"
    }
}

struct MLBLabelObj: Decodable, Equatable {
    private let _label: String?
    private let _value: String?

    var label: String { _label ?? "" }
    var value: String { _value ?? "" }

    private enum CodingKeys: String, CodingKey {
        case _label = "label"
        case _value = "value"
    }
}
