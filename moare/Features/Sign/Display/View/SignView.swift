//
//  SignView.swift
//  moare
//
//  Created by 최지혜 on 8/18/25.
//

import SwiftUI
import ComposableArchitecture

struct SignView: View {
    let signStore = Store(initialState: SignStore.State()) { SignStore() }
    
    @State private var show = false
    @State private var text = ""
    
    @FocusState private var isFocused: Bool

    var body: some View {
        let currentFlow = signStore.currentFlow
        
        VStack(spacing: 0) {
            if show {
                ZStack {
                    Text(signStore.title)
                        .font(.system(size: 16, weight: .medium))
                    HStack {
                        Spacer()
                        Button {
                            signStore.send(.updateSignFlow(signFlow: .signUpId))
                        } label : {
                            Text("회원가입")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.gray)
                        }
                        .uiState(visibleState: signStore.currentFlow == SignFlow.loginId)
                    }
                }
                .padding(.vertical, 8)
                
                IdTypeSelectButton(selectedIndex: signStore.idTypeSelectedIndex) { index in
                    signStore.send(.selectIdType(index: index), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                }
                .padding(.vertical, 8)
                .uiState(visibleState: currentFlow == SignFlow.loginId || currentFlow == SignFlow.signUpId)
                
                HStack {
                    TextField(signStore.placeholder, text: $text)
                        .frame(height: 50)
                        .font(.system(size: 16))
                        .focused($isFocused)
                        .uiState(visibleState: currentFlow != .signUpSportsInterest)
                        .disabled(signStore.shouldDisableTextField)
                        .onChange(of: text) {
                            signStore.send(.updateText(text: text))
                        }
                        .onChange(of: signStore.text) {
                            let newValue = signStore.text
                            if newValue != text {
                                text = newValue
                            }
                        }
                        .onChange(of: signStore.shouldDisableTextField) {
                            if !signStore.shouldDisableTextField {
                                isFocused = true
                            }
                        }

                    ZStack {
                        if signStore.activatedState == .allActivated || signStore.activatedState == .onlyButtonActivated {
                            Button {
                                signStore.send(.submit)
                            } label: {
                                Text(signStore.submitBtnLabel)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.white)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background {
                                        Capsule()
                                    }
                            }
                            .tint(Color("moare"))
                        } else {
                            Text(signStore.submitBtnLabel)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background {
                                    Capsule()
                                        .foregroundStyle(.gray)
                                        .opacity(0.7)
                                }
                        }
                    }
                }
                
                VStack {
                    if signStore.currentFlow != SignFlow.signUpSportsInterest {
                        Rectangle()
                            .fill(Color("moare"))
                            .frame(width: signStore.barWidth, height: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .animation(.easeInOut(duration: signStore.barDuration), value: signStore.barWidth)
                    }
                }
                .frame(maxWidth: .infinity, alignment: signStore.barAlignment)
                .onChange(of: signStore.apiFetchState) {
//                    if signStore.isCheckingNickname {
//                        if signStore.apiFetchState == ApiFetchState.fetching {
//                            barWidth = hstackWidth
//                            barDuration = 4
//                        } else if case ApiFetchState.failure = signStore.apiFetchState {
//                            barWidth = 20
//                            barDuration = 0.5
//                        }
//                    } else {
//                        if signStore.apiFetchState == ApiFetchState.fetching {
//                            barAlignment = if barAlignment == Alignment.bottomLeading {
//                                Alignment.bottomTrailing
//                            } else {
//                                Alignment.bottomLeading
//                            }
//                            
//                            barWidth = 10
//                            barDuration = 4
//                        } else if signStore.apiFetchState == ApiFetchState.success {
//                            barWidth = 20
//                            barDuration = 0.5
//                        } else if case ApiFetchState.failure = signStore.apiFetchState {
////                            if [.loginOtpExpired, .loginOtpLimitExceeded, .signUpOtpExpired].contains(signStore.currentFlow) {
////                                barWidth = hstackWidth
////                                barDuration = 0.5
////                            } else {
////                                barWidth = 20
////                                barDuration = 0.5
////                            }
//                        }
//                    }
                }
                
                ZStack {
                    // TODO: 숫자만 포함하게 정규식 추가
                    if (currentFlow == .loginOtp || currentFlow == .signUpOtp) &&
                        !signStore.shouldDisableTextField &&
                        text.count != 6 {
                        Text("인증번호 6자리를 입력해 주세요.")
                            .font(.system(size: 13))
                            .foregroundStyle(.gray)
                    }
                    
                    Text(signStore.errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color("moare"))
                }
                .frame(height: 15)
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
            
            isFocused = true
        }
    }
}
