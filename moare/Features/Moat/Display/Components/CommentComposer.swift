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
    
    private var lineHeight: CGFloat { 22 }
    private var numberOfLines: Int {
        text.components(separatedBy: "\n").count
    }
    private var maxHeight: CGFloat { lineHeight * 5 }
    
    var body: some View {
        HStack {
            TextEditor(text: $text)
                .frame(height: min(maxHeight, max(lineHeight * CGFloat(numberOfLines), lineHeight)))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.moare, lineWidth: 1)
                }
            
            Button(action: action) {
                Text("작성")
            }
        }
    }
}
