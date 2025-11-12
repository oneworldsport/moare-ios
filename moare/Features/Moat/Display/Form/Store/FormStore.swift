//
//  FormStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct FormStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var moatForCreate: MoatCreateRequest? = nil
        var moatForUpdate: MoatUpdateRequest? = nil
    }
    
    enum Action {
        case createMoat(content: String)
        case updateMoat(moatId: String)
        case deleteMoat(moatId: String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .createMoat(let content):
//                return .run { [moat = state.moatForCreate] send in
                return .run { send in
                    let moat = MoatCreateRequest(content: content, sportTags: ["#축구"])
                    
//                    if let moat {
                        let _ = try await moatClient.createMoat(body: moat)
//                    }
                }
                
            case .updateMoat(let moatId):
                return .run { [moat = state.moatForUpdate] send in
                    if let moat {
                        let _ = try await moatClient.updateMoat(moatId: moatId, body: moat)
                    }
                }
                
            case .deleteMoat(let moatId):
                return .run { send in
                    let _ = try await moatClient.deleteMoat(moatId: moatId)
                }
            }
        }
    }
}
