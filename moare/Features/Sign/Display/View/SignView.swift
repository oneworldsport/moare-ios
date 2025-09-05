//
//  SignView.swift
//  moare
//
//  Created by 최지혜 on 8/18/25.
//

import SwiftUI
import ComposableArchitecture

struct SignView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State var signStore: StoreOf<SignStore>? = nil
    
    @State private var updateText = ""
    @State private var hstackWidth: CGFloat = UIConstants.Width.screenWidth - 16
    @State private var barWidth: CGFloat = 20
    @State private var underlineLeading = true
    
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            if let signStore {                
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
                
                IdTypeSelectButton(selectedIndex: signStore.idTypeSelectedIndex) { index in
                    signStore.send(.selectType(index: index), animation: AnimationConstants.AnimationType.mediumDefaultAnimation)
                }
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
                .background(alignment: [.loginId, .signUpNickname, .signUpId].contains(signStore.currentFlow) ? .bottomLeading : .bottomTrailing) {
                    if signStore.currentFlow != SignFlow.signUpSportsInterest {
                        if [.loginOtpExpired, .loginOtpLimitExceeded, .signUpOtpExpired].contains(signStore.currentFlow) {
                            Rectangle()
                                .fill(Color("moare"))
                                .frame(width: hstackWidth, height: 2)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Rectangle()
                                .fill(Color("moare"))
                                .frame(width: barWidth, height: 2)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .animation(.easeInOut(duration: 0.5), value: barWidth)
                        }
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
            // init SignStore
            let signStore: StoreOf<SignStore> = storeManager.getStore(forKey: StoreKeys.signStore) ?? {
                let newStore = Store(initialState: SignStore.State()) {
                    SignStore()
                }
                
                storeManager.setStore(newStore, forKey: StoreKeys.signStore)
                
                return newStore
            }()
            
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                self.signStore = signStore
            }
            
            isFocused = true
            
            updateText = signStore.text
        }
        .onChange(of: updateText) {
            signStore?.send(.updateText(text: updateText))
        }
        .onChange(of: signStore?.text ?? "") { newValue in
            if newValue != updateText {
                updateText = newValue
            }
        }
        .onChange(of: signStore?.isValid ?? false) { isValid in
            withAnimation(.easeInOut(duration: 0.5)) {
                barWidth = isValid ? hstackWidth : 20
            }
        }
    }
}
