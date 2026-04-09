//
//  NBAUtil.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import Foundation

struct KBOUtil {
    static let codeMap: [Int: String] = [
        1: "OB",
        2: "LT",
        3: "SS",
        4: "HH",
        5: "LG",
        6: "HT",
        7: "WO",
        8: "NC",
        9: "KT",
        10: "SK"
    ]
    static let kboLogoUrl = "https://6ptotvmi5753.edge.naverncp.com/KBO_IMAGE/KBOHome/resources/images/common/h1_logo.png"
    

    static func playerPhotoURL(season: Int, id: Int?) -> String? {
        if let id {
            return "https://6ptotvmi5753.edge.naverncp.com/KBO_IMAGE/person/middle/\(season)/\(id).jpg"
        } else {
            return nil
        }
    }
    
    static func teamLogoURL(id: Int?) -> String? {
        if let id, let code = codeMap[id] {
            return "https://6ptotvmi5753.edge.naverncp.com/KBO_IMAGE/emblem/regular/fixed/emblem_\(code).png"
        } else {
            return nil
        }
    }
    
    static func getFullYear(fromYear: String) -> Int {
        let digits = fromYear.filter { $0.isNumber }
        guard let num = Int(digits) else { return 2025 }
        return 2000 + num
    }

    static func calculateYear(fromYear: String) -> Int {
        return 2025 - getFullYear(fromYear: fromYear) + 1
    }

    static func formatMoney(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        guard let num = Int(digits) else { return input }

        let eok = num / 10000          // 억 단위
        let cheon = (num % 10000) / 1000  // 천 단위

        if eok > 0 && cheon > 0 {
            return "\(eok)억 \(cheon)천만원"
        } else if eok > 0 {
            return "\(eok)억원"
        } else if cheon > 0 {
            return "\(cheon)천만원"
        } else {
            return "\(num)만원"
        }
    }
}
