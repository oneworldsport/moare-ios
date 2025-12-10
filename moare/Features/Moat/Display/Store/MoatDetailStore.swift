//
//  MoatDetailStore.swift
//  moare
//
//  Created by 최지혜 on 12/8/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MoatDetailStore {
    let moatClient = MoatClient()
    
    @ObservableState
    struct State {
        var reportPresenting: Bool = false
        
        var moatResponse: MoatResponse? = nil
        var moatDetailResponse: MoatDetailResponse? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
                
        case selectMoat(moatId: String)
        case selectMoatResponse(Result<MoatDetailResponse, Error>)
        
        case createMoat(content: String)
        case updateSelectedMoat(moatDetailResponse: MoatDetailResponse)
        
        case showUpdateForm(moatId: String)
        case settingItemsTapped(item: SettingItems, moatId: String)
        case deleteMoatResponse(result: Result<MessageResponse, Error>, moatId: String)
        case reportSuccess(reasonText : String)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case push(viewType: MoatViewType, moatId: String? = nil, moatDetailResponse: MoatDetailResponse? = nil, moat: MoatResponse? = nil)
        case deleted(moatId: String)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .selectMoat(let moatId):
                return .run { send in
                    do {
                        let result = try await moatClient.fetchMoatDetail(moatId: moatId)
                        await send(.selectMoatResponse(.success(result)))
                    } catch {
                        await send(.selectMoatResponse(.failure(error)))
                    }
                    
                }
                
            case .selectMoatResponse(.success(let moatDetailResponse)):
                return .send(.delegate(.push(viewType: .detail, moatDetailResponse: moatDetailResponse)))
                
            case .selectMoatResponse(.failure(_)):
                return .none
                
            case .createMoat(let content):
                
                return .run { [moat = state.moatDetailResponse] send in
                    if let moat {
                        let moatRequest = MoatCreateRequest(content: content, sportTags: moat.moat.sportTags, parentMoatId: moat.moat.moatId)
                        
                        let result = try await moatClient.createMoat(body: moatRequest)
                        
                        var comments = moat.commentListResponse?.moats ?? []
                        comments.append(result)
                        
                        var commentListResponse = moat.commentListResponse
                        commentListResponse?.moats = comments
                        
                        var newMoatDetail = moat
                        newMoatDetail.commentListResponse = commentListResponse
                        
                        await send(.updateSelectedMoat(moatDetailResponse: newMoatDetail))
                    }
                }
                
            case .updateSelectedMoat(let moatDetailResponse):
                state.moatDetailResponse = moatDetailResponse
                
                return .none
                
            case .showUpdateForm(let moatId):
                if let selectedMoat = state.moatDetailResponse,
                   selectedMoat.moat.moatId == moatId {
                    return .send(.delegate(.push(viewType: .updateForm, moat: selectedMoat.moat)))
                }
                
                if let selectedMoat = state.moatResponse,
                   selectedMoat.moatId == moatId {
                    return .send(.delegate(.push(viewType: .updateForm, moat: selectedMoat)))
                }
    
                return .none
                
            case .settingItemsTapped(let item, let moatId):
                switch item {
                case .report:
                    state.reportPresenting = true
                    return .none
                    
                case .updateMoat:
                    return .send(.showUpdateForm(moatId: moatId))
                    
                case .deleteMoat:
                    return .run { send in
                        let result = try await moatClient.deleteMoat(moatId: moatId)

                        await send(.deleteMoatResponse(result: .success(result), moatId: moatId))
                    }
                default:
                    return .none
                }
                
            case .deleteMoatResponse(.success(_), let moatId):
                return .send(.delegate(.deleted(moatId: moatId)))
                
            case .deleteMoatResponse(.failure, _):
                return .none
                
            case .reportSuccess(let reasonText):
                return .run { [selectedMoat = state.moatDetailResponse] send in
                    if let selectedMoat {
                        let body = ReportCreateRequest(
                            targetType: .moat,
                            targetId: selectedMoat.moat.moatId,
                            reasonCode: .other,
                            reasonText: reasonText
                        )
                        let result = try await moatClient.createReport(body: body)
                    }
                }
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
