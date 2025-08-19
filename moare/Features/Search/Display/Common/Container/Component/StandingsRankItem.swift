//
//  StandingsRankItem.swift
//  moare
//
//  Created by Mohwa Yoon on 6/9/25.
//

import SwiftUI

struct StandingsRankItem: View {
    let id: Int = 0
    let isGameStats: Bool
    let rank: Int
    let imageUrl: String?
    let isSvgLogo: Bool
    let name: String
    let subName: String?
    let extraInfo: String?
    let extraSubInfo: String?
    let action: (Int) -> Void
    
    init(
        isGameStats: Bool = false,
        rank: Int = 0,
        imageUrl: String?,
        isSvgLogo: Bool = false,
        name: String,
        subName: String? = nil,
        extraInfo: String? = nil,
        extraSubInfo: String? = nil,
        action: @escaping (Int) -> Void
    ) {
        self.isGameStats = isGameStats
        self.rank = rank
        self.imageUrl = imageUrl
        self.isSvgLogo = isSvgLogo
        self.name = name
        self.subName = subName
        self.extraInfo = extraInfo
        self.extraSubInfo = extraSubInfo
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if id != 0 {
                action(id)
            }
        }) {
            HStack(spacing: 0) {
                if !isGameStats {
                    Text("\(rank)")
                        .font(.system(size: 15, weight: .medium))
                        .frame(width: 28)
                }

                URLImage(url: imageUrl, customSize: CGSize(width: 25, height: 25), isSvg: isSvgLogo)
                    .padding(.leading, 4)
                    .padding(.trailing, 6)

                if isGameStats {
                    Text(name)
                        .font(.system(size: 12))
                        .lineLimit(2)
                        .frame(maxWidth: 80, alignment: .leading)
                    
                    // TODO: goals, cards, number, captain
                    VStack(spacing: 0) {
                        Text(extraInfo ?? "")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
//                            .opacity(!data.position.isEmpty ? 1 : 0.7)
                        
                        Text(extraSubInfo ?? "")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .opacity(0.7)
                    }
                    .frame(maxWidth: 20)
                    .padding(.leading, 2)

                    Spacer()
                } else {
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
