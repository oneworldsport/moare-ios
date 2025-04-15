//
//  SportSearchEngine_iOSApp.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture
import AWSCore
import AWSTranslate
import AWSS3
import SDWebImageSwiftUI
import SDWebImageSVGCoder

@main
struct SportSearchEngine_iOSApp: App {
    @StateObject private var storeManager = StoreManager()
    
    @State var isSplashFinished = false
    
    init() {
        Task {
            await AWSManager.shared.loadInitialData()
        }
        
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
 
    var body: some Scene {
        WindowGroup {
            if isSplashFinished {
                SearchView()
                    .environmentObject(storeManager)
                    .preferredColorScheme(.light) // force light mode
            } else {
                SplashView(isSplashFinished: $isSplashFinished)
                    .preferredColorScheme(.light) // force light mode
            }
        }
    }
}
