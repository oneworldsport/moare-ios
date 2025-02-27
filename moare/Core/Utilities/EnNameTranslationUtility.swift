//
//  EnNameTranslationUtilities.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/4/25.
//

import Foundation
import AWSTranslate

enum TranslationType {
    case country, player, team
}

struct EnNameTranslationUtility {
    static let countryTranslationDic: [String: String] = [
        "Korea Republic": "대한민국",
        "England": "영국"
    ]
    
    // NOTE: if the structure changes to translating teamName in the app, this dictionary should change to english-korean dictionary.
    // now is temporary dictionary.
    static let teamNameTranslationDic: [String: String] = [
        "늑대": "울버햄튼",
    ]

    static func translateByDic(type: TranslationType, input: String) -> String {
        let map: [String: String]
        
        switch type {
        case .country:
            map = countryTranslationDic
        case .player:
            map = countryTranslationDic // 추후 playerTranslationDic을 추가로 정의 가능
        case .team:
            map = teamNameTranslationDic
        }
        
        var result = input
        
        for (english, korean) in map {
            if result.range(of: english, options: .caseInsensitive) != nil {
                result = result.replacingOccurrences(of: english, with: korean, options: .caseInsensitive)
                break
            }
        }
        
        return result
    }
    
    static func translateByAWS(input: String?) async -> String {
        do {
            guard let input = input, !input.isEmpty else {
                return input ?? ""
            }
            
            let translateClient = AWSTranslate(forKey: "TranslateClient")
            let request = AWSTranslateTranslateTextRequest()!
            request.text = input
            request.sourceLanguageCode = "en"
            request.targetLanguageCode = "ko"
            
            return try await withCheckedThrowingContinuation { continuation in
                translateClient.translateText(request) { response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let translatedText = response?.translatedText {
                        continuation.resume(returning: translatedText)
                    } else {
                        continuation.resume(throwing: NSError(domain: "TranslateError", code: -1))
                    }
                }
            }
        } catch {
            return input ?? ""
        }
    }
}
