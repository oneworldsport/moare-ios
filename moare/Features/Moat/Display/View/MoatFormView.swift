//
//  FormView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

struct MoatFormView: View {
    @Bindable var store: StoreOf<MoatFormStore>
    
    @State private var show = false
    @State var text = ""
    @State private var touchSubmit = false
    
//    private let hashtagList: [String] = ["#축구", "#농구", "#야구", "#테니스"]
    
//    private var isEditing: Bool {
//       if case .update = store.moatMode { return true }
//       return false
//     }
    private var isButtonEnabled: Bool {
        !store.content.isBlank && !store.sportTags.isEmpty
    }
    
    var body: some View {
        VStack {
            if show {
                VStack {
                    if store.moat == nil {
                        Text("모트 작성")
                    } else {
                        Text("모트 수정")
                    }
                    
                    
                    Text("첫번째 줄은 메인에서 주제(썸네일?)로 표시됩니다.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $store.content)
                        .frame(height: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray, lineWidth: 1)
                        }
                                        
                    SportsSelectForm(sportsInterests: store.sportTags, isHashTag: true) { sport in
                        store.send(.updateSportsInterests(sport))
                    }
                    
                    // 에러 메시지
                    if touchSubmit && store.content.isBlank {
                        Text("내용을 입력해 주세요.")
                            .font(.system(size: 13))
                            .foregroundStyle(.moare)
                    } else if touchSubmit && store.sportTags.isEmpty {
                        Text("해시태그를 입력해 주세요.")
                            .font(.system(size: 13))
                            .foregroundStyle(.moare)
                    }
                    
                    // 만들기, 생성하기, 올리기, 공유하기, 작성하기
                    Button(action: {
                        if isButtonEnabled {
                            store.send(.submitTapped)
                        } else {
                            touchSubmit = true
                        }
                    }) {
                        Text(store.moat == nil ? "작성하기" : "수정하기")
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.moare, lineWidth: 1)
                            }
                            .foregroundStyle(.moare)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 8)
                .background(.white)
            }
        }
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
        }
        
    }
}

//#Preview {
//    MoatFormView()
//}
