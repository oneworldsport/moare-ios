//
//  DynamicCodableValue.swift
//  moare
//
//  Created by 최지혜 on 8/20/25.
//
import Foundation

enum DynamicCodableValue: Codable, Equatable {
    case boolValue(Bool)
    case intValue(Int)
    case doubleValue(Double)
    case stringValue(String)
    case arrayValue([DynamicCodableValue])
    case objectValue([String: DynamicCodableValue])
    case none

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolValue = try? container.decode(Bool.self) {
            self = .boolValue(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .intValue(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .doubleValue(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .stringValue(stringValue)
        } else if let arrayValue = try? container.decode([DynamicCodableValue].self) {
            self = .arrayValue(arrayValue)
        } else if let objectValue = try? container.decode([String: DynamicCodableValue].self) {
            self = .objectValue(objectValue)
        } else {
            self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .boolValue(let boolValue):
            try container.encode(boolValue)
        case .intValue(let intValue):
            try container.encode(intValue)
        case .doubleValue(let doubleValue):
            try container.encode(doubleValue)
        case .stringValue(let stringValue):
            try container.encode(stringValue)
        case .arrayValue(let arrayValue):
            try container.encode(arrayValue)
        case .objectValue(let objectValue):
            try container.encode(objectValue)
        case .none:
            try container.encodeNil()
        }
    }
    
    fileprivate func bridge() -> Any {
            switch self {
            case .none:                      return NSNull()
            case .boolValue(let b):          return b
            case .intValue(let i):           return i
            case .doubleValue(let d):        return d
            case .stringValue(let s):        return s
            case .arrayValue(let a):         return a.map { $0.bridge() }
            case .objectValue(let o):        return o.mapValues { $0.bridge() }
            }
        }

        /// DynamicCodableValue → JSON Data
        func toData() throws -> Data {
            try JSONSerialization.data(withJSONObject: bridge(), options: [])
        }

        /// 원하는 Decodable 모델로 바로 디코딩
        func decode<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
            try decoder.decode(T.self, from: toData())
        }
}
