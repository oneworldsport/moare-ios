//
//  LeagueTitle.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/14/25.
//

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

//#Preview {
//    LeagueTitle()
//}
