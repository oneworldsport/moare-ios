//
//  FormView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI
import ComposableArchitecture

struct FormView: View {
    @Bindable var store: StoreOf<FormStore>
    
    @State private var show = false
    @State var text = ""
    
    private let hashtagList: [String] = ["#축구", "#농구", "#야구", "#테니스"]
    
//    private var isEditing: Bool {
//       if case .update = store.moatMode { return true }
//       return false
//     }
    
    var body: some View {
        VStack {
            if show {
                VStack {
                    Text("모트 작성")
                    
                    Text("첫번째 줄은 메인에서 주제(썸네일?)로 표시됩니다.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $store.content)
                        .frame(height: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray, lineWidth: 1)
                        }
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(hashtagList, id: \.self) { item in
                                Button(action: {}) {
                                    Text(item)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // 만들기, 생성하기, 올리기, 공유하기, 작성하기
                    Button(action: {
                        store.send(.submitTapped)
                    }) {
                        Text("작성하기")
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
//    FormView()
//}
