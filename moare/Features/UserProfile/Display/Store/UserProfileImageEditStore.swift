//
//  UserProfileImageEditStore.swift
//  moare
//
//  Created by Mohwa Yoon on 11/15/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct UserProfileImageEditStore {
    @ObservableState
    struct State {
        let userId: String
        
        var profileImage: UIImage? = nil
        
        init(userId: String) {
            self.userId = userId
        }
    }
    
    enum Action {
        case onComplete(UIImage)
        case goBack
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case pop(key: String? = nil, fileURL: URL? = nil)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onComplete(let image):
                let userId = state.userId
                return .run { send in
                    guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                        // 에러 처리
                        return
                    }
                    
                    do {
                        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
                        let fileURL = tempDir.appendingPathComponent("upload-\(UUID().uuidString).jpg")
                        try imageData.write(to: fileURL)
                        
                        let key = "temp/\(userId)/\(UUID().uuidString).jpg"
                        let result = await withCheckedContinuation { continuation in
                            AWSManager.shared.uploadImage(fileURL: fileURL, key: key) { result in
                                continuation.resume(returning: result)
                            }
                        }
                        
                        switch result {
                        case .success(let key):
                            print("Uploaded avatar URL: \(key)")
                            await send(.delegate(.pop(key: key, fileURL: fileURL)))
                            
                        case .failure(let error):
                            print("Upload error: \(error)")
                            try FileManager.default.removeItem(at: fileURL)
                            await send(.delegate(.pop()))
                        }
                    } catch {
                        print("Temp file error: \(error)")
                    }
                }
                
            case .goBack:
                return .send(.delegate(.pop()))
                
            case .delegate:
                return .none
            }
        }
    }
}
