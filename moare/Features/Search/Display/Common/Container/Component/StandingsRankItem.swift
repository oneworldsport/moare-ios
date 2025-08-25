//
//  StandingsRankItem.swift
//  moare
//
//  Created by Mohwa Yoon on 6/9/25.
//

import SwiftUI

struct StandingsRankItem: View {
    let id: Int
    let width: CGFloat
    let shouldShowRank: Bool
    let shouldShowExtraInfo: Bool
    let rank: Int
    let imageUrl: String?
    let name: String
    let subName: String?
    let extraInfo: String?
    let extraSubInfo: String?
    let action: (Int) -> Void
    
    init(
        id: Int = 0,
        width: CGFloat? = nil,
        shouldShowRank: Bool = true,
        shouldShowExtraInfo: Bool = false,
        rank: Int = 0,
        imageUrl: String?,
        name: String,
        subName: String? = nil,
        extraInfo: String? = nil,
        extraSubInfo: String? = nil,
        action: @escaping (Int) -> Void
    ) {
        self.id = id
        self.width = width ?? 132
        self.shouldShowRank = shouldShowRank
        self.shouldShowExtraInfo = shouldShowExtraInfo
        self.rank = rank
        self.imageUrl = imageUrl
        self.name = name
        self.subName = subName
        self.extraInfo = extraInfo
        self.extraSubInfo = extraSubInfo
        self.action = action
    }
    
    var body: some View {
        let rankWidth: CGFloat = {
           if rank >= 100 {
                return 30
            } else if rank >= 10 {
                return 22
            } else {
                return 15
            }
        }()
        
        Button(action: {
            if id != 0 {
                action(id)
            }
        }) {
            HStack(spacing: 0) {
                if shouldShowRank {
                    Text("\(rank)")
                        .font(.system(size: 15, weight: .medium))
                        .frame(width: rankWidth)
                }

                URLImage(url: imageUrl, customSize: CGSize(width: 25, height: 25))
                    .padding(.trailing, 6)

                if shouldShowExtraInfo {
                    Text(name)
                        .font(.system(size: 12))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    
                    // TODO: goals, cards, number, captain
                    VStack(spacing: 0) {
                        if let extraInfo {
                            Text(extraInfo)
                                .font(.system(size: 11))
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
    //                            .opacity(!data.position.isEmpty ? 1 : 0.7)
                        }
                        
                        if let extraSubInfo {
                            Text(extraSubInfo)
                                .font(.system(size: 11))
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                                .opacity(0.7)
                        }
                    }
                    .frame(width: (extraInfo != nil || extraSubInfo != nil) ? (width - 102) : 0)
                    .padding(.leading, 2)

                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        Text(name)
                            .font(.system(size: 12))
                            .lineLimit(1)
                        
                        if let subName {
                            Text(subName)
                                .font(.system(size: 11, weight: .light))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VCapsuleBar()
                    .opacity(0.5)
            }
            .padding(.leading, 8)
        }
        .foregroundStyle(.primary)
        .frame(width: width, height: 40)
    }
}
