//
//  MoatItem.swift
//  moare
//
//  Created by Mohwa Yoon on 9/6/25.
//

import SwiftUI

enum MoatType {
    case trending, detail, comment, userProfile
}

struct MoatItem: View {    
    let userId: String?
    let moatUserId: String
    let moatType: MoatType
    let isButtonDisabled: Bool
    let title: String?
    let content: String
    let hashtagList: [String]?
    let fired: Bool
    let fireCount: Int
    let commentCount: Int
    let profileImageURL: String
    let userHandle: String
    let timeAgo: String
    let settingsTapped: (MoatSettingItems) -> Void
    let fireTapped: () -> Void
    let profileTapped: () -> Void
    let action: () -> Void
    
    let height: CGFloat
    let titleFontSize: CGFloat
    let contentFontSize: CGFloat
    let profileImageSize: CGFloat
    let userHandleFontSize: CGFloat
    let timeFontSize: CGFloat
    let iconFontSize: CGFloat
    let iconCountFontSize: CGFloat
    
    @State private var isSideBarShowing: Bool = true
    
    init(
        userId: String?,
        moatUserId: String,
        moatType: MoatType = .trending,
        isButtonDisabled: Bool = false,
        title: String? = nil,
        content: String,
        hashtagList: [String]?,
        fired: Bool,
        fireCount: Int,
        commentCount: Int,
        profileImageURL: String = "",
        userHandle: String,
        createdAt: String,
        settingsTapped: @escaping (MoatSettingItems) -> Void = {_ in },
        fireTapped: @escaping () -> Void = {},
        profileTapped: @escaping () -> Void = {},
        action: @escaping () -> Void = {}
    ) {
        self.userId = userId
        self.moatUserId = moatUserId
        self.moatType = moatType
        self.isButtonDisabled = isButtonDisabled
        self.title = moatType == .comment ? nil : title
        self.content = content
        self.hashtagList = hashtagList
        self.fired = fired
        self.fireCount = fireCount
        self.commentCount = commentCount
        self.profileImageURL = profileImageURL
        self.userHandle = userHandle
        self.timeAgo = CalendarUtil.timeAgoString(from: createdAt)
        self.settingsTapped = settingsTapped
        self.fireTapped = fireTapped
        self.profileTapped = profileTapped
        self.action = action
        
        switch moatType {
        case .trending:
            self.height = 100
            self.titleFontSize = 18
            self.contentFontSize = 18
            self.profileImageSize = 25
            self.userHandleFontSize = 16
            self.timeFontSize = 15
            self.iconFontSize = 17
            self.iconCountFontSize = 12
        case .detail:
            self.height = 160
            self.titleFontSize = 18
            self.contentFontSize = 16
            self.profileImageSize = 25
            self.userHandleFontSize = 16
            self.timeFontSize = 15
            self.iconFontSize = 17
            self.iconCountFontSize = 12
        case .comment:
            self.height = 80
            self.titleFontSize = 18
            self.contentFontSize = 16
            self.profileImageSize = 20
            self.userHandleFontSize = 15
            self.timeFontSize = 14
            self.iconFontSize = 16
            self.iconCountFontSize = 11
        case .userProfile:
            self.height = 80
            self.titleFontSize = 17
            self.contentFontSize = 18
            self.profileImageSize = 25
            self.userHandleFontSize = 16
            self.timeFontSize = 14
            self.iconFontSize = 16
            self.iconCountFontSize = 11
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                                        .lineLimit(2)
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
                                        let appendHashtag = hashtagList.map { tag in
                                            tag.hasPrefix("#") ? tag : "# " + tag
                                        }
                                        
                                        ForEach(appendHashtag, id: \.self) { item in
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
                            if moatType == .detail {
                                let isOwner = (userId == moatUserId)
                                
                                let itemsToShow: [MoatSettingItems] = {
                                    if isOwner {
                                        // 내 모트: 수정/삭제만 보이기
                                        return [.updateMoat, .deleteMoat]
                                    } else {
                                        // 남의 모트: 신고만 보이기
                                        return [.report]
                                    }
                                }()
                                
                                VStack(spacing: 0) {
                                    Menu {
                                        ForEach(itemsToShow, id: \.self) { item in
                                            Button(action: {
                                                settingsTapped(item)
                                            }) {
                                                Text("\(item.title)")
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .frame(width: 24, height: 24) // TODO: 나중에 fire랑 통일
                                            .font(.system(size: iconFontSize))
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 0) {
                                Image(systemName: fired ? "flame.fill" : "flame")
                                    .font(.system(size: iconFontSize))
                                    .padding(.bottom, 2)
                                    .onTapGesture {
                                        fireTapped()
                                    }
                                
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
                            HStack {
                                Circle()
                                    .fill(.moare)
                                    .frame(width: profileImageSize, height: profileImageSize)
                                
                                Text(userHandle)
                                    .font(.system(size: userHandleFontSize))
                            }.onTapGesture {
                                profileTapped()
                            }
                            
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
//        .disabled(isButtonDisabled)
        .frame(height: height)
        .contentShape(Rectangle()) // Button에서 Vstack으로 바꿔서 추가
        .optionalClickable(moatType != MoatType.detail, onTap: action)
        .foregroundStyle(.primary)
        .padding(.horizontal, 8)
        .onChange(of: moatType) { // 이거 생각해야됨
            if moatType == .detail {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isSideBarShowing = false
                }
            } else {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isSideBarShowing = true
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

struct DeletedMoatItem: View {
    var body: some View {
        Text("삭제된 모트입니다.")
    }
}

//#Preview {
//    MoatItem(
//        moatType: .userProfile,
//        title: "test",
//        content: "testetstest",
//        hashtagList: ["#축구"],
//        fireCount: 0,
//        commentCount: 0,
//        userHandle: "test",
//        createdAt: "2025-08-16T20:10:00.666666"
//    )
//}
