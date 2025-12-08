//
//  UserSettingsView.swift
//  moare
//
//  Created by Mohwa Yoon on 12/6/25.
//

import SwiftUI
import ComposableArchitecture

struct UserSettingsView: View {
    let store: StoreOf<UserSettingsStore>
    
    @Binding var isPresented: Bool
    
    @State private var show = false
    @State private var isWebViewPresented = false
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width * 0.9
            let minHeight = proxy.size.height * 0.5
            let maxHeight = proxy.size.height * 0.8
            
            ZStack {
                if show {
                    Color.black.opacity(0.7).ignoresSafeArea()
                        .onTapGesture {
                            if isWebViewPresented {
                                store.send(.updateWebViewPresented(false))
                            } else {
                                isPresented = false
                                store.send(.delegate(.close))
                            }
                        }
                    
                    VStack(alignment: .trailing) {
                        Button(action: {
                            isPresented = false
                            store.send(.delegate(.close))
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 22))
                                .frame(width: 30, height: 30)
                        }
                        .foregroundStyle(.moare)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Button(action: {
                                    store.send(.pop)
                                }) {
                                    Image(systemName: "chevron.backward")
                                        .frame(height: 30)
                                        .padding(.leading, 8)
                                        .padding(.trailing, 8) // 터치 공간 확보
                                }
                                .foregroundStyle(.moare)
                                
                                Spacer()
                            }
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(Array(store.current.children.enumerated()), id: \.element.id) { index, node in
                                        Button(action: {
                                            store.send(.tap(node))
                                        }) {
                                            HStack {
                                                VStack {
                                                    Text(node.title)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                    if let desc = node.desc {
                                                        Text(desc)
                                                            .font(.system(size: 14))
                                                            .multilineTextAlignment(.leading)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                                
                                                if !node.children.isEmpty {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                        .disabled(node.action == .none)
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 8)
                                        
                                        if index != store.current.children.count - 1 {
                                            HDivider(color: .secondary)
                                                .padding(.vertical, 12)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .frame(maxWidth: width, minHeight: minHeight, maxHeight: maxHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.white)
                        )
                    }
                    
                    TermsWebView(url: store.url, isPresented: $isWebViewPresented)
                        .onChange(of: store.isWebViewPresented) {
                            isWebViewPresented = store.isWebViewPresented
                        }
                        .onChange(of: isWebViewPresented) {
                            store.send(.updateWebViewPresented(isWebViewPresented))
                        }
                } // if show
            }
        }
        .onChange(of: isPresented) {
//            if isPresented {
//                store = Store(initialState: UserSettingsStore.State()) { UserSettingsStore() }
//            }
            
            withAnimation(AnimationConstants.AnimationType.defaultAnimation) {
                show = isPresented
            }
        }
    }
}
