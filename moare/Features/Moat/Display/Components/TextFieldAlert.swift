//
//  SettingWindow.swift
//  moare
//
//  Created by 최지혜 on 10/20/25.
//
import SwiftUI
import UIKit

enum MoatSettingItems: String, CaseIterable, Equatable, Identifiable {
    case report, updateMoat, deleteMoat, three
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .report: "신고하기"
        case .updateMoat: "모트 수정하기"
        case .deleteMoat: "모트 삭제하기"
        default: "^^"
        }
    }
}

enum UserProfileSettingItems: String, CaseIterable, Equatable, Identifiable {
    case report, updateProfile
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .report: "신고하기"
        case .updateProfile: "프로필 수정"
            
        default: "^^"
        }
    }
}

struct ReportAlert: View {
    @State var text = ""
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
            ZStack {
                VStack {
                    Text("모트 신고하기")
                    
                    TextEditor(text: $text)
                        .frame(height: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray, lineWidth: 1)
                        }
                    
                    Button(action : {
                        print("clicked")
                        isPresented = false
                    }) {
                        Text("신고하기")
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 100)
        }
    
}

struct TextFieldAlert: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var text: String
    
    var title: String
    var message: String? = nil
    
    var onSubmit: (String) -> Void
    var onCancel: (() -> Void)? = nil
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ host: UIViewController, context: Context) {
        guard isPresented, host.presentedViewController == nil else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
//        alert.addTextField { textfield in
//            textfield.placeholder = "신고 내용"
//            textfield.text = text
//        }
        let textFieldsVC = UIViewController()
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text
        
        textFieldsVC.view.addSubview(textView)
        
        NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: textFieldsVC.view.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: textFieldsVC.view.trailingAnchor),
                textView.topAnchor.constraint(equalTo: textFieldsVC.view.topAnchor),
                textView.bottomAnchor.constraint(equalTo: textFieldsVC.view.bottomAnchor),
                textView.heightAnchor.constraint(equalToConstant: 120) // 원하는 높이
            ])
        
        alert.setValue(textFieldsVC, forKey: "contentViewController")
        // contentViewController 인 이유 : UIAlertController가 특수하게 인식하는 비공식 키는 contentViewController 뿐이다.
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            DispatchQueue.main.async { isPresented = false }
            onCancel?()
            text = ""
        }
        
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            let newValue = textView.text ?? text
            DispatchQueue.main.async {
                text = newValue
                isPresented = false
            }
            onSubmit(newValue)
            text = ""
        }
    
        alert.addAction(cancel)
        alert.addAction(ok)
        
        host.present(alert, animated: true) 
    }
}
