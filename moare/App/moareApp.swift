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
    @State private var didInitialLoad = false
    
    var viewForTest: SportDisplayType? = SportDisplayType.fbPlayerInfo
    
    init() {
        Task {
            await AWSManager.shared.loadInitialData()
        }
        
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
 
    var body: some Scene {
        WindowGroup {
            Group {
                if viewForTest != nil && didInitialLoad {
                    SearchView(viewForTest: viewForTest)
                        .environmentObject(storeManager)
                        .preferredColorScheme(.light) // force light mode
                } else {
                    if isSplashFinished && didInitialLoad {
                        SearchView()
                            .environmentObject(storeManager)
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
