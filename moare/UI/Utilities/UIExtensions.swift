//
//  Extensions.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/13/24.
//

import SwiftUI

extension View {
    /// get view's width and height
    func readSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        onChange(proxy.size)
                    }
                    .onChange(of: proxy.size) {
                        onChange(proxy.size)
                    }
            }
        )
    }
    
    @ViewBuilder
    func refreshableIf(_ enabled: Bool, action: @escaping () async -> Void) -> some View {
        if enabled {
            self.refreshable { await action() }
        } else {
            self
        }
    }
}
