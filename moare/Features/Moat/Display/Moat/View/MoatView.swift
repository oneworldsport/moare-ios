//
//  MoatTimelineView.swift
//  moare
//
//  Created by 최지혜 on 8/29/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State var moatStore: StoreOf<MoatStore>? = nil
    
    @AppStorage("accessToken") private var accessToken: String = ""
    
    @State private var testClick = false
    @State private var listCount = 10
    @State private var formTestShow = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let moatStore {
                if !accessToken.isEmpty {
                    VStack {
                        ScrollView {
                            LazyVStack(spacing: 28) {
                                ForEach(0..<listCount, id: \.self) { _ in
                                    MoatItem(moatType: testClick ? .detail : .timeline) {
                                        testClick = true
                                        listCount = 1
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                        .scrollDisabled(testClick)
                        .frame(height: testClick ? 160 : nil)
                        
                        if testClick {
                            ScrollView {
                                LazyVStack(spacing: 28) {
                                    ForEach(0..<10) { _ in
                                        MoatItem(moatType: .comment) {
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                        }
                    }
                    
                    if !formTestShow {
                        Button(action: {
                            formTestShow = true
                        }) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 40))
                                .foregroundStyle(.moare)
                                .shadow(color: .moare, radius: 3, x: 2, y: 1)
                        }
                        .padding(10)
                        
                    } else {
                        FormView()
                    }
                } else {
                    SignView()
                        .environmentObject(storeManager)
                }
            }
        }
        .onAppear {
            let moatStore: StoreOf<MoatStore> = storeManager.getStore(forKey: StoreKeys.moatStore) ?? {
                let newStore = Store(initialState: MoatStore.State()) {
                    MoatStore()
                }
                
                storeManager.setStore(newStore, forKey: StoreKeys.moatStore)
                
                return newStore
            }()
            
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                self.moatStore = moatStore
            }
            
//            moatTimelineStore.send(.delete)
        }
    }
}
