//
//  TextComponents.swift
//  moare
//
//  Created by Mohwa Yoon on 3/10/25.
//

import Foundation
import SwiftUI

struct LeagueTitle: View {
    let url: String
    let leagueName: String
    let leagueSeason: Int
    
    var body: some View {
        HStack(spacing: 0) {
            URLImage(url: url, size: .small)
                .padding(.trailing, 6)
            
//            Text("\(leagueName) \(String(leagueSeason).suffix(2))/25")
            Text("\(leagueName) \(String(leagueSeason))-\(String(leagueSeason + 1).suffix(2))")
                .fontWeight(.medium)
        }
    }
}

struct NBATitle: View {
    let leagueName: String
    let leagueSeason: Int
    
    init(leagueName: String, leagueSeason: Int?) {
        self.leagueName = leagueName
        self.leagueSeason = leagueSeason ?? CalendarUtil.currentYear
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Image("nba_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(.trailing, 6)
            
            Text("\(leagueName) \(leagueSeason)-\(String(leagueSeason + 1).suffix(2))")
                .fontWeight(.medium)
        }
    }
}

struct BaseballLeagueTitle: View {
    let logoUrl: String
    let name: String
    let season: Int
    
    init(logoUrl: String, name: String, season: Int?) {
        self.logoUrl = logoUrl
        self.name = name
        self.season = season ?? 2025
    }
    
    var body: some View {
        HStack(spacing: 0) {
            URLImage(
                url: logoUrl,
                size: .small,
                isSvg: logoUrl.contains(".svg")
            )
                .padding(.trailing, 6)
            
            Text("\(name) " + String(season))
                .fontWeight(.medium)
        }
    }
}
