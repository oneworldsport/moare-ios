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
    
    @State private var show = false
    
    var body: some View {
        VStack(spacing: 0) {
            if show {
                HStack {
                    Button(action: {
                        isPresented = false
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
        .onChange(of: isPresented) {
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                show = isPresented
            }
        }
    }
}
