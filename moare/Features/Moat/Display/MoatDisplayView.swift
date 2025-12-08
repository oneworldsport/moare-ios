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
    let signStore: Store<SignStore.State?, SignStore.Action>
    
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
            
            if let userId = stackStore.userId {
                if let id = stackStore.path.ids.last {
                    if let store = stackStore.scope(
                        state: \.path[id: id],
                        action: \.path[id: id]
                    ) {
                        MoatPathView(
//                                stackStore: stackStore,
                            store: store,
                            userId: userId
    //                        didPop: stackStore.didPop,
    //                        isCombinedView: stackStore.includesPreviousView
                        )
                    }
                }
            } else {
                IfLetStore(signStore) { store in
                    SignView(store: store)
                }
            }
        }
        .onAppear {
            if let token = KeychainManager.shared.get("accessToken"), !token.isEmpty {
                stackStore.send(.bootstrapSession)
            } else {
                stackStore.send(.delegate(.initSignStore))
            }
        }
        .onChange(of: stackStore.userId) {
            if let _ = stackStore.userId {
                if stackStore.path.ids.isEmpty {
                    stackStore.send(.push(.trending))
                }
            } else {
                stackStore.send(.emptyPath)
            }
        }
    }
}

struct MoatPathView: View {
//    let stackStore: StoreOf<MoatStackStore>
    let store: StoreOf<MoatStackStore.Path>
    let userId: String?
//    let didPop: Bool
//    let isCombinedView: Bool
    
    init(
//        stackStore: StoreOf<MoatStackStore>,
        store: StoreOf<MoatStackStore.Path>,
        userId: String?
//        didPop: Bool,
//        isCombinedView: Bool = false
    ) {
//        self.stackStore = stackStore
        self.store = store
        self.userId = userId
//        self.didPop = didPop
//        self.isCombinedView = isCombinedView
    }
    
    var body: some View {
        switch store.state {
        case .trending:
            if let s = store.scope(state: \.trending, action: \.trending) { MoatView(store: s, userId: userId) }
        case .createForm:
            if let s = store.scope(state: \.createForm, action: \.createForm) { MoatFormView(store: s) }
        case .detail:
            if let s = store.scope(state: \.detail, action: \.detail) { MoatView(store: s, userId: userId).id(UUID()) }
            
        case .updateForm:
            if let s = store.scope(state: \.updateForm, action: \.updateForm) { MoatFormView(store: s) }
        }
    }
}

