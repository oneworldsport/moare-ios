//
//  PlaceholderTextEditor.swift
//  moare
//
//  Created by Mohwa Yoon on 9/9/25.
//

import SwiftUI

struct PlaceholderTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
            
            if text.isEmpty {
                Text("\(placeholder)")
                    .foregroundStyle(.secondary)
                    .opacity(0.5)
                    .padding(.top, 9)
                    .padding(.leading, 8)
            }
        }
    }
}

//#Preview {
//    PlaceholderTextEditor(placeholder: "9955555888")
//}
