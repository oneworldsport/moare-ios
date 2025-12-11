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
        
        case fireToggle(moatId: String, targetType: FireTargetType)
        
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
                
            case .fireToggle(let moatId, let targetType):
                // api는 따로 치니까 ui 만 바꾸는 걸로
                switch targetType {
                case .moat:
                    if var moatDetail = state.moatDetailResponse,
                       moatDetail.moat.moatId == moatId {
                        moatDetail.moat.isFired.toggle()
                        moatDetail.moat.fireCount += moatDetail.moat.isFired ? 1 : -1
                        state.moatDetailResponse = moatDetail
                    }
                    
                    // 작성하자마자 누르는 경우
                    if var moat = state.moatResponse,
                       moat.moatId == moatId {
                        moat.isFired.toggle()
                        moat.fireCount += moat.isFired ? 1 : -1
                        state.moatResponse = moat
                    }
                    
                case .comment:
                    if var moatDetail = state.moatDetailResponse,
                       var commentsList = moatDetail.commentListResponse?.moats,
                       let comment = commentsList.firstIndex(where: { $0.moatId == moatId }) {
                        
                        commentsList[comment].isFired.toggle()
                        commentsList[comment].fireCount += commentsList[comment].isFired ? 1 : -1
                        
                        moatDetail.commentListResponse?.moats = commentsList
                        state.moatDetailResponse = moatDetail
                    }
                }
                
                return .none
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
