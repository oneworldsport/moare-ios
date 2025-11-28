//
//  UserProfileUpdateFormView.swift
//  moare
//
//  Created by Mohwa Yoon on 11/14/25.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

struct UserProfileUpdateFormView: View {
    let store: StoreOf<UserProfileUpdateFormStore>
    
    @State private var show = false
    @State private var userHandleText = ""
    @State private var bioText = ""
    @State private var labelWidth: CGFloat = 80
    
    @FocusState var userHandleFocusState: Bool
    
    private let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        let userProfile = store.userProfile
        let profileImageUrl = userProfile.profileImageUrl != nil ? "https://moare-sns-profile-images.s3.ap-northeast-2.amazonaws.com/\(userProfile.profileImageUrl!)" : nil
        
        VStack(spacing: 0) {
            if show {
                // 프로필 이미지
                Button(action: {
                    store.send(.showImageEdit)
                }) {
                    UpdateFormProfileImage(url: store.tempImageUrl ?? profileImageUrl, size: 120)
                }
                .foregroundStyle(.primary)
                .padding(.bottom, 8)
                
                // 사용자 이름
                HStack(spacing: 0) {
                    Text("사용자 이름")
                        .font(.system(size: 15))
                        .frame(width: labelWidth, alignment: .leading)
                    
                    Capsule()
                        .fill(.moare)
                        .frame(width: 1, height: 20)
                        .padding(.trailing, 8)
                    
                    TextField("사용자 이름 입력", text: $userHandleText)
                        .focused($userHandleFocusState)
                        .disabled(store.isUserHandleTextFieldDisabled)
                        .onChange(of: userHandleText) {
                            store.send(.checkUserHandle(userHandleText))
                        }
                    
                    if store.userHandleCheckState == .fetching {
                        ProgressView()
                            .foregroundStyle(.moare)
                    } else if store.userHandleCheckState == .success {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.moare)
                    }
                }
                .padding(.bottom, 8)
                
                // TODO: HStack, VStack 사용하게 구조 수정
                if case .failure(let err) = store.userHandleCheckState {
                    HStack(spacing: 0) {
                        // 옆에 띄우기 위한 코드
                        Text("")
                            .font(.system(size: 15))
                            .frame(width: labelWidth)
                            .opacity(0)
                        // 옆에 띄우기 위한 코드
                        Capsule()
                            .fill(.moare)
                            .frame(width: 1, height: 20)
                            .opacity(0)
                            .padding(.trailing, 8)
                        
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundStyle(Color("moare"))
                            .padding(.bottom, 8)
                        
                        Spacer()
                    }
                }
                
                // 소개
                HStack(alignment: .top, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("소개")
                            .font(.system(size: 15))
                            .frame(width: labelWidth, alignment: .leading)
                        
                        Capsule()
                            .fill(.moare)
                            .frame(width: 1, height: 20)
                    }
                    .padding(.trailing, 8)
                    .padding(.top, 8) // TextEditor 내부의 기본 inset때문에
                    
                    TextEditor(text: $bioText)
                        .frame(height: 100)
//                        .padding(.vertical, 2)
//                        .padding(.horizontal, 6)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(.moare, lineWidth: 1)
//                        }
                        .onChange(of: bioText) {
                            store.send(.updateBio(bioText))
                        }
                }
                .padding(.bottom, 8)
                
                // 관심 스포츠
                HStack(spacing: 0) {
                    Text("관심 스포츠")
                        .font(.system(size: 15))
                        .frame(width: labelWidth, alignment: .leading)
                        .readSize { size in
                            labelWidth = size.width
                        }
                    
                    Capsule()
                        .fill(.moare)
                        .frame(width: 1, height: 20)
                        .padding(.trailing, 8)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(store.sportsInterests.indices, id: \.self) { index in
                                let sport = store.sportsInterests[index]
                                
                                Text(sport)
                                
                                if index != store.sportsInterests.count - 1 {
                                    Capsule()
                                        .frame(width: 1, height: 15)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
                
                SportsSelectForm(sportsInterests: store.sportsInterests) { sport in
                    store.send(.updateSportsInterests(sport))
                }
                
                Button(action: {
                    store.send(.submit)
                }) {
                    Text("완료")
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.moare, lineWidth: 2)
                        }
                }
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
            
            userHandleText = userProfile.userHandle
            if let bio = userProfile.bio {
                bioText = bio
            }
        }
    }
}
