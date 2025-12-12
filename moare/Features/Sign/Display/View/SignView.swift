//
//  SignView.swift
//  moare
//
//  Created by 최지혜 on 8/18/25.
//

import SwiftUI
import ComposableArchitecture

struct SignView: View {
    let store: StoreOf<SignStore>
    
    @State private var show = false
    @State private var text = ""
    @State private var termsChecked: [TermKey: Bool] = [:]
    
    // TODO: 약관 동의 하는 쪽 코드 뭔가 복잡한 것 같고 이상함.. 나중에 개선 필요함.
    private var requiredTermsAllChecked: Bool {
        store.termsList
            .filter { $0.isRequired }
            .allSatisfy { termsChecked[TermKey(termType: $0.termType, version: $0.version)] == true }
    }
    
    private var allRequiredTermsBinding: Binding<Bool> {
        Binding(
            get: { requiredTermsAllChecked },
            set: { newValue in
                for t in store.termsList where t.isRequired {
                    termsChecked[t.selfKey] = newValue
                }
                store.send(.updateTermsAgreements(requiredAllChecked: requiredTermsAllChecked, termsChecked: termsChecked))
            }
        )
    }
    
    @FocusState private var isFocused: Bool

    var body: some View {
        let currentFlow = store.currentFlow
        
        VStack(spacing: 0) {
            if show {
                ZStack {
                    Text(store.title)
                        .font(.system(size: 16, weight: .medium))
                    
                    HStack {
                        Spacer()
                        if currentFlow == .loginId || currentFlow == .signUpId {
                            Button {
                                if currentFlow == .loginId {
                                    store.send(.updateSignFlow(signFlow: .signUpId))
                                } else if currentFlow == .signUpId {
                                    store.send(.updateSignFlow(signFlow: .loginId))
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
                    SignUpTerms(terms: store.termsList, checked: $termsChecked)
                        .padding(.bottom, 12)
                        .onChange(of: termsChecked) {
                            store.send(.updateTermsAgreements(requiredAllChecked: requiredTermsAllChecked, termsChecked: termsChecked))
                        }
                }
                
                if currentFlow == .signUpSportsInterests {
                    Text("보는거나 하는걸 즐기는 스포츠들을 선택해 주세요")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
                
                IdTypeSelectButton(selectedIndex: store.idTypeSelectedIndex) { index in
                    store.send(.selectIdType(index: index), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                }
                .padding(.vertical, 8)
                .uiState(visibleState: currentFlow == .loginId || currentFlow == .signUpId)
                
                HStack {
                    if currentFlow == .signUpSportsInterests {
                        SelectedSports(sports: store.sportsInterests ?? [])
                    } else if currentFlow == .signUpTerms {
                        HStack {
                            Toggle("", isOn: allRequiredTermsBinding)
                                .toggleStyle(CheckboxToggleStyle())
                                .padding(.trailing, 8)
                            
                            Button(action: {
                                allRequiredTermsBinding.wrappedValue.toggle()
                            }) {
                                Text("전체 동의")
                            }
                            .foregroundStyle(.primary)
                        }
                        .padding(.trailing, 8)
                    } else {
                        TextField(store.placeholder, text: $text)
                            .frame(height: 50)
                            .font(.system(size: 16))
                            .focused($isFocused)
                            .disabled(store.shouldDisableTextField)
                            .onChange(of: text) {
                                store.send(.updateText(text: text))
                            }
                            .onChange(of: store.text) {
                                let newValue = store.text
                                if newValue != text {
                                    text = newValue
                                }
                            }
                            .onChange(of: store.shouldDisableTextField) {
                                if !store.shouldDisableTextField {
                                    isFocused = true
                                }
                            }
                    }

                    if store.activatedState == .allActivated || store.activatedState == .onlyButtonActivated {
                        Button {
                            store.send(.submit)
                        } label: {
                            Text(store.submitBtnLabel)
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
                        Text(store.submitBtnLabel)
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
                        .frame(width: store.barWidth, height: 2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .animation(.easeInOut(duration: store.barDuration), value: store.barWidth)
                }
                .frame(maxWidth: .infinity, alignment: store.barAlignment)
                
                ZStack {
                    // TODO: 사용 가능한 사용자 이름인지 확인중 문구 띄우기?
                    if (currentFlow == .loginOtp || currentFlow == .signUpOtp) &&
                        !store.shouldDisableTextField &&
                        text.count != 6 {
                        // TODO: 숫자만 포함하게 정규식 추가
                        Text("인증번호 6자리를 입력해 주세요.")
                            .font(.system(size: 13))
                            .foregroundStyle(.gray)
                    }
                    
                    Text(store.errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(.moare)
                }
//                .frame(height: 15)
                .frame(height: 33) // 2줄짜리 오류 문구 때문에 높이 늘림
                .padding(.top, 8)
                
                if currentFlow == .signUpSportsInterests {
                    SportList(selectedSports: store.sportsInterests ?? []) { sport in
                        store.send(.updateSport(sport: sport))
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
