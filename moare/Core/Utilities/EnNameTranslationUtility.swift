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
    
    static let shortTeamNameTranslationDic: [String: String] = [
        "Manchester United": "맨유", "Newcastle": "뉴캐슬", "Bournemouth": "본머스", "Fulham": "풀럼", "Wolves": "울버햄튼",
        "Liverpool": "리버풀", "Southampton": "새우샘프턴", "Arsenal": "아스널", "Everton": "에버턴", "Leicester": "레스터 시티",
        "Tottenham": "토트넘", "West Ham": "웨스트 햄", "Chelsea": "첼시", "Manchester City": "맨시티", "Brighton": "브라이턴",
        "Crystal Palace": "크리스털 팰리스", "Brentford": "브렌트퍼드", "Ipswich": "입스위치", "Nottingham Forest": "노팅엄 포레스트", "Aston Villa": "애스턴 빌라",

        "Barcelona": "바르셀로나", "Atletico Madrid": "아틀레티코", "Athletic Club": "빌바오", "Valencia": "발렌시아", "Villarreal": "비야레알",
        "Las Palmas": "라스팔마스", "Sevilla": "세비야", "Leganes": "레가네스", "Celta Vigo": "셀타 데 비고", "Espanyol": "에스파뇰",
        "Real Madrid": "레알 마드리드", "Alaves": "알라베스", "Real Betis": "레알 베티스", "Getafe": "헤타페", "Girona": "지로나",
        "Real Sociedad": "레알 소시에다드", "Valladolid": "레알 바야돌리드", "Osasuna": "오사수나", "Rayo Vallecano": "바예카노", "Mallorca": "마요르카",

        "Bayern München": "바이에른 뮌헨", "SC Freiburg": "SC 프라이부르크", "VfL Wolfsburg": "볼프스부르크", "Werder Bremen": "브레멘", "Borussia Mönchengladbach": "묀헨글라트바흐",
        "FSV Mainz 05": "마인츠 05", "Borussia Dortmund": "도르트문트", "1899 Hoffenheim": "호펜하임", "Bayer Leverkusen": "레버쿠젠", "Eintracht Frankfurt": "프랑크푸르트",
        "FC Augsburg": "아우크스부르크", "VfB Stuttgart": "슈투트가르트", "RB Leipzig": "라이프치히", "VfL Bochum": "보훔", "1. FC Heidenheim": "하이덴하임",
        "Union Berlin": "우니온 베를린", "FC St. Pauli": "FC 장 파울리", "Holstein Kiel": "홀슈타인 킬",

        "Angers": "앙제", "Lille": "LOSC 릴", "Lyon": "리옹", "Marseille": "마르세유", "Montpellier": "몽펠리에",
        "Nantes": "낭트", "Nice": "OGC 니스", "Paris Saint Germain": "PSG", "Monaco": "AS 모나코", "Reims": "랭스",
        "Rennes": "렌", "Strasbourg": "스트라스부르", "Toulouse": "툴루즈", "Stade Brestois 29": "브레스트", "Auxerre": "오세르",
        "Le Havre": "르아브르 AC", "Lens": "랭스", "Saint Etienne": "생테티엔"
    ]
    
    static let fullTeamNameTranslationDic: [String: String] = [
        "Manchester United": "맨체스터 유나이티드", "Newcastle": "뉴캐슬 유나이티드", "Bournemouth": "AFC 본머스", "Fulham": "풀럼", "Wolves": "울버햄프턴 원더러스",
        "Liverpool": "리버풀", "Southampton": "사우샘프턴", "Arsenal": "아스널", "Everton": "에버턴", "Leicester": "레스터 시티",
        "Tottenham": "토트넘 홋스퍼", "West Ham": "웨스트햄 유나이티드", "Chelsea": "첼시", "Manchester City": "맨체스터 시티", "Brighton": "브라이턴 & 호브 앨비언",
        "Crystal Palace": "크리스털 팰리스", "Brentford": "브렌트퍼드", "Ipswich": "입스위치 타운", "Nottingham Forest": "노팅엄 포레스트", "Aston Villa": "애스턴 빌라",

        "Barcelona": "FC 바르셀로나", "Atletico Madrid": "아틀레티코 마드리드", "Athletic Club": "아틀레틱 빌바오", "Valencia": "발렌시아 CF", "Villarreal": "비야레알 CF",
        "Las Palmas": "UD 라스팔마스", "Sevilla": "세비야 FC", "Leganes": "CD 레가네스", "Celta Vigo": "셀타 데 비고", "Espanyol": "RCD 에스파뇰",
        "Real Madrid": "레알 마드리드 CF", "Alaves": "데포르티보 알라베스", "Real Betis": "레알 베티스", "Getafe": "헤타페 CF", "Girona": "지로나 FC",
        "Real Sociedad": "레알 소시에다드", "Valladolid": "레알 바야돌리드 CF", "Osasuna": "CA 오사수나", "Rayo Vallecano": "라요 바예카노", "Mallorca": "RCD 마요르카",

        "Bayern München": "FC 바이에른 뮌헨", "SC Freiburg": "SC 프라이부르크", "VfL Wolfsburg": "VfL 볼프스부르크", "Werder Bremen": "SV 베르더 브레멘", "Borussia Mönchengladbach": "보루시아 묀헨글라트바흐",
        "FSV Mainz 05": "1. FSV 마인츠 05", "Borussia Dortmund": "보루시아 도르트문트", "1899 Hoffenheim": "TSG 1899 호펜하임", "Bayer Leverkusen": "바이어 04 레버쿠젠", "Eintracht Frankfurt": "아인트라흐트 프랑크푸르트",
        "FC Augsburg": "FC 아우크스부르크", "VfB Stuttgart": "VfB 슈투트가르트", "RB Leipzig": "RB 라이프치히", "VfL Bochum": "VfL 보훔", "1. FC Heidenheim": "1. FC 하이덴하임",
        "Union Berlin": "1. FC 우니온 베를린", "FC St. Pauli": "FC 장크트파울리", "Holstein Kiel": "홀슈타인 킬",

        "Angers": "앙제 SCO", "Lille": "LOSC 릴", "Lyon": "올랭피크 리옹", "Marseille": "올랭피크 드 마르세유", "Montpellier": "몽펠리에 HSC",
        "Nantes": "FC 낭트", "Nice": "OGC 니스", "Paris Saint Germain": "파리 생제르맹 FC", "Monaco": "AS 모나코 FC", "Reims": "스타드 드 랭스",
        "Rennes": "스타드 렌 FC", "Strasbourg": "RC 스트라스부르", "Toulouse": "툴루즈 FC", "Stade Brestois 29": "스타드 브레스투아 29", "Auxerre": "AJ 오세르",
        "Le Havre": "르아브르 AC", "Lens": "스타드 드 랭스", "Saint Etienne": "AS 생테티엔"
    ]

    static func translateByDic(type: TranslationType, isShort: Bool = true, input: String) -> String {
        let map: [String: String]
        
        switch type {
        case .country:
            map = countryTranslationDic
        case .player:
            map = countryTranslationDic // 추후 playerTranslationDic을 추가로 정의 가능
        case .team:
            map = isShort ? shortTeamNameTranslationDic : fullTeamNameTranslationDic
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
