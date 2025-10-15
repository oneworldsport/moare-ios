//
//  NoticeBox.swift
//  moare
//
//  Created by Mohwa Yoon on 2/21/25.
//

import SwiftUI

struct NoticeBox: View {
    let noticeList: [NoticeModel]

    @Binding var height: CGFloat
    
    private let maxHeight: CGFloat = 240
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(noticeList.indices, id: \.self) { index in
                    let notice = noticeList[index]
                    
                    Text(index == 0 ? notice.title : "\n\(notice.title)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    
                    ForEach(notice.sports ?? [], id: \.category) { sport in
                        NoticeSection(category: sport.category, content: sport.content)
                    }
                }
            }
            .padding(6)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { height = min(proxy.size.height, maxHeight) }
                        .onChange(of: proxy.size.height) {
                            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                                height = min(proxy.size.height, maxHeight)
                            }
                        }
                }
            )
        }
        .frame(maxHeight: height)
        .background(
            RoundedRectangle(cornerRadius: UIConstants.CornerRadius.small)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: UIConstants.CornerRadius.small)
                .stroke(.secondary, lineWidth: UIConstants.StrokeWidth.thin)
        )
    }
}

struct NoticeSection: View {
    let category: String
    let content: String
    
    @State private var isOpened: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(AnimationConstants.AnimationType.shortDefaultAnimation) {
                isOpened.toggle()
            }
        }) {
            HStack(spacing: 4) {
                Text(category)
                    .font(.system(size: 12))
                
                Image(systemName: "\(isOpened ? "chevron.up" : "chevron.down")")
                    .font(.system(size: 12))
                    .padding(2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.secondary, lineWidth: 1)
                    }
            }
        }
        .foregroundStyle(.secondary)
        
        if isOpened {
            Text(content)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        }
    }
}

struct SearchExampleBox: View {
    let text: String
    
    @Binding var height: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: UIConstants.CornerRadius.small)
                .fill(.white)
        )
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { height = proxy.size.height }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: UIConstants.CornerRadius.small)
                .stroke(.secondary, lineWidth: UIConstants.StrokeWidth.thin)
        )
    }
}

//#Preview {
//    NoticeBox()
//}
