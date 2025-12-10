//
//  FireStore.swift
//  moare
//
//  Created by 최지혜 on 12/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct FireStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var fireMap: [String: Bool] = [:]
        var fireCountMap: [String: Int] = [:]
    }
    
    enum Action {
        case toggle(id: String, targetType: FireTargetType, baseIsFired: Bool, baseCount: Int)
        case createResult(id: String, ok: Bool)
        case deleteResult(id: String, ok: Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .toggle(id, targetType, baseIsFired, baseCount):
                
                let current = state.fireMap[id] ?? baseIsFired
                let countBase = state.fireCountMap[id] ?? baseCount
                
                state.fireMap[id] = !current
                state.fireCountMap[id] = current ? max(0, countBase - 1) : countBase + 1
                
                if current {
                    // delete
                    return .run { [moatClient] send in
                        let ok = (try? await moatClient.deleteFire(moatId: id)) != nil
                        await send(.deleteResult(id: id, ok: ok))
                    }
                } else {
                    // create
                    return .run { [moatClient] send in
                        let req = FireCreateRequest(targetId: id, targetType: targetType)
                        let ok = (try? await moatClient.createFire(body: req)) != nil
                        await send(.createResult(id: id, ok: ok))
                    }
                }
                
            case let .createResult(id, ok):
                if !ok {
                    // 실패시 롤백
                    state.fireMap[id] = false
                    let base = state.fireCountMap[id] ?? 0
                    state.fireCountMap[id] = max(0, base - 1)
                }
                return .none
                
            case let .deleteResult(id, ok):
                if !ok {
                    // 실패시 롤백
                    state.fireMap[id] = true
                    let base = state.fireCountMap[id] ?? 0
                    state.fireCountMap[id] = base + 1
                }
                return .none
                
            }
        }
    }
}
