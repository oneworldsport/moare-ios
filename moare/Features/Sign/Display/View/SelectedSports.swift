//
//  SelectedSports.swift
//  moare
//
//  Created by Mohwa Yoon on 11/10/25.
//

import SwiftUI

struct SelectedSports: View {
    let sports: [String]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(sports, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 16))
                        .foregroundStyle(.moare)
                }
            }
            .frame(height: 50)
        }
    }
    
}

#Preview {
    SelectedSports(sports: ["축구", "야구", "농구"])
}
