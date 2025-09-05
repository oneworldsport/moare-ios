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

@main
struct SportSearchEngine_iOSApp: App {
    @StateObject private var storeManager = StoreManager()
    
    @State var isSplashFinished = false
    
    @State var viewForTest: SportDisplayType? = nil
    
    enum Screen {
        case search, moat, profile
    }
    
    @State private var selection: Screen = .moat
    
    init() {
        Task {
            await AWSManager.shared.loadInitialData()
        }
        
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
    
    var body: some Scene {
        WindowGroup {
            if isSplashFinished {
                if viewForTest != nil {
                    SearchView(viewForTest: viewForTest)
                        .environmentObject(storeManager)
                        .preferredColorScheme(.light) // force light mode
                } else {
                    TabView(selection: $selection) {
                        SearchView()
                            .environmentObject(storeManager)
                            .tabItem {
                                Image(systemName: "magnifyingglass")
                                if selection == .search {
                                    Text("검색")
                                } else {
                                    Text("")
                                }
                            }
                            .tag(Screen.search)
                        
                        MoatTimelineView()
                            .environmentObject(storeManager)
                            .tabItem {
                                Image(systemName: "bubble.left")
                                if selection == .moat {
                                    Text("모트")
                                } else {
                                    Text("")
                                }
                            }
                            .tag(Screen.moat)
                        
                        SearchView()
                            .environmentObject(storeManager)
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
                }
            } else {
                SplashView(isSplashFinished: $isSplashFinished)
                    .preferredColorScheme(.light) // force light mode
            }
        }
    }
}
