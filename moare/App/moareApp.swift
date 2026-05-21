//
//  SportSearchEngine_iOSApp.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI
import SDWebImageSVGCoder
import FirebaseCore
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        return true
    }
}

@main
struct SportSearchEngine_iOSApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let appStore = Store(initialState: AppStore.State()) { AppStore() }
    
    @State var isSplashFinished = false
    @State private var didInitialLoad = false
    
    init() {
//        Task {
//            await AWSManager.shared.loadInitialData()
//        }
        
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        
//        Analytics.logEvent("test_event", parameters: [
//            "source": "iOS_debug"
//        ])
    }
 
    var body: some Scene {
        WindowGroup {
            Group {
                if isSplashFinished && didInitialLoad {
                    SearchView(
                        appStore: appStore,
                        searchStore: appStore.scope(state: \.search, action: \.search)
                    )
                    .preferredColorScheme(.light) // force light mode
                } else {
                    SplashView(isSplashFinished: $isSplashFinished)
                        .preferredColorScheme(.light) // force light mode
                }
            }
            .task {
                didInitialLoad = true
                Task { await AWSManager.shared.loadInitialData() }
            }
        }
    }
}
