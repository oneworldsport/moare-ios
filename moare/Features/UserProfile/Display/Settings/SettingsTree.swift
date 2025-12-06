//
//  SettingsTree.swift
//  moare
//
//  Created by Mohwa Yoon on 12/6/25.
//

import Foundation

enum SettingsTree {
    static let root: SettingsNode = .branch("설정", children: [
        .branch("계정", children: [
            .leaf("로그아웃", action: .logout),
            .leaf("회원 탈퇴", action: .withdraw)
        ]),
        .branch("지원", children: [
            .leaf("문의 및 피드백", desc: "서비스 이용 중 불편한 점이나 개선 아이디어가 있다면 아래 이메일로 보내주세요.\n\n이메일: ymb3264@gmail.com", action: .none)
        ]),
        .branch("정보", children: [
            .leaf("이용약관", action: .openURL(Constants.Urls.privacyUrl)),
            .leaf("개인정보 처리방침", action: .openURL(Constants.Urls.privacyUrl))
        ])
    ])
}
