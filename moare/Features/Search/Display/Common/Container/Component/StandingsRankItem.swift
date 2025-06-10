//
//  StandingsRankItem.swift
//  moare
//
//  Created by Mohwa Yoon on 6/9/25.
//

import SwiftUI

struct StandingsRankItem: View {
    let rank: Int
    let imageUrl: String?
    let isSvgLogo: Bool
    let name: String
    let subName: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text("\(rank)")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 28)

                URLImage(url: imageUrl, customSize: CGSize(width: 25, height: 25), isSvg: isSvgLogo)
                    .padding(.leading, 4)
                    .padding(.trailing, 6)

                VStack(spacing: 2) {
                    Text(name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12))
                        .lineLimit(1)
                    
                    if let subName {
                        Text(subName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Rectangle()
                    .frame(width: 2)
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
            }
            .padding(.leading, 10)
        }
        .foregroundStyle(.primary)
        .frame(width: 132)
    }
}
