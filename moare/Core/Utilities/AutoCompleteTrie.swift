//
//  AutoCompleteTrie.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/4/25.
//

import Foundation

class TrieNode {
    var isEndOfWord: Bool
    var children: [Character: TrieNode]
//    var originalWords: Set<String>
    var originalWords: [String: Int]
    
    init(isEndOfWord: Bool = false) {
        self.isEndOfWord = isEndOfWord
        self.children = [:]
//        self.originalWords = []
        self.originalWords = [:]
    }
}

class Trie {
    private let root = TrieNode()
    
    // 단어 추가
    func insert(word: String, originalWord: String? = nil, weight: Int = 0) {
//        let hasEnglish = containsEnglish(word)
        
        // 영어일 때만 lowercased
//        let normalizedWord = hasEnglish ? word.lowercased() : word
        let displayWord = originalWord ?? word
        
        var node = root
        
        for char in word.lowercased() {
            if node.children[char] == nil {
                node.children[char] = TrieNode()
            }
            node = node.children[char]!
//            if let originalWord {
//                node.originalWords[originalWord] = weight
////                node.originalWords.insert(originalWord)
//            }
        }
        
        node.isEndOfWord = true
        node.originalWords[displayWord] = weight
//        if originalWord == nil {
//            node.originalWords[normalizedWord] = weight
////            node.originalWords.insert(word)
//        }
        
        
//        var node = root
//    
//        for char in word {
//            if node.children[char] == nil {
//                node.children[char] = TrieNode()
//            }
//            node = node.children[char]!
//        }
//        
//        node.isEndOfWord = true
//        let targetWord = originalWord ?? word
//        node.originalWords[targetWord] = weight
    }
    
    // 검색
    func search(prefix: String) -> [String] {
//        var node = root
//        for char in prefix {
//            guard let childNode = node.children[char] else {
//                return []
//            }
//            node = childNode
//        }
//        
////        return collectWords(from: node, prefix: prefix)
//        
//        var exactMatches = [String: Int]() // 음절 매칭
//        var fuzzyMatches = [String: Int]() // 초성 매칭
//        
//        // inout 문법을 사용하는 이유 -> 단순히 return 값으로 처리하면, 매 호출마다 합쳐야 해서 비효율적
//        collectWordsSeparated(from: node, exactMatches: &exactMatches, fuzzyMatches: &fuzzyMatches, prefix: prefix)
//        
//        let sortedExact = exactMatches.sorted {
//            $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value
//        }
//        
//        let sortedFuzzy = fuzzyMatches.sorted {
//            $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value
//        }
//        
//        print("exactMatches: \(sortedExact)")
//        print("fuzzyMatches: \(sortedFuzzy)")
//        
//        return (sortedExact + sortedFuzzy).prefix(10).map { $0.key }
        
        func findNode(for prefix: String) -> TrieNode? {
            var node = root
            for char in prefix {
                guard let next = node.children[char] else {
                    return nil
                }
                node = next
            }
            return node
        }
        
        let exactNode = findNode(for: prefix.lowercased())
        
        var exactMatches = [String: Int]()
        var fuzzyMatches = [String: Int]()
        
        if let exactNode {
            collectWordsSeparated(from: exactNode, exactMatches: &exactMatches, fuzzyMatches: &fuzzyMatches, prefix: prefix.lowercased())
        }
        
        if isKorean(prefix) {
            let chosung = getChosung(from: prefix.lowercased())
            if let fuzzyNode = findNode(for: chosung) {
                collectWordsSeparated(from: fuzzyNode, exactMatches: &exactMatches, fuzzyMatches: &fuzzyMatches, prefix: chosung)
            }
        }
        
        let sortedExact = exactMatches.sorted {
            $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value
        }
        
        let sortedFuzzy = fuzzyMatches.sorted {
            $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value
        }
        
        let combinedResults: [(String, Int)] = !exactMatches.isEmpty ? sortedExact : sortedFuzzy

        // 중복 제거 + 상위 10개
        var seenWords = Set<String>()
        var finalResults: [String] = []

        for (word, _) in combinedResults {
            if seenWords.insert(word).inserted {
                finalResults.append(word)
                if finalResults.count >= 10 { break }
            }
        }
        
        return finalResults
//        return (sortedExact + sortedFuzzy).prefix(10).map { $0.key }
    }
    
//    private func collectWordsSeparated(from node: TrieNode,
//                                       exactMatches: inout [String: Int],
//                                       fuzzyMatches: inout [String: Int],
//                                       prefix: String) {
//        if node.isEndOfWord {
//            for (word, weight) in node.originalWords {
//                if word.hasPrefix("#chosung#") {
//                    let cleanWord = String(word.dropFirst("#chosung#".count))
//                    fuzzyMatches[cleanWord] = weight
//                } else if word.hasPrefix(prefix) {
//                    exactMatches[word] = weight
//                } else {
//                    fuzzyMatches[word] = weight
//                }
//            }
//        }
//
//        for (_, childNode) in node.children {
//            collectWordsSeparated(from: childNode,
//                                  exactMatches: &exactMatches,
//                                  fuzzyMatches: &fuzzyMatches,
//                                  prefix: prefix)
//        }
//    }
    
    private func collectWordsSeparated(
        from node: TrieNode,
        exactMatches: inout [String: Int],
        fuzzyMatches: inout [String: Int],
        prefix: String
    ) {
        if node.isEndOfWord {
            for (word, weight) in node.originalWords {
                if word.hasPrefix(prefix) {
                    exactMatches[word] = weight
                } else {
                    fuzzyMatches[word] = weight
                }
            }
        }

        for (_, childNode) in node.children {
            collectWordsSeparated(from: childNode, exactMatches: &exactMatches, fuzzyMatches: &fuzzyMatches, prefix: prefix)
        }
    }
    
    // 모든 단어 수집
    private func collectWords(from node: TrieNode, prefix: String) -> [String] {
        var result = [String: Int]()
        
        if node.isEndOfWord {
            for (word, weight) in node.originalWords {
                // TODO: result[word] == nil { 이 코드는 필요 없는 것 같은데..?
                if result[word] == nil {
                    result[word] = weight
                }
            }
        }
        
        for (char, childNode) in node.children {
            let newPrefix = prefix + String(char)
            let childWords = collectWords(from: childNode, prefix: newPrefix)
            for word in childWords {
                if let weight = childNode.originalWords[word] {
                    result[word] = weight
                }
            }
        }
        
        return result.sorted {
            if $0.value == $1.value {
                return $0.key < $1.key
            }
            return $0.value > $1.value
        }.prefix(10).map { $0.key }
    }
    
    func getWeight(for word: String) -> Int {
        var node = root
        
        for char in word {
            guard let childNode = node.children[char] else {
                return 0 // 단어가 없으면 기본 weight 반환
            }
            node = childNode
        }
        return node.originalWords[word] ?? 0
    }
    
    private func isKorean(_ string: String) -> Bool {
        for scalar in string.unicodeScalars {
            let value = scalar.value
            if (value >= 0xAC00 && value <= 0xD7A3) ||  // 완성형
                (value >= 0x3131 && value <= 0x318E) ||  // 호환 자모 (ㄱ ~ ㆎ)
                (value >= 0x1100 && value <= 0x11FF)     // 자모
            {
                return true
            }
        }
        return false
    }
    
    private func containsEnglish(_ string: String) -> Bool {
        for scalar in string.unicodeScalars {
            if (scalar.value >= 0x41 && scalar.value <= 0x5A) ||  // A-Z
                (scalar.value >= 0x61 && scalar.value <= 0x7A) {   // a-z
                return true
            }
        }
        return false
    }
}
