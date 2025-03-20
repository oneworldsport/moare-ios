//
//  StringConstants.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/14/25.
//

import Foundation

struct StringConstants {
    struct Football {
        static let resultOpen = "결과 보기"
        static let resultHide = "결과 숨기기"
        static let gameNotStartedStr = "경기 전"
        static let gameFirstHalfStr = "전반전"
        static let gameHalftimeStr = "전반 종료"
        static let gameSecondHalfStr = "후반전"
        static let gameFinishedStr = "경기 종료"
        
        static let gameNotStarted = "NS"
        static let gameFirstHalf = "1H"
        static let gameHalftime = "HT"
        static let gameSecondHalf = "2H"
        static let gameExtraTime = "ET" // 연장전
        static let gameBreakTime = "BT" // 연장전 전반 후 휴식시간
        static let gamePenaltyShootout = "P" // 승부차기
        static let gameFinished = "FT"
        static let gameFinishedAfterExtraTime = "AET" // 승부차기 없이 연장전 후 경기 종료
        static let gameFinishedAfterPenaltyShootout = "PET" // 승부차기 후 경기 종료
        static let gamePostponed = "PST"
        static let gameCancelled = "CANC"
        static let gameLiveList = [gameFirstHalf, gameHalftime, gameSecondHalf, gameExtraTime, gameBreakTime, gamePenaltyShootout]
        static let gameFinishedList = [gameFinished, gameFinishedAfterExtraTime, gameFinishedAfterPenaltyShootout]
        
        static let standingsFirstCategory = "순위"
        static let statsFirstCategories = ["공격 지표", "수비 지표", "공통 지표"]
        static let playerStandingsSecondCategories = ["득점", "도움", "공격포인트", "슈팅", "유효슈팅", "키패스", "드리블 성공", "pk골", "태클 시도", "볼 경합 성공", "패스 시도", "파울", "경고", "퇴장", "경기수", "선발출전", "교체출전", "출전시간(분)", "평균평점"]
        static let playerStandingsAttackCategories = ["득점", "도움", "공격포인트", "슈팅", "유효슈팅", "키패스", "드리블 성공", "pk골"]
        static let playerStandingsDefendCategories = ["태클 시도", "볼 경합 성공"]
        static let playerStandingsEtcCategories = ["패스 시도", "파울", "경고", "퇴장", "경기수", "선발출전", "교체출전", "출전시간(분)", "평균평점"]
        
        static let gameStatsFirstCategory = "선수 이름"
        // 보류: 세이브, 실점, 패널티 실패, 패널티 세이브
        static let gameStatsSecondCategories = ["득점", "pk골", "도움", "슈팅", "유효슈팅", "키패스", "드리블 성공/시도(%)", "오프사이드", "태클 시도", "볼 경합 성공/시도(%)", "가로채기", "패스 시도", "얻은 파울", "파울", "경고", "퇴장", "출전시간(분)", "평점"]
        static let gameStatsAttackCategories = ["득점", "pk골", "도움", "슈팅", "유효슈팅", "키패스", "드리블 성공/시도(%)", "오프사이드"]
        static let gameStatsDefendCategories = ["태클 시도", "볼 경합 성공/시도(%)", "가로채기"]
        static let gameStatsEtcCategories = ["패스 시도", "얻은 파울", "파울", "경고", "퇴장", "출전시간(분)", "평점"]
    }
}
