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
    @State private var updateText = ""
    @State private var hstackWidth: CGFloat = UIConstants.Width.screenWidth - 16
    @State private var barWidth: CGFloat = 20
    @State private var barAlignment: Alignment = .bottomLeading
    @State private var barDuration: Double = 0.5
    
    @FocusState private var isFocused: Bool

    var body: some View {
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
                    signStore.send(.selectType(index: index), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                }
                .padding(.vertical, 8)
                .uiState(visibleState: signStore.currentFlow == SignFlow.loginId || signStore.currentFlow == SignFlow.signUpId)
                
                HStack {
                    TextField(signStore.placeholder, text: $updateText)
                        .frame(height: 50)
                        .font(.system(size: 16))
                        .focused($isFocused)
                        .uiState(visibleState: signStore.currentFlow != SignFlow.signUpSportsInterest)
                    
                    Button {
                        signStore.send(.submit)
                    } label: {
                        Text(signStore.submitBtnLabel)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(signStore.isValid ? Color("moare") : .gray)
                }
                
                VStack {
                    if signStore.currentFlow != SignFlow.signUpSportsInterest {
                        Rectangle()
                            .fill(Color("moare"))
                            .frame(width: barWidth, height: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .animation(.easeInOut(duration: barDuration), value: barWidth)
                    }
                }
                .frame(maxWidth: .infinity, alignment: barAlignment)
                .onChange(of: signStore.apiFetchState) {
                    if signStore.isCheckingNickname {
                        if signStore.apiFetchState == ApiFetchState.fetching {
                            barWidth = hstackWidth
                            barDuration = 4
                        } else if case ApiFetchState.failure = signStore.apiFetchState {
                            barWidth = 20
                            barDuration = 0.5
                        }
                    } else {
                        if signStore.apiFetchState == ApiFetchState.fetching {
                            barAlignment = if barAlignment == Alignment.bottomLeading {
                                Alignment.bottomTrailing
                            } else {
                                Alignment.bottomLeading
                            }
                            
                            barWidth = 10
                            barDuration = 4
                        } else if signStore.apiFetchState == ApiFetchState.success {
                            barWidth = 20
                            barDuration = 0.5
                        } else if case ApiFetchState.failure = signStore.apiFetchState {
                            if [.loginOtpExpired, .loginOtpLimitExceeded, .signUpOtpExpired].contains(signStore.currentFlow) {
                                barWidth = hstackWidth
                                barDuration = 0.5
                            } else {
                                barWidth = 20
                                barDuration = 0.5
                            }
                        }
                    }
                }
                .onChange(of: updateText) {
                    signStore.send(.updateText(text: updateText))
                    
                    if !updateText.isEmpty && !signStore.errorText.isEmpty {
                        signStore.send(.clearErrorText)
                    }
                }
                .onChange(of: signStore.text) {
                    let newValue = signStore.text
                    
                    if newValue != updateText {
                        updateText = newValue
                    }
                }
                .onChange(of: signStore.isValid) {
                    let isValid = signStore.isValid
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        barWidth = isValid ? hstackWidth : 20
                    }
                }
                
                Text(signStore.errorText)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 13))
                    .foregroundStyle(Color("moare"))
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
            
            isFocused = true
            updateText = signStore.text
        }
    }
}
