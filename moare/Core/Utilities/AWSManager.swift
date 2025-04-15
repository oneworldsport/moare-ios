//
//  AWSManager.swift
//  moare
//
//  Created by Mohwa Yoon on 4/15/25.
//

import AWSCore
import AWSTranslate
import AWSS3
import ComposableArchitecture

class AWSManager {
    static let shared = AWSManager()
    
    private(set) var trendingKeywords: TrendingKeywords?
    
    private let trendingKeywordsPromise = AsyncPromise<TrendingKeywords>()
    
    private init() {
        configureAWS()
    }
    
    private func configureAWS() {
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .APNortheast2,
            identityPoolId: "ap-northeast-2:efa201e1-412b-438a-927f-411cc4838469"
        )
    
        let configuration = AWSServiceConfiguration(
            region: .APNortheast2,
            credentialsProvider: credentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Translate
        AWSTranslate.register(with: configuration!, forKey: "TranslateClient")
        
        // S3
        let transferUtilityConfiguration = AWSS3TransferUtilityConfiguration()
        transferUtilityConfiguration.bucket = "sport-search-engine"
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: transferUtilityConfiguration,
            forKey: "TransferUtilityClient"
        )
        
//        AWSDDLog.sharedInstance.logLevel = .verbose
//        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
    }
    
    func loadInitialData() async {
        async let trendingKeywords = loadTrendingKeywords()
        async let nameDictionary = loadNameDictionary()
        
        self.trendingKeywords = try? await trendingKeywords
        
        if let trendingKeywords = self.trendingKeywords {
//            try? await Task.sleep(for: .seconds(5))
            await trendingKeywordsPromise.fulfill(with: trendingKeywords)
        }
        
        if let nameDictionary = try? await nameDictionary {
            DependencyValues._current.translatedNameProvider.setDictionary(category: "nba_player", nameMap: nameDictionary)
        }
    }
    
    func loadTrendingKeywords() async throws -> TrendingKeywords {
        let bucket = "sport-search-engine"
        let s3Key = "trending_keywords/trending_keywords.json"
        let fileName = s3Key.components(separatedBy: "/").last ?? "trending_keywords.json"
        let fileURL = FileManager.default
               .urls(for: .documentDirectory, in: .userDomainMask)[0]
               .appendingPathComponent(fileName)
        
        let currentETag = UserDefaults.standard.string(forKey: "trendingKeywordsETag")
        
        let s3 = AWSS3.default()
        let request = AWSS3HeadObjectRequest()!
        request.bucket = bucket
        request.key = s3Key
        
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
        
        if newETag == currentETag, FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(TrendingKeywords.self, from: data)
        }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        let _: URL = try await withCheckedThrowingContinuation { continuation in
            let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "TransferUtilityClient")
            let downloadExpression = AWSS3TransferUtilityDownloadExpression()
            
            transferUtility!.download(to: fileURL, key: s3Key, expression: downloadExpression) { task, url, data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let fileURL = url {
                    continuation.resume(returning: fileURL)
                } else {
                    continuation.resume(throwing: NSError(domain: "DownloadError", code: 0))
                }
            }
        }
        
        UserDefaults.standard.setValue(newETag, forKey: "trendingKeywordsETag")
        
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(TrendingKeywords.self, from: data)
    }
    
    func loadNameDictionary() async throws -> [String: String] {
        let bucket = "sport-search-engine"
        let s3Key = "name_dictionary/nba_player_name_dictionary.json"
        let fileName = s3Key.components(separatedBy: "/").last ?? "nba_player_name_dictionary.json"
        let fileURL = FileManager.default
               .urls(for: .documentDirectory, in: .userDomainMask)[0]
               .appendingPathComponent(fileName)
        
        let currentETag = UserDefaults.standard.string(forKey: "nbaPlayerNameDictionaryETag")
        
        let s3 = AWSS3.default()
        let request = AWSS3HeadObjectRequest()!
        request.bucket = bucket
        request.key = s3Key
        
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
        
        if newETag == currentETag, FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([String: String].self, from: data)
        }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        let _: URL = try await withCheckedThrowingContinuation { continuation in
            let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "TransferUtilityClient")
            let downloadExpression = AWSS3TransferUtilityDownloadExpression()
            
            transferUtility!.download(to: fileURL, key: s3Key, expression: downloadExpression) { task, url, data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let fileURL = url {
                    continuation.resume(returning: fileURL)
                } else {
                    continuation.resume(throwing: NSError(domain: "DownloadError", code: 0))
                }
            }
        }
        
        UserDefaults.standard.setValue(newETag, forKey: "nbaPlayerNameDictionaryETag")
        
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([String: String].self, from: data)
    }
    
    func waitForTrendingKeywords() async throws -> TrendingKeywords {
        try await trendingKeywordsPromise.value
    }
}
