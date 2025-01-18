//
//  UIConstants.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/14/25.
//

import Foundation
import SwiftUI

struct UIConstants {
    struct Padding {
        static let defaultPadding: CGFloat = 8
        static let defaultHPadding: CGFloat = 8
        static let defalutVPadding: CGFloat = 4
    }
    
    struct Height {
        static let screenHeight: CGFloat = UIScreen.main.bounds.height
    }
    
    struct Width {
        static let screenWidth: CGFloat = UIScreen.main.bounds.width
    }
    
    // NOTE: if there are name that already exist, name as plural
    struct Sizes {
        
    }
    
    struct Colors {
        
    }
    
    struct StrokeWidth {
        static let defaultWidth: CGFloat = 2
        static let thin: CGFloat = 1
        static let medium: CGFloat  = 3
        static let thick: CGFloat = 5
    }
    
    struct CornerRadius {
        static let defaultRadius: CGFloat = 10
        static let small: CGFloat = 5
        static let medium: CGFloat = 20
        static let big: CGFloat = 30
    }
}
