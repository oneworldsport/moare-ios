//
//  Checkbox.swift
//  moare
//
//  Created by Mohwa Yoon on 12/3/25.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
//                configuration.label
            }
            .frame(width: 22, height: 22)
            .background(
                // TODO: radius 더 늘려서 확인해보기
                RoundedRectangle(cornerRadius: 5)
                    .fill(configuration.isOn ? .moare : .clear)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(configuration.isOn ? .moare : .secondary, lineWidth: 1)
            }
        }
    }
}
