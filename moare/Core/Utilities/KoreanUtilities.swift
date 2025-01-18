//
//  KoreanUtilities.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/4/25.
//

import Foundation

let CHO: [Character] = [
    "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
]

func getChosung(from text: String) -> String {
    var result = ""
    
    for char in text {
        if let scalar = char.unicodeScalars.first, scalar.value >= 0xAC00, scalar.value <= 0xD7A3 {
            let unicode = scalar.value - 0xAC00
            let cho = Int(unicode) / (21 * 28)
            result.append(CHO[cho])
        } else {
            result.append(char) // 한글이 아니면 그대로 추가
        }
    }
    
    return result
}
