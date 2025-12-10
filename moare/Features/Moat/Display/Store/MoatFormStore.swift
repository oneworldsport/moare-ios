//
//  FormStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MoatFormStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var moatForCreate: MoatCreateRequest? = nil
        var moatForUpdate = MoatUpdateRequest()
        
        var moat: MoatResponse?
        var isUpdate: Bool
        
        var content: String = ""
        var sportTags: [String] = []
        
        init(moat: MoatResponse? = nil) {
            self.moat = moat
            self.isUpdate = moat != nil
            if let moat = moat {
                self.content = moat.content
                self.sportTags = moat.sportTags.map { tag in
                    tag.hasPrefix("#") ? tag : "# " + tag
                }
            }
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)

        case deleteMoat(moatId: String)
        case updateSportsInterests(String)
        
        case submitTapped
        case submitResponse(Result<MoatResponse, Error>)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case createdOrUpdatedMoat(MoatResponse)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .deleteMoat(let moatId):
                return .run { send in
                    let _ = try await moatClient.deleteMoat(moatId: moatId)
                }
                
            case .updateSportsInterests(let sport):
                if state.sportTags.contains(sport) {
                    state.sportTags.removeAll { $0 == sport }
                } else {
                    state.sportTags.append(sport)
                }
                
                if let moat = state.moat {
                    if Set(state.sportTags) != Set(moat.sportTags) {
                        state.moatForUpdate.sportTags = state.sportTags
                    } else {
                        state.moatForUpdate.sportTags = nil
                    }
                }
                                
                return .none
                
            case .submitTapped:
                if state.moat == nil {
                    return .run { [content = state.content, sportTags = state.sportTags] send in
                        let sendForSportTags = sportTags.map { tag in
                                tag.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespaces)
                            }
                        
                        let moat = MoatCreateRequest(content: content, sportTags: sendForSportTags)
                        
                        let result = try await moatClient.createMoat(body: moat)
                        
                        await send(.submitResponse(.success(result)))
                    }
                } else {
                    state.moatForUpdate.content = state.content
                    state.moatForUpdate.sportTags = state.sportTags
                    
                    if let moat = state.moat {
                        return .run { [moatForUpdate = state.moatForUpdate] send in
                            let noHashTagsSportTags = (moatForUpdate.sportTags ?? []).map {
                                $0.replacingOccurrences(of: "#", with: "")
                                  .trimmingCharacters(in: .whitespaces)
                              }
                            
                            var body = moatForUpdate
                            if body.sportTags?.isEmpty == true {
                                body.sportTags = noHashTagsSportTags
                            }
                            
                            
                            let result = try await moatClient.updateMoat(moatId: moat.moatId, body: body)
                            
                            await send(.submitResponse(.success(result)))
                        }
                    }
                }
                
                return .none
                
            case .submitResponse(.success(let result)):
                state.moatForUpdate = .init()
                
                return .send(.delegate(.createdOrUpdatedMoat(result)))
                
            case .submitResponse(.failure(let error)):
                return .none
                
            case .binding, .delegate:
                return .none
            }
        }
    }
}
