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
        var node = root
        
        for char in word {
            if node.children[char] == nil {
                node.children[char] = TrieNode()
            }
            node = node.children[char]!
            if let originalWord = originalWord {
                node.originalWords[originalWord] = weight
//                node.originalWords.insert(originalWord)
            }
        }
        
        node.isEndOfWord = true
        if originalWord == nil {
            node.originalWords[word] = weight
//            node.originalWords.insert(word)
        }
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
        var node = root
        
        for char in prefix {
            guard let childNode = node.children[char] else {
                return []
            }
            node = childNode
        }
        
        return collectWords(from: node, prefix: prefix)
    }
    
    // 모든 단어 수집
    private func collectWords(from node: TrieNode, prefix: String) -> [String] {
//        var result = Set<String>()
        
//        if node.isEndOfWord {
//            result.formUnion(node.originalWords)
//        }
        
//        for (char, childNode) in node.children {
//            let newPrefix = prefix + String(char)
//            result.formUnion(collectWords(from: childNode, prefix: newPrefix))
//        }
        
//        return Array(Array(result).prefix(10))
        
        
        //-----
//        var results: [(word: String, weight: Int)] = []
//        
//        if node.isEndOfWord {
//            results.append(contentsOf: node.originalWords.map { ($0.key, $0.value) })
//        }
//        
//        for (char, childNode) in node.children {
//            let newPrefix = prefix + String(char)
//            results.append(contentsOf: collectWords(from: childNode, prefix: newPrefix).map { (word: $0, weight: node.originalWords[$0] ?? 0) })
//        }
//        
//        // Sort by weight in descending order and limit to 10 results
//        print(results .sorted {
//            if $0.weight == $1.weight {
//                return $0.word < $1.word // 동일 가중치일 경우 사전순으로 정렬
//            }
//            return $0.weight > $1.weight // 기본적으로 가중치로 정렬
//        }.map { $0.word }
//        )
//        return Array(results
//            .sorted { $0.weight > $1.weight }
////            .sorted {
////                if $0.weight == $1.weight {
////                    return $0.word < $1.word // 동일 가중치일 경우 사전순으로 정렬
////                }
////                return $0.weight > $1.weight // 기본적으로 가중치로 정렬
////            }
//            .map { $0.word }
//            .prefix(10))
        
        
        //-----
        var result = [String: Int]()
        
        if node.isEndOfWord {
            for (word, weight) in node.originalWords {
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
}
