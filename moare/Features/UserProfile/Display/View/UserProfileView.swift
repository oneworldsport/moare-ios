//
//  UserProfileView.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

import SwiftUI

struct UserProfileView: View {
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Circle()
                    .fill(.moare)
                    .frame(width: 80, height: 80)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("모아레")
                        
                        Spacer()
                        
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                    }
                    
                    Spacer()
                    
                    Text("#축구 #농구 #야구")
                }
            }
            .frame(height: 80)
            .padding(.horizontal, 8)
            
            HDivider()
            
            ScrollView {
                LazyVStack(spacing: 28) {
                    ForEach(0..<9) { _ in
                        MoatItem(moatType: .userProfile)
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

#Preview {
    UserProfileView()
}
