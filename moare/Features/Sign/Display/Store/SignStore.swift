//
//  SignStore.swift
//  moare
//
//  Created by 최지혜 on 8/18/25.
//

import SwiftUI
import ComposableArchitecture

enum SignFlow {
    case loginId,
         loginOtp,
         signUpId,
         signUpOtp,
         signUpNickname,
         signUpSportsInterest,
         signUpSuccess
}

// SignView에 '제출 버튼'과 '하단 프로그레스바'의 활성화된 상태
enum SignActivatedState {
    case allActivated, onlyButtonActivated, allDeactivated
}

struct CheckNicknameCancelID: Hashable {}

@Reducer
struct SignStore {
    let signClient = SignClient()
    
    @ObservableState
    struct State {
        var currentFlow: SignFlow = .loginId
        
        var idType: AuthMethod = .email
        var idTypeSelectedIndex: Int = 0
        
        var title: String = "로그인"
        var text: String = ""
        var placeholder: String = " 이메일 입력"
        var submitBtnLabel: String = "코드 전송"
        var errorMessage: String = ""
        var shouldDisableTextField: Bool = false
        
        var activatedState: SignActivatedState = .allDeactivated
        let fullWidth: CGFloat = UIConstants.Width.screenWidth - 16
        var barAlignment: Alignment = .bottomLeading
        var barWidth: CGFloat = 20
        var barDuration: CGFloat = 0.5
        var isFirstRequest = true // barAlignment 설정을 바꿀때 사용
        
        var apiFetchState: ApiFetchState = .idle
        var isCheckingNickname: Bool = false
        
        var id = ""
        var session: String? = nil
        var otp = ""
        var nickname: String? = nil
        var sportsInterest: [String]? = nil
    }
    
    enum Action {
        case updateSignFlow(signFlow: SignFlow)
        
        case selectIdType(index: Int)
        case updateText(text: String)
        case submit
        
        // private
        case checkIdValidation
        case sendLoginOtp
        case sendLoginOtpSuccess(session: String)
        case confirmLoginOtp
        
        case sendSignUpOtp
        case confirmSignUpOtp
        case checkNickname
        case checkNicknameSuccess(result: Bool)
        case reserveNickname
        case reserveNicknameSuccess(result: Bool)
        case completeSignUp
        case completeSignUpSuccess(result: Bool)
        case signUpIdSuccess
        
        case responseFailure(APIHTTPError)
//        case clearErrorMessage
        
        case updateBarState
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateSignFlow(let signFlow):
                state.currentFlow = signFlow
                state.activatedState = .allDeactivated
                state.apiFetchState = .success
                state.isFirstRequest = true
                
//                if state.barAlignment == .bottomLeading {
//                    state.barAlignment = .bottomTrailing
//                } else {
//                    state.barAlignment = .bottomLeading
//                }
                
                switch signFlow {
                case .loginId:
                    state.title = "로그인"
                    state.placeholder = " 이메일 입력"
                    state.submitBtnLabel = "코드 전송"
                    
                case .loginOtp:
                    state.title = "코드 인증"
                    state.placeholder = " 인증 코드"
                    state.submitBtnLabel = "확인"
                    
                case .signUpId:
                    return .run { send in
                        await send(.selectIdType(index: 0))
                        await send(.signUpIdSuccess)
                    }
                    
                case .signUpOtp:
                    state.title = "코드 인증"
                    state.placeholder = " 인증 코드"
                    state.submitBtnLabel = "확인"
                    
                case .signUpNickname:
                    state.title = "닉네임"
                    state.placeholder = " 닉네임 입력"
                    state.submitBtnLabel = "다음"
                    
                case .signUpSportsInterest:
                    state.title = "스포츠 선택"
                    state.submitBtnLabel = "선택 완료"
//                    state.isActivated = true
                    
                case .signUpSuccess:
                    state.title = "가입 완료!"
                }
                
                return .send(.updateText(text: ""))
                
            case .selectIdType(let index):
                state.idTypeSelectedIndex = index
                
                if index == 0 {
                    state.idType = .email
                    state.placeholder = " 이메일 입력"
                } else {
                    state.idType = .phoneNumber
                    state.placeholder = " 전화번호 입력"
                }
                
                return .send(.updateText(text: ""))
                
            case .updateText(let text):
                // '코드 재전송'의 경우에는 아래 로직을 타면 안됨. 개선 필요할듯..?
                if state.shouldDisableTextField {
                    return .none
                }
                
                state.text = text
                state.errorMessage = ""
                
                switch state.currentFlow {
                case .loginId, .signUpId:
                    return .send(.checkIdValidation)
                    
                case .loginOtp, .signUpOtp:
                    if state.text.count == 6 {
                        state.activatedState = .allActivated
                    } else {
                        state.activatedState = .allDeactivated
                    }
                    
                case .signUpNickname:
                    return .run { send in
                        // TODO: 유효성 검사 먼저 필요
                        // text가 바뀌면 2초 후 닉네임 중복 검사 api(.checkNickname) 호출.
                        // 2초 이내에 또 text가 바뀌면 이전 실행 취소하고 새로 실행.
                        try await Task.sleep(for: .seconds(2))
                        await send(.checkNickname)
                    }
                    .cancellable(id: CheckNicknameCancelID(), cancelInFlight: true)
                default: break
                }
                
                return .send(.updateBarState)
                
            case .checkIdValidation:
                if state.idType == .email {
                    if validateEmail(state.text) {
                        state.activatedState = .allActivated
                    } else {
                        state.activatedState = .allDeactivated
                    }
                } else {
                    if validatePhoneNumber(state.text) {
                        state.activatedState = .allActivated
                    } else {
                        state.activatedState = .allDeactivated
                    }
                }
                
                return .send(.updateBarState)
                
            case .submit:
                state.errorMessage = ""
                
                switch state.currentFlow {
                case .loginId:
                    return .send(.sendLoginOtp)
                case .loginOtp:
                    if state.shouldDisableTextField {
                        return .send(.sendLoginOtp)
                    } else {
                        return .send(.confirmLoginOtp)
                    }
                case .signUpId:
                    return .send(.sendSignUpOtp)
                case .signUpOtp:
                    return .send(.confirmSignUpOtp)
                case .signUpNickname:
                    return .send(.reserveNickname)
                case .signUpSportsInterest:
                    return .send(.completeSignUp)
                case .signUpSuccess:
                    return .none
                }
            
            case .sendLoginOtp:
                if state.currentFlow == .loginId {
                    state.id = state.text
                }
                
                state.apiFetchState = .fetching
                state.activatedState = .allDeactivated
                
                let id = state.id
                let method = state.idType
                return .run { send in
                    do {
                        await send(.updateBarState)
                        
                        try await Task.sleep(for: .seconds(3))
                        
                        let body = StartAuthRequest(id: id, method: method)
                        let result = try await signClient.startLoginAuth(body: body)
                        
                        await send(.sendLoginOtpSuccess(session: result.session))
                    } catch {
                        if let err = error as? APIHTTPError {
                            await send(.responseFailure(err))
                        }
                    }
                }
                
            case .sendLoginOtpSuccess(let session):
                state.session = session
                state.shouldDisableTextField = false
                
                return .send(.updateSignFlow(signFlow: .loginOtp))
                
            case .confirmLoginOtp:
                state.otp = state.text
                
                state.apiFetchState = .fetching
                state.activatedState = .allDeactivated
                
                guard let session = state.session else {
                    // TODO: 오류 처리 필요
                    return .none
                }
                let id = state.id
                let otp = state.otp
                return .run { send in
                    do {
                        await send(.updateBarState)
                        
                        try await Task.sleep(for: .seconds(3))
                        
                        let body = ConfirmAuthRequest(id: id, otp: otp, session: session)
                        let result = try await signClient.confirmLoginAuth(body: body)
                        
                        // 로그인 성공 후 MoatView를 보여준다
                        UserDefaults.standard.set(result.idToken, forKey: "idToken")
                        UserDefaults.standard.set(result.accessToken, forKey: "accessToken")
                        UserDefaults.standard.set(result.refreshToken, forKey: "refreshToken")
                    } catch {
                        if let err = error as? APIHTTPError {
                            await send(.responseFailure(err))
                        }
                    }
                }
                
            case .sendSignUpOtp:
                if state.id.isEmpty {
                    state.id = state.text
                }
                
                let body = SignUpInitiateRequest(id: state.id, method: state.idType)
                
                state.apiFetchState = .fetching
                
                return .run { send in
                    do {
//                        try await Task.sleep(for: .seconds(3))
                        
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
                    } catch {
                        
                    }
                }
                
            case .checkNickname:
                state.nickname = state.text
                state.isCheckingNickname = true
                state.activatedState = .allDeactivated
                
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
//                    state.isActivated = true
                } else {
                    state.apiFetchState = .failure("")
//                    state.isActivated = false
                    state.errorMessage = "이미 사용중인 닉네임입니다."
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
                
            case .signUpIdSuccess:
                state.id = ""
                state.session = nil
                state.otp = ""
                
                state.title = "회원가입"
                state.submitBtnLabel = "코드 전송"
                
                return .none
                
            case .responseFailure(let apiError):
                state.apiFetchState = .failure("")
                
                var authErrorCode = AuthErrorCode.unknown
                
                if let code = apiError.apiCode, let message = apiError.message {
                    if let errorCode = AuthErrorCode.init(rawValue: code) {
                        switch errorCode {
                        default:
                            authErrorCode = errorCode
                            state.errorMessage = message
                        }
                    }
                }
                
                switch state.currentFlow {
                case .loginId:
                    if authErrorCode == .userNotFound {
                        state.activatedState = .allActivated
                    }
                    
                case .loginOtp:
                    if authErrorCode == .otpInvalid {
                        if let session = apiError.details?["session"] {
                            state.session = session
                        }
                        
                        state.submitBtnLabel = "확인"
                        state.activatedState = .allActivated
                    } else if authErrorCode == .otpExpired {
                        state.submitBtnLabel = "코드 재전송"
                        state.activatedState = .allActivated
                        
                        state.text = ""
                        state.shouldDisableTextField = true
                    } else if authErrorCode == .otpAttemptLimitExceeded {
                        state.submitBtnLabel = "코드 재전송"
                        state.activatedState = .allActivated
                        
                        state.text = ""
                        state.shouldDisableTextField = true
                    }
                default: break
                }
                
                return .send(.updateBarState)
                
            case .updateBarState:
                if state.apiFetchState == .fetching {
                    if state.isFirstRequest {
                        state.isFirstRequest = false
                        if state.barAlignment == .bottomLeading {
                            state.barAlignment = .bottomTrailing
                        } else {
                            state.barAlignment = .bottomLeading
                        }
                    }
                    
                    state.barDuration = 10
                } else {
                    state.barDuration = 0.5
                }
                
                switch state.activatedState {
                case .allActivated:
                    // NOTE: 같은 크기로 state.barWidth를 바꾸면 animation이 trigger가 안됨
                    if state.barWidth == state.fullWidth {
                        state.barWidth = state.fullWidth - 0.1
                    } else {
                        state.barWidth = state.fullWidth
                    }
                    
                case .onlyButtonActivated, .allDeactivated:
                    if state.barWidth == 20 {
                        state.barWidth = 20.2
                    } else {
                        state.barWidth = 20
                    }
                }
                
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
