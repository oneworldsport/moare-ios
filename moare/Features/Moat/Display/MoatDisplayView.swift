//
//  MoatDisplayView.swift
//  moare
//
//  Created by Mohwa Yoon on 11/3/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatDisplayView: View {
    let moatStackStore: StoreOf<MoatStackStore>
    
    @AppStorage("accessToken") private var accessToken: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackButton {
                    moatStackStore.send(.pop)
                }
                
                Spacer()
            }
            
            if !accessToken.isEmpty {
                if let id = moatStackStore.path.ids.last {
                    if let store = moatStackStore.scope(
                        state: \.path[id: id],
                        action: \.path[id: id]
                    ) {
                        MoatPathView(
//                                moatStackStore: moatStackStore,
                            store: store,
    //                        didPop: moatStackStore.didPop,
    //                        isCombinedView: moatStackStore.includesPreviousView
                        )
                    }
                }
            } else {
                SignView()
            }
        }
        .onAppear {
            if !accessToken.isEmpty {
                moatStackStore.send(.bootstrapSession)
            }
        }
    }
}

struct MoatPathView: View {
//    let moatStackStore: StoreOf<MoatStackStore>
    let store: StoreOf<MoatStackStore.Path>
//    let didPop: Bool
//    let isCombinedView: Bool
    
    init(
//        moatStackStore: StoreOf<MoatStackStore>,
        store: StoreOf<MoatStackStore.Path>,
//        didPop: Bool,
//        isCombinedView: Bool = false
    ) {
//        self.moatStackStore = moatStackStore
        self.store = store
//        self.didPop = didPop
//        self.isCombinedView = isCombinedView
    }
    
    var body: some View {
        switch store.state {
        case .moat:
            if let s = store.scope(state: \.moat, action: \.moat) { MoatView(store: s) }
        case .form:
            if let s = store.scope(state: \.form, action: \.form) { FormView(store: s) }
        }
    }
}

