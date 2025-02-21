//
//  TestView.swift
//  moare
//
//  Created by Mohwa Yoon on 2/21/25.
//

import SwiftUI

struct TestView: View {
    @State private var isInfoIconVisible = false
    @State private var isNoticeOpened = false
    @State private var noticeIconPosition: CGFloat = 0
    
    @FocusState var focusState: Bool
    
    var body: some View {
        VStack {
            VStack(alignment: .trailing) {
                Spacer()
                Text("dd")
                    .background(.red)
            }
            .frame(width: 100, height: 100)
            .background(.blue)
            
            ZStack {
                //            NoticeBox()
                ////                .background(.red)
                //                .position(x: UIConstants.Width.screenWidth - 92, y: noticeIconPosition - 120)
                //
                //            HStack {
                //                Spacer()
                //
                //                Button(action: {
                //                    isNoticeOpened.toggle()
                //                }) {
                //                    Image(systemName: "info.circle")
                //                        .tint(.secondary)
                //                }
                //                .background(
                //                    GeometryReader { geometry in
                //                        Color.clear.preference(key: NoticeIconPositionKey.self, value: geometry.frame(in: .global).midY)
                //                    }
                //                )
                //                .onPreferenceChange(NoticeIconPositionKey.self) { value in
                //                    noticeIconPosition = value
                //                }
                //            }
                //            .padding(.trailing, 12)
                ////            .padding(.bottom, 6)
                
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        NoticeBox()
                        //                        .opacity(isNoticeOpened ? 1 : 0)
                        
                        Button(action: {
                            isNoticeOpened.toggle()
                        }) {
                            Image(systemName: "info.circle")
                                .tint(.secondary)
                        }
                    }
                }
                //            .padding(.trailing, 12)
                .offset(x: -12, y: -90) // 124 / 2 + 25 + 3
                //            .position(x: UIConstants.Width.screenWidth - 92, y: noticeIconPosition - 150)
                
                ZStack {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .opacity(0.5)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(key: NoticeIconPositionKey.self, value: geometry.frame(in: .global).midY)
                            }
                        )
                        .onPreferenceChange(NoticeIconPositionKey.self) { value in
                            noticeIconPosition = value
                        }
                    
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                }
            }
        }
        
    }
}

struct NoticeIconPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    TestView()
}
