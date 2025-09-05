//
//  SignStore.swift
//  moare
//
//  Created by 최지혜 on 8/18/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SignStore {
    
    let signClient = SignClient()
    
    @ObservableState
    struct State {
        var currentFlow: SignFlow = .loginId
        var title: String = "로그인"
        var idType: AuthMethod = .email
        var idTypeSelectedIndex: Int = 0
        var text: String = ""
        var placeholder: String = " 이메일 입력"
        var submitBtnLabel: String = "코드 전송"
        var isValid: Bool = false
        var errorText: String = ""
        var apiFetchState: ApiFetchState = .idle
        var isCheckingNickname: Bool = false
        
        var id = ""
        var session: String? = nil
        var otp = ""
        var nickname: String? = nil
        var sportsInterest: [String]? = nil
    }
    
    enum Action {
        case selectType(index: Int)
        case updateText(text: String)
        case checkValidation
        case submit
        case sendLoginOtp
        case sendLoginOtpSuccess(session: String)
        case confirmLoginOtp
        case confirmLoginOtpResult(responseSession: String)
        case sendSignUpOtp
        case confirmSignUpOtp
        case confirmSignUpOtpSuccess(type: AuthResponseType)
        case checkNickname
        case checkNicknameSuccess(result: Bool)
        case reserveNickname
        case reserveNicknameSuccess(result: Bool)
        case completeSignUp
        case completeSignUpSuccess(result: Bool)
        case updateSignFlow(signFlow: SignFlow)
        case signUpIdSuccess
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .selectType(let index):
                state.idTypeSelectedIndex = index
                
                if index == 0 {
                    state.idType = .email
                    state.placeholder = " 이메일 입력"
                } else {
                    state.idType = .phoneNumber
                    state.placeholder = " 전화번호 입력"
                }
                
                state.text = ""
                
                return .send(.checkValidation)
                
            case .updateText(let text):
                state.text = text
                
                return .send(.checkValidation)
                
            case .checkValidation:
                switch state.currentFlow {
                case .loginId, .signUpId:
                    if state.idType == .email {
                        state.isValid = validateEmail(state.text)
                    } else {
                        state.isValid = validatePhoneNumber(state.text)
                    }
                    
                    return .none
                    
                case .loginOtp, .loginOtpRetry, .signUpOtp, .signUpOtpRetry:
                    state.isValid = state.text.count == 6
                    
                    return .none
                    
                case .loginOtpExpired:
                    return .none
                    
                case .loginOtpLimitExceeded:
                    return .none
                    
                case .loginSuccess:
                    return .none
                    
                case .signUpOtpExpired:
                    return .none
                    
                case .signUpNickname:
                    return .run { send in
                        try await Task.sleep(for: .seconds(2))
                        
                        await send(.checkNickname)
                    }
            
                case .signUpSportsInterest:
                    return .none
                    
                case .signUpSuccess:
                    return .none
                    
                }
                
            case .submit:
                switch state.currentFlow {
                case .loginId, .loginOtpExpired, .loginOtpLimitExceeded:
                    if state.isValid {
                        return .send(.sendLoginOtp)
                    }
                    
                case .loginOtp, .loginOtpRetry:
                    if state.isValid {
                        return .send(.confirmLoginOtp)
                    }
                    
                case .loginSuccess:
                    return .none
                    
                case .signUpId, .signUpOtpExpired:
                    if state.isValid {
                        return .send(.sendSignUpOtp)
                    }
                    
                case .signUpOtp, .signUpOtpRetry:
                    if state.isValid {
                        return .send(.confirmSignUpOtp)
                    }
                    
                case .signUpNickname:
                    if state.isValid {
                        return .send(.reserveNickname)
                    }
                    
                case .signUpSportsInterest:
                    if state.isValid {
                        return .send(.completeSignUp)
                    }
                    
                case .signUpSuccess:
                    return .none
                }
                return .none
            
            case .sendLoginOtp:
                if state.id.isEmpty { state.id = state.text }
                
                state.apiFetchState = .fetching
                
                let id = state.id
                let method = state.idType

                
                return .run { send in
                    do {
                        let body = StartAuthRequest(id: id, method: method)
                        let result = try await signClient.startLoginAuth(body: body)
                        
                        await send(.sendLoginOtpSuccess(session: result.session))
                    } catch {
                        print("\(error)")
                    }
                }
                
            case .sendLoginOtpSuccess(let session):
                state.session = session
                
                return .send(.updateSignFlow(signFlow: .loginOtp))
                
            case .confirmLoginOtp:
                state.otp = state.text
                state.apiFetchState = .fetching
                
                guard let session = state.session else {
                    return .none
                }
                
                let id = state.id
                let otp = state.otp
                
                return .run { send in
                    do {
                        let body = ConfirmAuthRequest(id: id, otp: otp, session: session)
                        
                        let result = try await signClient.confirmLoginAuth(body: body)
                        
                        switch result {
                        case .token(let token):
                            UserDefaults.standard.set(token.idToken, forKey: "idToken")
                            UserDefaults.standard.set(token.accessToken, forKey: "accessToken")
                            UserDefaults.standard.set(token.refreshToken, forKey: "refreshToken")
                            
                            await send(.updateSignFlow(signFlow: .loginSuccess))
                            
                        case .session(let responseSession):
                            await send(.confirmLoginOtpResult(responseSession: session))
                            
                        case .type(let type):
                            if type == .expired {
                                await send(.updateSignFlow(signFlow: .loginOtpExpired))
                            } else if type == .limitExceeded {
                                await send(.updateSignFlow(signFlow: .loginOtpLimitExceeded))
                            }
                        }
                    } catch {
                        
                    }
                }
                
            case .confirmLoginOtpResult(let responseSession):
                state.session = responseSession
                
                return .send(.updateSignFlow(signFlow: .loginOtpRetry))
                
            case .sendSignUpOtp:
                if state.id.isEmpty {
                    state.id = state.text
                }
                
                let body = SignUpInitiateRequest(id: state.id, method: state.idType)
                
                state.apiFetchState = .fetching
                
                return .run { send in
                    do {
                        let result = try await signClient.initiateSignUp(body: body)
                        
                        await send(.updateSignFlow(signFlow: .signUpOtp))
                    } catch {
                        
                    }
                }
                
            case .confirmSignUpOtp:
                state.otp = state.text
                
                let body = SignUpVerificationRequest(id: state.id, otp: state.otp)
                
                state.apiFetchState = .fetching
                
                return .run { send in
                    do {
                        let result = try await signClient.verifySignUpOtp(body: body)
                        
                        await send(.confirmSignUpOtpSuccess(type: result.type))
                    } catch {
                        
                    }
                }
                
            case .confirmSignUpOtpSuccess(let type):
                switch type {
                case .success:
                    return .send(.updateSignFlow(signFlow: .signUpNickname))
                case .retry:
                    return .send(.updateSignFlow(signFlow: .signUpOtpRetry))
                case .expired:
                    return .send(.updateSignFlow(signFlow: .signUpOtpExpired))
                default :
                    return .none
                }
                
            case .checkNickname:
                state.nickname = state.text
                state.isCheckingNickname = true
                state.isValid = false
                
                if let nickname = state.nickname,
                   !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // nickname이 nil이 아니고, 공백 제거 후에도 비어있지 않음
                    state.apiFetchState = .fetching
                    
                    return .run { send in
                        do {
                            let result = try await signClient.checkNickname(nickname: nickname)
                            
                            await send(.checkNicknameSuccess(result: result.success))
                        } catch {
                            
                        }
                    }
                }
                
                return .none
                
            case .checkNicknameSuccess(let result):
                state.isCheckingNickname = false
                
                if result {
                    state.apiFetchState = .success
                    state.isValid = true
                } else {
                    state.apiFetchState = .failure("")
                    state.isValid = false
                    state.errorText = "이미 사용중인 닉네임입니다."
                }
                return .none
                
            case .reserveNickname:
                if let nickname = state.nickname,
                   !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // nickname이 nil이 아니고, 공백 제거 후에도 비어있지 않음
                    state.apiFetchState = .fetching
                    
                    return .run { send in
                        do {
                            let result = try await signClient.reserveNickname(nickname: nickname)
                            
                            await send(.reserveNicknameSuccess(result: result.success))
                        } catch {
                            print("\(error)")
                        }
                    }
                }
                
                return .none
                
            case .reserveNicknameSuccess(let result):
                if result {
                    return .send(.updateSignFlow(signFlow: .signUpSportsInterest))
                }
                return .none
                
            case .completeSignUp:
                let body = SignUpCompleteRequest(id: state.id, method: state.idType, profile: UserProfileCreateRequest(nickname: state.nickname ?? "test"))
                
                state.apiFetchState = .fetching
                
                return .run { send in
                    let result = try await signClient.completeSignUp(body: body)
                    
                    await send(.completeSignUpSuccess(result: result.success))
                }
                
            case .completeSignUpSuccess(let result):
                if result {
                    return .send(.updateSignFlow(signFlow: .signUpSuccess))
                }
                
                return .none
                
            case .updateSignFlow(let signFlow):
                state.currentFlow = signFlow
                state.text = ""
                state.isValid = false
                
                switch signFlow {
                case .loginId:
                    state.apiFetchState = .success
                    state.title = "로그인"
                    state.placeholder = " 이메일 입력"
                    state.submitBtnLabel = "코드 전송"
                case .loginOtp:
                    state.apiFetchState = .success
                    state.title = "코드 인증"
                    state.placeholder = " 인증 코드"
                    state.submitBtnLabel = "확인"
                case .loginOtpRetry:
                    state.apiFetchState = .failure("")
                    state.submitBtnLabel = "확인"
                    state.errorText = "코드가 틀렸습니다. 다시 시도해 주세요."
                case .loginOtpExpired:
                    state.apiFetchState = .failure("")
                    state.placeholder = ""
                    state.submitBtnLabel = "코드 재전송"
                    state.isValid = true
                    state.errorText = "코드가 만료되었습니다. 코드를 재전송해 주세요."
                case .loginOtpLimitExceeded:
                    state.apiFetchState = .failure("")
                    state.placeholder = ""
                    state.submitBtnLabel = "코드 재전송"
                    state.isValid = true
                    state.errorText = "코드 인증 시도 횟수를 초과하였습니다. 코드를 재전송해 주세요."
                case .loginSuccess:
                    state.apiFetchState = .success
                case .signUpId:
                    state.apiFetchState = .success
                    
                    return .run { send in
                        await send(.selectType(index: 0))
                        await send(.signUpIdSuccess)
                    }
                case .signUpOtp:
                    state.apiFetchState = .success
                    state.title = "코드 인증"
                    state.placeholder = " 인증 코드"
                    state.submitBtnLabel = "확인"
                case .signUpOtpRetry:
                    state.apiFetchState = .failure("")
                    state.submitBtnLabel = "확인"
                    state.errorText = "코드가 틀렸습니다. 다시 시도해 주세요."
                case .signUpOtpExpired:
                    state.apiFetchState = .failure("")
                    state.placeholder = ""
                    state.submitBtnLabel = "코드 재전송"
                    state.isValid = true
                    state.errorText = "코드가 만료되었습니다. 코드를 재전송해 주세요."
                case .signUpNickname:
                    state.apiFetchState = .success
                    state.title = "닉네임"
                    state.placeholder = " 닉네임 입력"
                    state.submitBtnLabel = "다음"
                case .signUpSportsInterest:
                    state.apiFetchState = .success
                    state.title = "스포츠 선택"
                    state.submitBtnLabel = "선택 완료"
                    state.isValid = true
                case .signUpSuccess:
                    state.apiFetchState = .success
                    state.title = "가입 완료!"
                }
                
                return .none
                
            case .signUpIdSuccess:
                state.id = ""
                state.session = nil
                state.otp = ""
                
                state.title = "회원가입"
                state.submitBtnLabel = "코드 전송"
                
                return .none
            }
        }
    }
    
    func validateEmail(_ email: String) -> Bool {
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return email.range(of: emailPattern, options: .regularExpression) != nil
    }
    
    func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let phonePattern = "^(010|011|016|017|018|019)-?\\d{3,4}-?\\d{4}$"
        return phoneNumber.range(of: phonePattern, options: .regularExpression) != nil
    }
}

enum SignFlow {
    case loginId, loginOtp, loginOtpRetry, loginOtpExpired, loginOtpLimitExceeded, loginSuccess, signUpId, signUpOtp, signUpOtpRetry, signUpOtpExpired, signUpNickname, signUpSportsInterest, signUpSuccess
}
