//
//  LeagueKeywords.swift
//  moare
//
//  Created by Mohwa Yoon on 1/21/26.
//

import SwiftUI

struct LeagueKeywordsList: View {
    let leagueKeywords: LeagueKeywords
    
    let onItemSelected: (KeywordInfo) -> ()
    
    @State private var liveHeight: CGFloat = 0
    @State private var recentHeight: CGFloat = 0
    
    private var height: CGFloat {
        max(liveHeight, recentHeight)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack {
                HCapsuleBar()
                
                HStack {
                    Circle()
                        .fill(.moare)
                        .frame(width: 10, height: 10)
                        .keyframeAnimator(
                            initialValue: 1.0,
                            repeating: true
                        ) { content, alpha in
                            content.opacity(alpha)
                        } keyframes: { _ in
                            KeyframeTrack {
                                LinearKeyframe(1.0, duration: 0.5)  // 0~500ms 유지
                                LinearKeyframe(0.0, duration: 0.7)  // 500~1200ms 1->0
                                LinearKeyframe(1.0, duration: 0.7)  // 1200~1900ms 0->1
                                LinearKeyframe(1.0, duration: 0.5)  // 1900~2400ms 유지
                            }
                        }
                    
                    Text("경기중")
                }
                
                ScrollView {
                    VStack {
                        ForEach(Array(leagueKeywords.live.enumerated()), id: \.offset) { _, value in
                            KeywordItem(keyword: value.keyword) {
                                onItemSelected(value)
                            }
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { liveHeight = min(proxy.size.height, 150) }
                                .onChange(of: proxy.size.height) { liveHeight = min(proxy.size.height, 150) }
                        }
                    )
                }
                .frame(height: height)
            }
            
            VStack {
                HCapsuleBar()
                
                Text("최근 결과")
                
                ScrollView {
                    VStack {
                        ForEach(Array(leagueKeywords.recent.enumerated()), id: \.offset) { _, value in
                            KeywordItem(keyword: value.keyword) {
                                onItemSelected(value)
                            }
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { recentHeight = min(proxy.size.height, 150) }
                                .onChange(of: proxy.size.height) { recentHeight = min(proxy.size.height, 150) }
                        }
                    )
                }
                .frame(height: height)
            }
        }
    }
}
