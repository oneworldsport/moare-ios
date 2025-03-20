//
//  NoticeBox.swift
//  moare
//
//  Created by Mohwa Yoon on 2/21/25.
//

import SwiftUI

struct NoticeBox: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("현재 제공중인 스포츠 데이터:")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text("• 프리미어리그 24/25" +
                     "\n• 라리가 24/25" +
                     "\n• 분데스리가 24/25" +
                     "\n• 리그 1 24/25")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text("\n제공 예정 스포츠 데이터:")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text("• 챔피언스리그 24/25" +
                     "\n• KBO 리그 2025" +
                     "\n• MLB 2025")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(10)
        }
        .frame(maxWidth: 160, maxHeight: 100)
        .overlay(
            RoundedRectangle(cornerRadius: UIConstants.CornerRadius.small)
                .stroke(.secondary, lineWidth: UIConstants.StrokeWidth.thin)
        )
    }
}

#Preview {
    NoticeBox()
}
