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
                        if currentFlow == .loginId || currentFlow == .signUpId {
                            Button {
                                signStore.send(.updateSignFlow(signFlow: .signUpId))
                            } label : {
                                Text(currentFlow == .loginId ? "회원가입" : "로그인")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
                
                if currentFlow == .signUpSportsInterests {
                    Text("보는거나 하는걸 즐기는 스포츠들을 선택해 주세요")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
                
                IdTypeSelectButton(selectedIndex: signStore.idTypeSelectedIndex) { index in
                    signStore.send(.selectIdType(index: index), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                }
                .padding(.vertical, 8)
                .uiState(visibleState: currentFlow == .loginId || currentFlow == .signUpId)
                
                HStack {
                    if currentFlow == .signUpSportsInterests {
                        SelectedSports(sports: signStore.sportsInterests ?? [])
                    } else {
                        TextField(signStore.placeholder, text: $text)
                            .frame(height: 50)
                            .font(.system(size: 16))
                            .focused($isFocused)
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
                    Rectangle()
                        .fill(Color("moare"))
                        .frame(width: signStore.barWidth, height: 2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .animation(.easeInOut(duration: signStore.barDuration), value: signStore.barWidth)
                }
                .frame(maxWidth: .infinity, alignment: signStore.barAlignment)
                
                ZStack {
                    // TODO: 사용 가능한 사용자 이름인지 확인중 문구 띄우기?
                    if (currentFlow == .loginOtp || currentFlow == .signUpOtp) &&
                        !signStore.shouldDisableTextField &&
                        text.count != 6 {
                        // TODO: 숫자만 포함하게 정규식 추가
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
                
                if currentFlow == .signUpSportsInterests {
                    SportList(selectedSports: signStore.sportsInterests ?? []) { sport in
                        signStore.send(.addSport(sport: sport))
                    }
                    .padding(.top, 8)
                }
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
