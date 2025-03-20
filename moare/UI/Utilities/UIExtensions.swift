//
//  Extensions.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/13/24.
//

import SwiftUI

extension View {
    /// get view's width and height
    func getViewSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        onChange(geometry.size)
                    }
                    .onChange(of: geometry.size) { newValue in
                        onChange(newValue)
                    }
            }
        )
    }
}
