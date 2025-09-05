//
//  IdTypeSelectButton.swift
//  moare
//
//  Created by 최지혜 on 8/26/25.
//

import SwiftUI

struct IdTypeSelectButton: View {
    let selectedIndex: Int
    let action: (Int) -> Void
    
    private let buttonLabels = ["이메일", "전화번호"]
    
    private let buttonWidth = (UIConstants.Width.screenWidth / 2) - 16
    
    @State private var buttonBarOffset: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ForEach(buttonLabels.indices, id:\.self) { index in
                    Button(action: {
                        action(index)
                    }) {
                        Text(buttonLabels[index])
                            .font(.system(size: 15, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 37)
                    }
                    .foregroundStyle(.primary)
                    
                    if index == 0 {
                        VCapsuleBar()
                    }
                }
            }
            .frame(height: 37)
            
            HCapsuleBar()
                .offset(x: buttonBarOffset)
        }
        .onAppear() {
            buttonBarOffset = getOffsetOfAniCapsuleBar(itemWidth: buttonWidth, index: selectedIndex)
        }
        .onChange(of: selectedIndex) {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                if selectedIndex == 0 {
                    buttonBarOffset = getOffsetOfAniCapsuleBar(itemWidth: buttonWidth, index: selectedIndex)
                } else {
                    buttonBarOffset = 16 + getOffsetOfAniCapsuleBar(itemWidth: buttonWidth, index: selectedIndex)
                }
            }
        }
    }
}

