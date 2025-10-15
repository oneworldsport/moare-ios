//
//  TextComponents.swift
//  moare
//
//  Created by Mohwa Yoon on 3/10/25.
//

import Foundation
import SwiftUI

struct FBLeagueTitle: View {
    let url: String
    let leagueName: String
    let leagueSeason: Int
    var logoCustomSize: CGSize? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            URLImage(url: url, size: .small, customSize: logoCustomSize)
                .padding(.trailing, 6)
        
            Text("\(leagueName) \(String(leagueSeason))-\(String(leagueSeason + 1).suffix(2))")
                .fontWeight(.medium)
        }
    }
}

struct FBLeagueTitleForGameStats: View {
    let url: String
    let leagueName: String
    let leagueSeason: Int
    let description: String
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                URLImage(url: url, customSize: CGSize(width: 23, height: 23))
                    .padding(.trailing, 4)
            
                Text("\(leagueName) \(String(leagueSeason))-\(String(leagueSeason + 1).suffix(2))")
                    .font(.system(size: 14))
            }
            
            Text(" - \(MatchDescriptionConverter.convert(descriptionType: .roundWithoutDash, input: description))")
                .font(.system(size: 14))
            
            Spacer()
        }
        .padding(.leading, UIConstants.Padding.defaultHPadding)
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
                size: .small
            )
            .padding(.trailing, 6)
            
            Text("\(name) " + String(season))
                .fontWeight(.medium)
        }
    }
}

struct BaseballLeagueTitleForGameStats: View {
    let logoUrl: String
    let name: String
    let season: Int
    let seriesDescription: String
    
    init(logoUrl: String, name: String, season: Int?, seriesDescription: String = "") {
        self.logoUrl = logoUrl
        self.name = name
        self.season = season ?? CalendarUtil.currentYear
        self.seriesDescription = seriesDescription
    }
    
    var body: some View {
        HStack(spacing: 0) {
            URLImage(url: logoUrl, customSize: CGSize(width: 23, height: 23))
                .padding(.trailing, 4)
        
            Text("\(name) " + String(season))
                .font(.system(size: 14))
            
            if !seriesDescription.isEmpty {
                Text(" - \(seriesDescription)")
                    .font(.system(size: 14))
            }
            
            Spacer()
        }
        .padding(.leading, UIConstants.Padding.defaultHPadding)
    }
}
