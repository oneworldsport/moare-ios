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


//private struct HeightKey: PreferenceKey {
//    static var defaultValue: CGFloat = 0
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = nextValue()
//    }
//}
//
//extension View {
//    func readHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
//        background(
//            GeometryReader { proxy in
//                Color.clear.preference(key: HeightKey.self, value: proxy.size.height)
//            }
//        )
//        .onPreferenceChange(HeightKey.self, perform: onChange)
//    }
//}
