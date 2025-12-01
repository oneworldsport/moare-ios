//
//  SelectedHashtags.swift
//  moare
//
//  Created by Mohwa Yoon on 12/1/25.
//

import SwiftUI

struct SelectedHashtags: View {
    let selectedHashTags: [String]
    
    let deleteItem: (String) -> Void
    let deleteAll: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedHashTags, id: \.self) { hashtag in
                        HStack {
                            Text(hashtag)
                                .font(.system(size: 13))
                                .foregroundStyle(.moare)
                            
                            Button(action: {
                                deleteItem(hashtag)
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 13))
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .overlay {
                            Capsule()
                                .stroke(.moare, lineWidth: 1)
                        }
                    }
                }
                .padding(.vertical, 4) // NOTE: 원래 바깥쪽에 줬었는데 .stroke이 뭔가 가려지는듯한 느낌이 있어 여기에 줌. 아래 .leading 패딩도 마찬가지.
                .padding(.leading, 2)
            }
            
            Button(action: {
                deleteAll()
            }) {
                Text("전체삭제")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .overlay {
                        Capsule()
                            .stroke(.secondary, lineWidth: 1)
                    }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
    }
}
