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
    @State private var tos = false
    @State private var privacy = false
    
    private var allCheckedBinding: Binding<Bool> {
        Binding(
            get: { tos && privacy },
            set: { newValue in
                tos = newValue
                privacy = newValue
                signStore.send(.updateTermsChecked(newValue))
            }
        )
    }
    
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
                                if currentFlow == .loginId {
                                    signStore.send(.updateSignFlow(signFlow: .signUpId))
                                } else if currentFlow == .signUpId {
                                    signStore.send(.updateSignFlow(signFlow: .loginId))
                                }
                            } label : {
                                Text(currentFlow == .loginId ? "회원가입" : "로그인")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
                
                if currentFlow == .signUpTerms {
                    SignUpTerms(tos: $tos, privacy: $privacy)
                        .padding(.bottom, 12)
                        .onChange(of: tos) {
                            signStore.send(.updateTermsChecked(allCheckedBinding.wrappedValue))
                        }
                        .onChange(of: privacy) {
                            signStore.send(.updateTermsChecked(allCheckedBinding.wrappedValue))
                        }
                }
                
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
                    } else if currentFlow == .signUpTerms {
                        HStack {
                            Toggle("", isOn: allCheckedBinding)
                                .toggleStyle(CheckboxToggleStyle())
                                .padding(.trailing, 8)
                            
                            Button(action: {
                                allCheckedBinding.wrappedValue.toggle()
                            }) {
                                Text("전체 동의")
                            }
                            .foregroundStyle(.primary)
                        }
                        .padding(.trailing, 8)
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
                .padding(.bottom, currentFlow == .signUpTerms ? 12 : 0)
                
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
                        .foregroundStyle(.moare)
                }
//                .frame(height: 15)
                .frame(height: 33) // 2줄짜리 오류 문구 때문에 높이 늘림
                .padding(.top, 8)
                
                if currentFlow == .signUpSportsInterests {
                    SportList(selectedSports: signStore.sportsInterests ?? []) { sport in
                        signStore.send(.updateSport(sport: sport))
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
