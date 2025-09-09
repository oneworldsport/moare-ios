//
//  MoatItem.swift
//  moare
//
//  Created by Mohwa Yoon on 9/6/25.
//

import SwiftUI

enum MoatType {
    case timeline, detail, comment, userProfile
}

struct MoatItem: View {
    let moatType: MoatType
    let isButtonDisabled: Bool
    let title: String?
    let content: String
    let hashtagList: [String]?
    let fireCount: Int
    let commentCount: Int
    let profileImageURL: String
    let nickname: String
    let timeAgo: String
    let action: () -> Void
    
    let height: CGFloat
    let titleFontSize: CGFloat
    let contentFontSize: CGFloat
    let profileImageSize: CGFloat
    let nicknameFontSize: CGFloat
    let timeFontSize: CGFloat
    let iconFontSize: CGFloat
    let iconCountFontSize: CGFloat
    
    @State private var isSideBarShowing: Bool = true
    
    init(
        moatType: MoatType = .timeline,
        isButtonDisabled: Bool = false,
        title: String? = nil,
        content: String,
        hashtagList: [String]?,
        fireCount: Int,
        commentCount: Int,
        profileImageURL: String = "",
        nickname: String,
        createdAt: String,
        action: @escaping () -> Void = {}
    ) {
        self.moatType = moatType
        self.isButtonDisabled = isButtonDisabled
        self.title = moatType == .comment ? nil : title
        self.content = content
        self.hashtagList = hashtagList
        self.fireCount = fireCount
        self.commentCount = commentCount
        self.profileImageURL = profileImageURL
        self.nickname = nickname
        self.timeAgo = CalendarUtil.timeAgoString(from: createdAt)
        self.action = action
        
        switch moatType {
        case .timeline:
            self.height = 100
            self.titleFontSize = 18
            self.contentFontSize = 18
            self.profileImageSize = 25
            self.nicknameFontSize = 16
            self.timeFontSize = 15
            self.iconFontSize = 17
            self.iconCountFontSize = 12
        case .detail:
            self.height = 160
            self.titleFontSize = 18
            self.contentFontSize = 16
            self.profileImageSize = 25
            self.nicknameFontSize = 16
            self.timeFontSize = 15
            self.iconFontSize = 17
            self.iconCountFontSize = 12
        case .comment:
            self.height = 80
            self.titleFontSize = 18
            self.contentFontSize = 16
            self.profileImageSize = 20
            self.nicknameFontSize = 15
            self.timeFontSize = 14
            self.iconFontSize = 16
            self.iconCountFontSize = 11
        case .userProfile:
            self.height = 80
            self.titleFontSize = 17
            self.contentFontSize = 18
            self.profileImageSize = 25
            self.nicknameFontSize = 16
            self.timeFontSize = 14
            self.iconFontSize = 16
            self.iconCountFontSize = 11
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isSideBarShowing {
                    MoatItemSideBar(isLeft: true, height: height)
                        .transition(.move(edge: .leading))
                }
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            if let title {
                                // NOTE: detail 제외하고는 전체 높이의 가운데에 위치
                                HStack {
                                    Text(title)
                                        .font(.system(size: titleFontSize, weight: .medium))
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxHeight: moatType == .detail ? nil : .infinity)
                            }
                            
                            if moatType == .detail || moatType == .comment {
                                // NOTE: comment에서는 전체 높이의 가운데에 위치
                                Text(content)
                                    .font(.system(size: contentFontSize))
                                    .frame(maxHeight: moatType == .detail ? nil : .infinity)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            if moatType != .comment {
                                // NOTE: detail에서는 title과 content를 최대한 위로
                                if moatType == .detail {
                                    Spacer()
                                }
                                
                                HStack {
                                    if let hashtagList {
                                        ForEach(hashtagList, id: \.self) { item in
                                            Text(item)
                                                .font(.system(size: 14))
                                                .foregroundStyle(.moare)
                                        }
                                    }
                                    
                                    if moatType == .userProfile {
                                        Spacer()
                                        Text(timeAgo)
                                            .font(.system(size: timeFontSize))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        // TODO: comment일때 실제 내부 높이는(time까지 합쳐서) height(80) 넘음
                        VStack(spacing: 0) {
                            VStack(spacing: 0) {
                                Text("🔥")
                                    .font(.system(size: iconFontSize))
                                    .padding(.bottom, 2)
                                
                                Text("\(fireCount)")
                                    .font(.system(size: iconCountFontSize))
                            }
                            .padding(.bottom, moatType == .detail ? 8 : 4)
                            
                            VStack(spacing: 0) {
                                Image(systemName: "bubble.left")
                                    .font(.system(size: iconFontSize))
                                    .padding(.bottom, 2)
                                
                                Text("\(commentCount)")
                                    .font(.system(size: iconCountFontSize))
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    
                    if moatType != .userProfile {
                        HStack {
                            Circle()
                                .fill(.moare)
                                .frame(width: profileImageSize, height: profileImageSize)
                            
                            Text(nickname)
                                .font(.system(size: nicknameFontSize))
                            
                            Spacer()
                            
                            Text(timeAgo)
                                .font(.system(size: timeFontSize))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                
                if isSideBarShowing {
                    MoatItemSideBar(isLeft: false, height: height)
                        .transition(.move(edge: .trailing))
                }
            }
        }
        .disabled(isButtonDisabled)
        .frame(height: height)
        .foregroundStyle(.primary)
        .padding(.horizontal, 8)
        .onChange(of: moatType) {
            if moatType == .detail {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isSideBarShowing = false
                }
            }
        }
    }
}

struct MoatItemSideBar: View {
    let isLeft: Bool
    let height: CGFloat
    
    let width: CGFloat = 10
    let radius: CGFloat = 10
    let degree: CGFloat = 60
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: isLeft ? width : 0, y: height + 10))
            
            path.addArc(center: CGPoint(x: isLeft ? radius : width - radius, y: height - radius),
                        radius: radius,
                        startAngle: Angle(degrees: isLeft ? 90 + degree : 90 - degree),
                        endAngle: Angle(degrees: isLeft ? 180 : 0),
                        clockwise: !isLeft)
            
            path.addArc(center: CGPoint(x: isLeft ? radius : width - radius, y: radius),
                        radius: radius,
                        startAngle: Angle(degrees: isLeft ? 180 : 0),
                        endAngle: Angle(degrees: isLeft ? 270 - degree : 270 + degree),
                        clockwise: !isLeft)
            
            path.addLine(to: CGPoint(x: isLeft ? width : 0, y: -10))
        }
        .stroke(.moare, style: StrokeStyle(lineWidth: 2, lineCap: .round))
        .frame(width: width, height: height)
    }
}


//#Preview {
//    MoatItem()
//}
