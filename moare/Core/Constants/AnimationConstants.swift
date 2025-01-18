//
//  AnimationConstants.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/14/25.
//

import Foundation
import SwiftUI

struct AnimationConstants {
    struct Duration {
        static let defaultDuration: Double = 0.5
        static let short: Double = 0.3
        static let medium: Double = 0.7
        static let long: Double = 1.0
    }
    
    struct AnimationType {
        static let defaultAnimation = Animation.easeInOut(duration: Duration.defaultDuration)
        static let shortDefaultAnimation = Animation.easeInOut(duration: Duration.short)
        static let mediumDefaultAnimation = Animation.easeInOut(duration: Duration.medium)
        static let longDefaultAnimation = Animation.easeInOut(duration: Duration.long)
    }
}
