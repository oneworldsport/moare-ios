//
//  SportList.swift
//  moare
//
//  Created by Mohwa Yoon on 11/10/25.
//

import SwiftUI

struct SportList: View {
    private let sports = ["축구", "야구", "농구", "테니스", "F1", "배구", "골프"]
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    let selectedSports: [String]
    let onItemSelect: (String) -> ()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(sports, id: \.self) { item in
                    Button(action: {
                        onItemSelect(item)
                    }) {
                        VStack(spacing: 0) {
                            HCapsuleBar(color: .secondary)
                                .opacity(selectedSports.contains(item) ? 0 : 0.8)
                            
                            Text(item)
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal, 20)
                    }
                    .overlay {
                        if selectedSports.contains(item) {
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(.moare, lineWidth: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(KeywordButtonStyle())
                }
            }
            .padding()
        }
    }
}

//#Preview {
//    SportList(selectedSports: ["축구", "야구"], onItemSelected: {})
//}
