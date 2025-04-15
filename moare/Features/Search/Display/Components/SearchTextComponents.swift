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
            
            // TODO: make season text to use util
            Text("\(leagueName) \(String(leagueSeason).suffix(2))/25")
                .fontWeight(.medium)
        }
    }
}

struct NBATitle: View {
    let leagueName: String
    let leagueSeason: Int
    
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
