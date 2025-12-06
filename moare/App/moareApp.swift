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
    
    let searchStackStore = Store(initialState: SearchStackStore.State()) { SearchStackStore() }
    let moatStackStore = Store(initialState: MoatStackStore.State()) { MoatStackStore() }
    let userProfileStackStore = Store(initialState: UserProfileStackStore.State()) { UserProfileStackStore() }
    
    @State var isSplashFinished = false
    @State private var didInitialLoad = false
    
//    var viewForTest: SportDisplayType? = SportDisplayType.nbaTournament
    var viewForTest: SportDisplayType? = nil
    
    enum Screen {
        case search, moat, profile
    }
    
    @State private var selection: Screen = .moat
    
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
                        searchStackStore: searchStackStore,
                        searchStore: searchStackStore.scope(state: \.search, action: \.search),
                        viewForTest: viewForTest
                    )
                    .preferredColorScheme(.light) // force light mode
                } else {
                    if isSplashFinished && didInitialLoad {
                        TabView(selection: $selection) {
                            SearchView(
                                searchStackStore: searchStackStore,
                                searchStore: searchStackStore.scope(state: \.search, action: \.search)
                            )
                            .preferredColorScheme(.light) // force light mode
                            .tabItem {
                                Image(systemName: "magnifyingglass")
                                if selection == .search {
                                    Text("검색")
                                } else {
                                    Text("")
                                }
                            }
                            .tag(Screen.search)
                            
                            MoatDisplayView(
                                stackStore: moatStackStore
                            )
                            .tabItem {
                                Image(systemName: "bubble.left")
                                if selection == .moat {
                                    Text("모트")
                                } else {
                                    Text("")
                                }
                            }
                            .tag(Screen.moat)
                            
                            UserProfileDisplayView(
                                stackStore: userProfileStackStore
                            )
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                if selection == .profile {
                                    Text("내 프로필")
                                } else {
                                    Text("")
                                }
                            }
                            .tag(Screen.profile)
                        }
                        .preferredColorScheme(.light) // force light mode
                        .tint(Color("moare"))
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
