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
    
    // TODO: 이게 사용하기 편하니깐, Keychain으로 옮길때 그냥 flag용으로 UserDefaults도 하나 만들면 될듯?
    @AppStorage("accessToken") private var accessToken: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    BackButton {
                        moatStackStore.send(.pop)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                    }) {
                        Text("로그아웃")
                            .font(.system(size: 12))
                            .padding(.trailing)
                    }
                }
                
                Spacer()
            }
            .zIndex(1)
            
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
                        .padding(.top, 30)
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
        .onChange(of: accessToken) {
            if accessToken.isEmpty {
                moatStackStore.send(.emptyPath)
            } else {
                if moatStackStore.path.ids.isEmpty {
                    moatStackStore.send(.push(.trending))
                }
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

