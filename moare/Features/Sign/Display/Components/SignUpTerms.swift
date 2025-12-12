//
//  SignUpTerms.swift
//  moare
//
//  Created by Mohwa Yoon on 12/5/25.
//

import SwiftUI

struct SignUpTerms: View {
    let terms: [TermsResponse]
    @Binding var checked: [TermKey: Bool]
    
    @State private var url = ""
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ForEach(terms, id: \.selfKey) { term in
                    let title = term.termType == TermType.privacy ? "(필수)개인정보 수집 및 이용 동의" : "(필수)이용약관 동의"
                    
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { checked[term.selfKey] ?? false },
                            set: { checked[term.selfKey] = $0 }
                        ))
                        .toggleStyle(CheckboxToggleStyle())
                        .padding(.trailing, 8)
                        
                        Button(action: {
                            url = term.url
                            isPresented = true
                        }) {
                            Text(title)
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.primary)
                    }
                    
                }
            }
            
            TermsWebView(url: url, isPresented: $isPresented)
        }
    }
}

//ForEach(termsList) { $item in
//    let terms = item.data
//    let title = terms.termType == TermType.privacy ? "(필수)개인정보 수집 및 이용 동의" : "(필수)이용약관 동의"
//    
//    HStack {
//        Toggle("", isOn: $item.isAgreed)
//            .toggleStyle(CheckboxToggleStyle())
//            .padding(.trailing, 8)
//        
//        Button(action: {
//            url = terms.url
//            isPresented = true
//        }) {
//            Text(title)
//            
//            Image(systemName: "chevron.right")
//        }
//        .foregroundStyle(.primary)
//    }
//}
