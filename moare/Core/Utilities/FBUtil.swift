//
//  FBUtil.swift
//  moare
//
//  Created by Mohwa Yoon on 6/20/25.
//

struct FBUtil {
    static func teamLogoURL(id: Int?) -> String? {
        if let id {
            return "https://media.api-sports.io/football/teams/\(id).png"
        } else {
            return nil
        }
    }
    
}
