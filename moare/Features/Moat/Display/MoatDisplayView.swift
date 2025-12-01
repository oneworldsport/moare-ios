//
//  MoatDisplayView.swift
//  moare
//
//  Created by Mohwa Yoon on 11/3/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatDisplayView: View {
    let stackStore: StoreOf<MoatStackStore>
    
    // TODO: 이게 사용하기 편하니깐, Keychain으로 옮길때 그냥 flag용으로 UserDefaults도 하나 만들면 될듯?
    @AppStorage("accessToken") private var accessToken: String = ""
    
    @State private var searchBarText = ""
    @State private var isSearchBarOpened = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                BackButton {
                    stackStore.send(.pop)
                }
                
                Spacer()
                
                MoatSearchBar(text: $searchBarText, isSearchBarOpened: $isSearchBarOpened)
                
                Button(action: {
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                }) {
                    Text("로그아웃")
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                }
            }
            .frame(height: 40)
            
            if !stackStore.selectedHashtags.isEmpty {
                SelectedHashtags(
                    selectedHashTags: stackStore.selectedHashtags,
                    deleteItem: { hashtag in
                        // TODO: 이때도 moat 다시 가져와야함
                        stackStore.send(.updateSelectedHashtags(hashtag))
                    }, deleteAll: {
                        // TODO: 이때도 moat 다시 가져와야함
                        stackStore.send(.emptySelectedHashtags)
                    })
            }
            
            if isSearchBarOpened {
                MoatSearchForm(
                    text: $searchBarText,
                    selectedHashTags: stackStore.selectedHashtags,
                    onItemSelect: { hashtag in
                        stackStore.send(.updateSelectedHashtags(hashtag))
                    },
                    onComplete: {
                        stackStore.send(.getMoatsWithHashtags)
                        
                        withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                            searchBarText = ""
                            isSearchBarOpened = false
                        }
                    }
                )
            }
            
            if !accessToken.isEmpty {
                if let id = stackStore.path.ids.last {
                    if let store = stackStore.scope(
                        state: \.path[id: id],
                        action: \.path[id: id]
                    ) {
                        MoatPathView(
//                                stackStore: stackStore,
                            store: store,
    //                        didPop: stackStore.didPop,
    //                        isCombinedView: stackStore.includesPreviousView
                        )
                    }
                }
            } else {
                SignView()
            }
        }
        .onAppear {
            if !accessToken.isEmpty {
                stackStore.send(.bootstrapSession)
            }
        }
        .onChange(of: accessToken) {
            if accessToken.isEmpty {
                stackStore.send(.emptyPath)
            } else {
                if stackStore.path.ids.isEmpty {
                    stackStore.send(.push(.trending))
                }
            }
        }
    }
}

struct MoatPathView: View {
//    let stackStore: StoreOf<MoatStackStore>
    let store: StoreOf<MoatStackStore.Path>
//    let didPop: Bool
//    let isCombinedView: Bool
    
    init(
//        stackStore: StoreOf<MoatStackStore>,
        store: StoreOf<MoatStackStore.Path>,
//        didPop: Bool,
//        isCombinedView: Bool = false
    ) {
//        self.stackStore = stackStore
        self.store = store
//        self.didPop = didPop
//        self.isCombinedView = isCombinedView
    }
    
    var body: some View {
        switch store.state {
        case .trending:
            if let s = store.scope(state: \.trending, action: \.trending) { MoatView(store: s) }
        case .form:
            if let s = store.scope(state: \.form, action: \.form) { FormView(store: s) }
        case .detail:
            if let s = store.scope(state: \.detail, action: \.detail) { MoatView(store: s).id(UUID()) }
        }
    }
}

