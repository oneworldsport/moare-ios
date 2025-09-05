//
//  StickyHeader.swift
//  moare
//
//  Created by Mohwa Yoon on 8/20/25.
//

import Foundation
import SwiftUI

struct StickyHeader<Content: View>: View {
    let content: () -> Content
    let coordinateSpaceName: String
    
    @State private var offset: CGFloat = 0
    @State private var stuck: Bool = false
    
    init(
        coordinateSpaceName: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.coordinateSpaceName = coordinateSpaceName
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
                .frame(height: 0)
                .background(
                    GeometryReader { geometry in
                        let newOffset = geometry.frame(in: .named(coordinateSpaceName)).minY
                        
                        Color.clear
                            .onAppear {
                                offset = newOffset
                            }
                            .onChange(of: newOffset) {
                                stuck = newOffset <= 0
                                offset = newOffset
                            }
                    }
                )
            
            if stuck {
                content()
                    .background(.white)
                    .zIndex(1)
                    .offset(y: -offset)
            } else {
                content()
            }
        }
        // 왜 content()랑 여기에 둘다 해야 적용되는거지..?
        .background(.white)
        .zIndex(1)
    }
}
