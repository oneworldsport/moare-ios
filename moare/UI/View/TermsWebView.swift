//
//  TermsWebView.swift
//  moare
//
//  Created by Mohwa Yoon on 12/2/25.
//

import SwiftUI

struct TermsWebView: View {
    let url: String
    
    @Binding var isPresented: Bool
    
    var body: some View {
        if isPresented {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                            .frame(width: 30, height: 30)
                            .padding(.leading, 10)
                    }
                    .foregroundStyle(.moare)
                    
                    Spacer()
                }
                .frame(height: 34)
                
                WebView(url: URL(string: url)!)
            }
        }
    }
}
