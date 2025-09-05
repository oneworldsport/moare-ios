//
//  MoatTimelineView.swift
//  moare
//
//  Created by 최지혜 on 8/29/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatTimelineView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State var moatTimelineStore: StoreOf<MoatTimelineStore>? = nil
    
    @AppStorage("accessToken") private var accessToken: String = ""
    
    var body: some View {
        VStack {
            if let moatTimelineStore {
                if !accessToken.isEmpty {
                    Text("환영")
                } else {
                    SignView()
                        .environmentObject(storeManager)
                }
            }
        }
        .onAppear {
            let moatTimelineStore: StoreOf<MoatTimelineStore> = storeManager.getStore(forKey: StoreKeys.moatTimelineStore) ?? {
                let newStore = Store(initialState: MoatTimelineStore.State()) {
                    MoatTimelineStore()
                }
                
                storeManager.setStore(newStore, forKey: StoreKeys.moatTimelineStore)
                
                return newStore
            }()
            
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                self.moatTimelineStore = moatTimelineStore
            }
            
//            moatTimelineStore.send(.delete)
        }
    }
}
