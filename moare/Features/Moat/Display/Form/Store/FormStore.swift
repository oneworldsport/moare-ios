//
//  FormStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

enum MoatMode {
    case create, update
}

@Reducer
struct FormStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var moatForCreate: MoatCreateRequest? = nil
        var moatForUpdate: MoatUpdateRequest? = nil
        
        var moatMode: MoatMode = .create
        
        var content: String = ""
        var sportTags: [String] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
//        case createMoat
        case updateMoat(moatId: String)
        case deleteMoat(moatId: String)
        
        case submitTapped
        case submitResponse(Result<MoatResponse, Error>)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case created(MoatResponse)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
//            case .createMoat:
////                return .run { [moat = state.moatForCreate] send in
//                return .run { [content = state.content, sportTags = state.sportTags] send in
//                    let moat = MoatCreateRequest(content: content, sportTags: ["축구"])
//                    
////                    if let moat {
//                        let _ = try await moatClient.createMoat(body: moat)
////                    }
//                }
                
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
                
            case .submitTapped:
                switch state.moatMode {
                case .create:
                    return .run { [content = state.content, sportTags = state.sportTags] send in
                        let moat = MoatCreateRequest(content: content, sportTags: ["축구"])
                        
                        let result = try await moatClient.createMoat(body: moat)
                        
                        await send(.submitResponse(.success(result)))
                    }
                case .update:
                    return .none
                }
                
            case .submitResponse(.success(let result)):
                switch state.moatMode {
                case .create:
                    return .send(.delegate(.created(result)))
                case .update:
                    return .none
                }
                
            case .submitResponse(.failure(let error)):
                return .none
                
            case .binding, .delegate:
                return .none
            }
        }
    }
}
