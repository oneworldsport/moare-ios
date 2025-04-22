//
//  NBAUtil.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import Foundation

struct NBAUtil {
    static func translateEastWest(input: String) -> String {
        return if input.lowercased() == "east" {
            "동부"
        } else if input.lowercased() == "west" {
            "서부"
        } else {
            input
        }
    }
    
    static func playerPhotoURL(id: Int?) -> String? {
        if let id {
            return "https://cdn.nba.com/headshots/nba/latest/1040x760/\(id).png"
        } else {
            return nil
        }
    }
    
    static func teamLogoURL(id: Int?) -> String? {
        if let id {
            return "https://cdn.nba.com/logos/nba/\(id)/primary/L/logo.svg"
        } else {
            return nil
        }
    }
    
    // TODO: 다른곳에서 다시 정리 필요
    static func toCm(feet: Int, inches: Int, decimalPlaces: Int = 0) -> Double {
        let totalInches = feet * 12 + inches
        return (Double(totalInches) * 2.54).rounded(to: decimalPlaces)
    }
}
