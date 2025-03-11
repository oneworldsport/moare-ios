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
    
    static let teamNameTranslationDic: [String: String] = [
        "Manchester United": "맨체스터 유나이티드",
        "Newcastle": "뉴캐슬 유나이티드",
        "Bournemouth": "AFC 본머스",
        "Fulham": "풀럼",
        "Wolves": "울버햄프턴 원더러스",
        "Liverpool": "리버풀",
        "Southampton": "사우샘프턴",
        "Arsenal": "아스널",
        "Everton": "에버턴",
        "Leicester": "레스터 시티",
        "Tottenham": "토트넘 홋스퍼",
        "West Ham": "웨스트햄 유나이티드",
        "Chelsea": "첼시",
        "Manchester City": "맨체스터 시티",
        "Brighton": "브라이턴 & 호브 앨비언",
        "Crystal Palace": "크리스털 팰리스",
        "Brentford": "브렌트퍼드",
        "Ipswich": "입스위치 타운",
        "Nottingham Forest": "노팅엄 포레스트",
        "Aston Villa": "애스턴 빌라"
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
