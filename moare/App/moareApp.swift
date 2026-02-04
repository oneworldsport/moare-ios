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
    
    var viewForTest: SportDisplayType? = SportDisplayType.tennisGameStats
//    var viewForTest: SportDisplayType? = nil
    
    init() {
        Task {
            await AWSManager.shared.loadInitialData()
        }
        
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        
//        Analytics.logEvent("test_event", parameters: [
//            "source": "iOS_debug"
//        ])
    }
 
    var body: some Scene {
        WindowGroup {
            Group {
                if viewForTest != nil && didInitialLoad {
                    SearchView(
                        appStore: appStore,
                        searchStore: appStore.scope(state: \.search, action: \.search),
                        viewForTest: viewForTest
                    )
                    .preferredColorScheme(.light) // force light mode
                } else {
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
            }
            .task {
                if viewForTest != nil {
                    // NOTE: test code를 실행할때는 s3가 모두 초기화(비동기 작업) 되기 전에 화면이 나와 사전이 비어있는 경우가 있음. 그래서 s3 초기화 작업이 모두 끝나면 다음 코드 진행.
                    await AWSManager.shared.loadInitialData()
                    didInitialLoad = true
                } else {
                    didInitialLoad = true
                    Task { await AWSManager.shared.loadInitialData() }
                }
            }
        }
    }
}
