//
//  DataFetchingState.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/9/24.
//

import Foundation

enum ApiFetchState: Equatable {
    case idle, fetching, success
    case failure(String)
//    case failure(Error)
    
    static func == (lhs: ApiFetchState, rhs: ApiFetchState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
            (.fetching, .fetching),
            (.success, .success),
            (.failure, .failure):
            return true
//        case (.failure(let lhsError), .failure(let rhsError)):
//            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

//struct DataFetchingInfo {
//    var status: FetchingStatus = .idle
//    var startTime: Date? = nil
//    var endTime: Date? = nil
//    var aniDuration: CGFloat = 0
//    var shouldShowProgress = false
//    var showData = false
////    : Bool {
////        if let endTime = endTime, let starTime = startTime {
////            
////        }
////        
////        return false
////    }
//    
////    func checkFetching() {
////        if let startTime, let endTime {
////            DispatchQueue.main.asyncAfter(deadline: .now() + aniDuration) {
////                if status == .fetching {
////                    shouldShowProgress = true
////                }
////            }
////        }
////    }
//}
