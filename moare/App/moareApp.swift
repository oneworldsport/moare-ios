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
        
//        checkAutoCompleteJson()
        
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
    
    private func checkAutoCompleteJson() {
        let bucket = "sport-search-engine"
        let key = "autocomplete/autocomplete.json"
        
        let s3 = AWSS3.default()
        let request = AWSS3HeadObjectRequest()!
        request.bucket = bucket
        request.key = key
        
        Task {
            do {
                let newETag: String? = try await withCheckedThrowingContinuation { continuation in
                    s3.headObject(request).continueWith { task in
                        if let error = task.error {
                            continuation.resume(throwing: error)
                        } else if let result = task.result, let eTag = result.eTag {
                            continuation.resume(returning: eTag)
                        } else {
                            continuation.resume(returning: nil)
                        }
                        return nil
                    }
                }
                
                let currentETag = UserDefaults.standard.string(forKey: "autoCompleteETag")
                
                if newETag == currentETag {
                    return
                }
                
                let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "TransferUtilityClient")
                let downloadExpression = AWSS3TransferUtilityDownloadExpression()
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let downloadURL = documentsDirectory.appendingPathComponent("autocomplete.json")
                
                if FileManager.default.fileExists(atPath: downloadURL.path) {
                    try FileManager.default.removeItem(at: downloadURL)
                }
                
                let _: URL = try await withCheckedThrowingContinuation { continuation in
                    transferUtility!.download(to: downloadURL, key: key, expression: downloadExpression) { task, url, data, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let fileURL = url {
                            continuation.resume(returning: fileURL)
                        } else {
                            continuation.resume(throwing: NSError(domain: "DownloadError", code: 0))
                        }
                    }
                    // for checking error
//                    .continueWith { task in
//                        if let error = task.error {
//                            print("Download Task Error: \(error)")
//                        } else {
//                            print("Download Task Completed Successfully")
//                        }
//                        return nil
//                    }
                }
                
                UserDefaults.standard.setValue(newETag, forKey: "autoCompleteETag")
                
                // TODO: has to think about structure
                if let searchStore: StoreOf<SearchStore> = storeManager.getStore(forKey: StoreKeys.searchStore) {
                    searchStore.send(.initTrie)
                } else {
                    storeManager.setStore(Store(initialState: SearchStore.State()) { SearchStore() }, forKey: StoreKeys.searchStore)
                    let searchStore: StoreOf<SearchStore>? = storeManager.getStore(forKey: StoreKeys.searchStore)
                    
                    // init Trie
                    searchStore?.send(.initTrie)
                }
            } catch {
                print("\(error)")
            }
        }
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
