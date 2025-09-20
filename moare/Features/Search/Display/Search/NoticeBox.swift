//
//  NoticeBox.swift
//  moare
//
//  Created by Mohwa Yoon on 2/21/25.
//

import SwiftUI

struct NoticeBox: View {
    let noticeList: [NoticeModel]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(noticeList.indices, id: \.self) { index in
                    let notice = noticeList[index]
                    
                    Text(index == 0 ? notice.title : "\n\(notice.title)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    
                    Text(notice.content)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    
                }
            }
            .padding(10)
        }
        .frame(maxWidth: 160, maxHeight: 100)
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

struct SearchExampleBox: View {
    let text: String
    
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
        .overlay(
            RoundedRectangle(cornerRadius: UIConstants.CornerRadius.small)
                .stroke(.secondary, lineWidth: UIConstants.StrokeWidth.thin)
        )
    }
}

//#Preview {
//    NoticeBox()
//}
