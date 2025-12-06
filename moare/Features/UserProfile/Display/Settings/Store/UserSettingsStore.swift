//
//  UserSettingsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 12/6/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct UserSettingsStore {
    @ObservableState
    struct State {
        var stack: [SettingsNode] = [SettingsTree.root]
        var current = SettingsTree.root
        
        var url = ""
        var isWebViewPresented = false
    }
    
    enum Action {
        case tap(SettingsNode)
        case pop
        case updateWebViewPresented(Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tap(let node):
                switch node.action {
                case .push:
                    state.stack.append(node)
                    state.current = node
                    
                case .logout:
                    return .run { send in
                        do {
                            try await AWSManager.shared.revokeRefreshToken()
                        } catch {
                            print("\(error)")
                        }
                    }
                    
                case .withdraw: break
                    
                case .openURL(let url):
                    state.url = url
                    
                    return .send(.updateWebViewPresented(true))
                    
                case .none: break
                }
                
                return .none
                
            case .pop:
                if state.stack.count > 1 {
                    _ = state.stack.popLast()
                    state.current = state.stack.last ?? SettingsTree.root
                }
                
                return .none
                
            case .updateWebViewPresented(let presented):
                state.isWebViewPresented = presented
                
                return .none
            }
        }
    }
}
