//
//  Comment.swift
//  moare
//
//  Created by Mohwa Yoon on 9/9/25.
//

import SwiftUI

struct CommentComposer: View {
    @Binding var text: String
    let action: () -> Void
    
    private var firstLineHeight: CGFloat { 35 }
    private var lineHeight: CGFloat { 22 }
    private var numberOfLines: Int {
        text.components(separatedBy: "\n").count
    }
    private var maxHeight: CGFloat { firstLineHeight + (lineHeight * 4) }
    
    var body: some View {
        HStack {
            PlaceholderTextEditor(placeholder: "모트 작성", text: $text)
                .padding(.leading, 4)
            
            Button(action: action) {
                Text("작성")
                    .font(.system(size: 15))
                    .foregroundStyle(text.isEmpty ? .secondary : Color.moare)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(text.isEmpty ? .secondary : Color.moare, lineWidth: 1)
                    }
                    .padding(.trailing, 4)
            }
        }
        .frame(height: min(maxHeight, (firstLineHeight + lineHeight * CGFloat(numberOfLines - 1))))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.moare, lineWidth: 1)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    @State var text = ""
    CommentComposer(text: $text, action: {})
}
