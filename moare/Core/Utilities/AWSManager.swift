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
    private(set) var noticeList: [NoticeModel]?
    private(set) var tournamentTeams: [String: [Int?]]?
    
    private let trendingKeywordsPromise = AsyncPromise<TrendingKeywords>()
    private let triePromise = AsyncPromise<(Trie, [KeywordInfo])>()
    private let noticeListPromise = AsyncPromise<[NoticeModel]>()
    private let tournamentTeamsPromise = AsyncPromise<[String: [Int?]]>()
    
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
        // process
        // 1. Trending Keywords
        // 2. AutoComplete
        // 3. Notice
        // 4. Dictionary
        async let trendingKeywords: TrendingKeywords = loadJsonFromS3(s3Key: "trending_keywords/trending_keywords.json", eTagKey: "trendingKeywordsETag")
        async let autoCompleteData: [KeywordInfo] = loadJsonFromS3(s3Key: "autocomplete/autocomplete.json", eTagKey: "autoCompleteETag")
        async let noticeList: [NoticeModel] = loadJsonFromS3(s3Key: "notice/main_notice.json", eTagKey: "mainNoticeETag")
        async let tournamentTeams: [String: [Int?]] = loadJsonFromS3(s3Key: "tournament/tournament_teams.json", eTagKey: "tournamentTeamsETag")
        
        async let eplPlayerNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/epl_player_name_dictionary.json", eTagKey: "eplPlayerNameDictionaryETag")
        async let footballTeamNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/football_team_name_dictionary.json", eTagKey: "footballTeamNameDictionaryETag")
        async let nbaPlayerNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/nba_player_name_dictionary.json", eTagKey: "nbaPlayerNameDictionaryETag")
        async let nbaTeamNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/nba_team_name_dictionary.json", eTagKey: "nbaTeamNameDictionaryETag")
        async let kboTeamNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/kbo_team_name_dictionary.json", eTagKey: "kboTeamNameDictionaryETag")
        async let mlbPlayerNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/mlb_player_name_dictionary.json", eTagKey: "mlbPlayerNameDictionaryETag")
        async let mlbTeamNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/mlb_team_name_dictionary.json", eTagKey: "mlbTeamNameDictionaryETag")
        async let laligaPlayerNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/laliga_player_name_dictionary.json", eTagKey: "laligaPlayerNameDictionaryETag")
        async let bundesligaPlayerNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/bundesliga_player_name_dictionary.json", eTagKey: "bundesligaPlayerNameDictionaryETag")
        async let ligue1PlayerNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/ligue1_player_name_dictionary.json", eTagKey: "ligue1PlayerNameDictionaryETag")
        async let serieaPlayerNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/seriea_player_name_dictionary.json", eTagKey: "serieaPlayerNameDictionaryETag")
        async let mlsPlayerNameDictionary: [String: String] = loadJsonFromS3(s3Key: "name_dictionary/mls_player_name_dictionary.json", eTagKey: "mlsPlayerNameDictionaryETag")
                
        do {
            let trendingKeywords = try await trendingKeywords
            self.trendingKeywords = trendingKeywords
//            try? await Task.sleep(for: .seconds(5))
            await trendingKeywordsPromise.fulfill(with: trendingKeywords)
        } catch {
            await trendingKeywordsPromise.fulfill(with: TrendingKeywords(date: "", keywords: []))
        }
        
        do {
            let autoCompleteData = try await autoCompleteData
            
            let trie = Trie() // Singleton Instance
            autoCompleteData.forEach {
                let keyword = $0.keyword
                trie.insert(word: keyword)
                trie.insert(word: getChosung(from: keyword), originalWord: keyword, weight: $0.weight ?? 0)
            }
            
            await triePromise.fulfill(with: (trie, autoCompleteData))
        } catch {
            print("🚨 autoCompleteData fetch error: \(error)")
        }
        
        // test
//        let decoder = JSONDecoder()
//        if let url = Bundle.main.url(forResource: "main_notice_test", withExtension: "json"),
//           let data = try? Data(contentsOf: url) {
//            do {
//                let noticeList = try decoder.decode([NoticeModel].self, from: data)
//                await noticeListPromise.fulfill(with: noticeList)
//            } catch {
//                // 실패하더라도 await -> 빈 값이라도 넘겨주기
//                await noticeListPromise.fulfill(with: [])
//                print("noticeList load failed:", error)
//            }
//        } else {
//            await noticeListPromise.fulfill(with: [])
//            print("noticeList load failed")
//        }
                
        do {
            let value = try await noticeList
            self.noticeList = value
            await noticeListPromise.fulfill(with: value)
        } catch {
            // 실패하더라도 await -> 빈 값이라도 넘겨주기
            await noticeListPromise.fulfill(with: [])
            print("noticeList load failed:", error)
        }
        
        do {
            let value = try await tournamentTeams
            self.tournamentTeams = value
            await tournamentTeamsPromise.fulfill(with: value)
        } catch {
            self.tournamentTeams = [:]
            await tournamentTeamsPromise.fulfill(with: [:])
            
            print("tournamentTeams load failed:", error)
        }
        
        do {
            let eplPlayerNameDictionary = try await eplPlayerNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.eplPlayerDic, nameMap: eplPlayerNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.eplPlayerDic, nameMap: [:])
            print("eplPlayerNameDictionary load failed:", error)
        }
        
        do {
            let footballTeamNameDictionary = try await footballTeamNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.footballTeamDic, nameMap: footballTeamNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.footballTeamDic, nameMap: [:])
            print("footballTeamNameDictionary load failed:", error)
        }
        
        do {
            let nbaPlayerNameDictionary = try await nbaPlayerNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.nbaPlayerDic, nameMap: nbaPlayerNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.nbaPlayerDic, nameMap: [:])
            print("nbaPlayerNameDictionary load failed:", error)
        }
        
        do {
            let nbaTeamNameDictionary = try await nbaTeamNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.nbaTeamDic, nameMap: nbaTeamNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.nbaTeamDic, nameMap: [:])
            print("nbaTeamNameDictionary load failed:", error)
        }
        
        do {
            let kboTeamNameDictionary = try await kboTeamNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.kboTeamDic, nameMap: kboTeamNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.kboTeamDic, nameMap: [:])
            print("kboTeamNameDictionary load failed:", error)
        }
        
        do {
            let mlbPlayerNameDictionary = try await mlbPlayerNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.mlbPlayerDic, nameMap: mlbPlayerNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.mlbPlayerDic, nameMap: [:])
            print("mlbPlayerNameDictionary load failed:", error)
        }
        
        do {
            let mlbTeamNameDictionary = try await mlbTeamNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.mlbTeamDic, nameMap: mlbTeamNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.mlbTeamDic, nameMap: [:])
            print("mlbTeamNameDictionary load failed:", error)
        }
        
        do {
            let laligaPlayerNameDictionary = try await laligaPlayerNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.laligaPlayerDic, nameMap: laligaPlayerNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.laligaPlayerDic, nameMap: [:])
            print("laligaPlayerNameDictionary load failed:", error)
        }
        
        do {
            let bundesligaPlayerNameDictionary = try await bundesligaPlayerNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.bundesligaPlayerDic, nameMap: bundesligaPlayerNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.bundesligaPlayerDic, nameMap: [:])
            print("bundesligaPlayerNameDictionary load failed:", error)
        }
        
        do {
            let ligue1PlayerNameDictionary = try await ligue1PlayerNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.ligue1PlayerDic, nameMap: ligue1PlayerNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.ligue1PlayerDic, nameMap: [:])
            print("ligue1PlayerNameDictionary load failed:", error)
        }
        
        do {
            let serieaPlayerNameDictionary = try await serieaPlayerNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.serieaPlayerDic, nameMap: serieaPlayerNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.serieaPlayerDic, nameMap: [:])
            print("serieaPlayerNameDictionary load failed:", error)
        }
        
        do {
            let mlsPlayerNameDictionary = try await mlsPlayerNameDictionary
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.mlsPlayerDic, nameMap: mlsPlayerNameDictionary)
        } catch {
            DependencyValues._current.translatedNameProvider.setDictionary(category: Constants.Keys.mlsPlayerDic, nameMap: [:])
            print("mlsPlayerNameDictionary load failed:", error)
        }
    }
    
    private func loadJsonFromS3<T: Decodable>(
        s3Key: String,
        eTagKey: String
    ) async throws -> T {
        let fileName = s3Key.components(separatedBy: "/").last ?? s3Key
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        let currentETag = UserDefaults.standard.string(forKey: eTagKey)
        
        let newETag = try await fetchETagFromS3(key: s3Key)

        if newETag == currentETag, FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        }

        try await downloadS3File(key: s3Key, fileURL: fileURL)
        
        UserDefaults.standard.setValue(newETag, forKey: eTagKey)

        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func fetchETagFromS3(key: String) async throws -> String? {
        let bucket = "sport-search-engine"
        
        let s3 = AWSS3.default()
        let headRequest = AWSS3HeadObjectRequest()!
        headRequest.bucket = bucket
        headRequest.key = key
        
        return try await withCheckedThrowingContinuation { continuation in
            s3.headObject(headRequest).continueWith { task in
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
    }
    
    private func downloadS3File(key: String, fileURL: URL) async throws {
        let bucket = "sport-search-engine"
        
        let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "TransferUtilityClient")
        let downloadExpression = AWSS3TransferUtilityDownloadExpression()
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        let _: URL = try await withCheckedThrowingContinuation { continuation in
            transferUtility!.download(to: fileURL, key: key, expression: downloadExpression) { task, url, data, error in
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
    }
    
    func waitForTrendingKeywords() async throws -> TrendingKeywords {
        try await trendingKeywordsPromise.value
    }
    
    func waitForTrieTuple() async throws -> (Trie, [KeywordInfo]) {
        try await triePromise.value
    }
    
    func waitForNoticeList() async throws -> [NoticeModel] {
        try await noticeListPromise.value
    }
    
    func waitForTournamentTeams() async throws -> [String: [Int?]] {
        try await tournamentTeamsPromise.value
    }
}
