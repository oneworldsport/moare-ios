//
//  SettingsNode.swift
//  moare
//
//  Created by Mohwa Yoon on 12/6/25.
//

import SwiftUI

struct SettingsNode: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let desc: String?
    let systemImage: String?
    let action: Action
    let children: [SettingsNode]
    
    enum Action: Hashable {
        case push, logout, withdraw, none
        case openURL(String)
    }
    
    static func leaf(
        _ title: String,
        desc: String? = nil,
        systemImage: String? = nil,
        action: Action
    ) -> SettingsNode {
        SettingsNode(
            title: title,
            desc: desc,
            systemImage: systemImage,
            action: action,
            children: []
        )
    }
    
    static func branch(
        _ title: String,
        desc: String? = nil,
        systemImage: String? = nil,
        children: [SettingsNode]
    ) -> SettingsNode {
        SettingsNode(
            title: title,
            desc: desc,
            systemImage: systemImage,
            action: .push,
            children: children
        )
    }
}
