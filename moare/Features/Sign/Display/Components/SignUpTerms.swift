//
//  SignUpTerms.swift
//  moare
//
//  Created by Mohwa Yoon on 12/5/25.
//

import SwiftUI

struct SignUpTerms: View {
    @Binding var tos: Bool
    @Binding var privacy: Bool
    
    @State private var url = ""
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Toggle("", isOn: $tos)
                        .toggleStyle(CheckboxToggleStyle())
                        .padding(.trailing, 8)
                    
                    Button(action: {
                        url = Constants.Urls.privacyUrl
                        isPresented = true
                    }) {
                        Text("(필수)이용약관 동의")
                        
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.primary)
                }
                
                HStack {
                    Toggle("", isOn: $privacy)
                        .toggleStyle(CheckboxToggleStyle())
                        .padding(.trailing, 8)
                    
                    Button(action: {
                        url = Constants.Urls.privacyUrl
                        isPresented = true
                    }) {
                        Text("(필수)개인정보 수집 및 이용 동의")
                        
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.primary)
                }
            }
            
            TermsWebView(url: url, isPresented: $isPresented)
        }
    }
}
