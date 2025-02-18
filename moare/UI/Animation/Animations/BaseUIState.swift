//
//  BaseUIState.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 7/21/24.
//

import Foundation
import SwiftUI

extension View {
//    func uiState(
//        visibleState: Binding<Bool>
//    ) -> some View {
//        self.modifier(
//            BaseUIModifier(
//                visibleState: visibleState
//            )
//        )
//    }
    
    func uiState(
        visibleState: Bool
    ) -> some View {
        self.modifier(
            BaseUIModifier(
                visibleState: visibleState
            )
        )
    }
}

//struct BaseUIModifier: ViewModifier {
//    @Binding var visibleState: Bool
//    
//    func body(content: Content) -> some View {
//        Group {
//            if visibleState {
//                content
//            } else {
//                EmptyView()
//            }
//        }
//    }
//}

struct BaseUIModifier: ViewModifier {
    var visibleState: Bool
    
    func body(content: Content) -> some View {
        Group {
            if visibleState {
                content
            } else {
                EmptyView()
            }
        }
    }
}
