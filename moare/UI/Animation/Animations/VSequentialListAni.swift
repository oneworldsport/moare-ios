//
//  VSequentialListAni.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 6/1/24.
//

import SwiftUI

struct VSequentialListItem: ViewModifier {
    let index: Int
    let reversedIndex: Int
    let itemHeight: CGFloat
    let aniDelay: Double
    let reversedAniDelay: Double
    let aniDuration: Double
    @Binding var shouldHide: Bool
    @State private var offset: CGSize
    
    init(
        index: Int,
        itemCount: Int,
        itemHeight: CGFloat,
        aniDelay: Double,
        aniDuration: Double,
        shouldHide: Binding<Bool>? = nil
    ) {
        self.index = index
        self.reversedIndex = itemCount - index
        self.itemHeight = itemHeight
        self.aniDelay = Double(index) * aniDelay
        self.reversedAniDelay = Double(reversedIndex) * aniDelay
        self.aniDuration = aniDuration
        self._shouldHide = shouldHide ?? .constant(false)
        _offset = State(initialValue: CGSize(width: 0, height: -itemHeight))
    }
    
    func body(content: Content) -> some View {
        VStack {
            if offset.height == 0 {
                content
                    .offset(offset)
            }
        }
        .onAppear {
            animateItem()
        }
        .onChange(of: shouldHide) { newValue in
            hideItem()
        }
    }
    
    private func animateItem() {
        DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: aniDuration).delay(aniDelay)) {
                    offset = CGSize(width: 0, height: 0)
                }
            }
//        withAnimation(.easeInOut(duration: aniDuration).delay(aniDelay)) {
//            offset = CGSize(width: 0, height: 0)
//        }
    }
    
    private func hideItem() {
        if shouldHide {
            withAnimation(.easeInOut(duration: aniDuration).delay(reversedAniDelay)) {
                offset = CGSize(width: 0, height: -itemHeight)
            }
        }
    }
}

extension View {
    /// Showing and hiding list item from top to bottom and bottom to top.
    ///
    /// - Parameters:
    ///   - shouldHide: Required when hiding animation is needed
    ///
    /// - Note: When using in ScrollView, should fill the ScrollView's width before the list ani starts.
    /// - NoteExmample:
//    ScrollView {
//        // View to fill ScrollView's width before vSequentialListAni
//        HStack {
//            Spacer()
//        }
//        
//        ForEach(dataList.indices, id: \.self) { index in
//            let data = dataList[index]
//            
//            DataItem(data: data)
//                .vSequentialListAni(
//                    index: index,
//                    itemCount: dataList.count,
//                    itemHeight: 100,
//                    aniDelay: 0.1,
//                    aniDuration: 0.5
//                )
//        }
//    }
    public func vSequentialListAni(
        index: Int,
        itemCount: Int,
        itemHeight: CGFloat,
        aniDelay: Double,
        aniDuration: Double,
        shouldHide: Binding<Bool>? = nil
    ) -> some View {
        self.modifier(
            VSequentialListItem(
                index: index,
                itemCount: itemCount,
                itemHeight: itemHeight,
                aniDelay: aniDelay,
                aniDuration: aniDuration,
                shouldHide: shouldHide
            )
        )
    }
}
