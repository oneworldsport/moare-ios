//
//  StringConstants.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/14/25.
//

import Foundation

struct StringConstants {
    static let resultOpen = "결과 보기"
    static let resultHide = "결과 숨기기"
    static let gameNotStartedStr = "경기 전"
    static let gameFinishedStr = "경기 종료"
    static let gamePostponedStr = "경기 연기"
    static let gameLiveStr = "경기중"
    static let gameCanceledStr = "경기 취소"
    
    static let standingsFirstCategory = "순위"
    static let statsFirstCategories = ["공격 지표", "수비 지표", "공통 지표"]
    
    static let gameStatsFirstCategory = "선수 이름"
    
    static let leagueStandings = "리그 순위"
    
    struct Football {
        static let gameFirstHalfStr = "전반전"
        static let gameHalftimeStr = "전반 종료"
        static let gameSecondHalfStr = "후반전"
        
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
        
        static let teamStandingsCategories = ["승점", "승", "무", "패", "경기수", "득점", "실점", "득실차", "홈성적", "원정성적"]
        
        static let playerStandingsAttackCategories = ["득점", "도움", "공격포인트", "슈팅", "유효슈팅", "키패스", "드리블 성공", "pk골"]
        static let playerStandingsDefendCategories = ["태클 시도", "볼 경합 성공"]
        static let playerStandingsCommonCategories = ["패스 시도", "파울", "경고", "퇴장", "경기수", "선발출전", "교체출전", "출전시간(분)", "평균평점"]
        static let playerStandingsSecondCategories = playerStandingsAttackCategories + playerStandingsDefendCategories + playerStandingsCommonCategories
        
        // 보류: 세이브, 실점, 패널티 실패, 패널티 세이브
        static let gameStatsAttackCategories = ["득점", "pk골", "도움", "슈팅", "유효슈팅", "키패스", "드리블 성공/시도(%)", "오프사이드"]
        static let gameStatsDefendCategories = ["태클 시도", "볼 경합 성공/시도(%)", "가로채기"]
        static let gameStatsCommonCategories = ["패스 시도", "얻은 파울", "파울", "경고", "퇴장", "출전시간(분)", "평점"]
        static let gameStatsSecondCategories = gameStatsAttackCategories + gameStatsDefendCategories + gameStatsCommonCategories
        
        static func leagueNameStr(leagueId: Int) -> String {
            switch leagueId {
            case Constants.Ids.epl:
                return "EPL"
            case Constants.Ids.laliga:
                return "라리가"
            case Constants.Ids.bundesliga:
                return "분데스리가"
            case Constants.Ids.seriea:
                return "세리에A"
            case Constants.Ids.ligue1:
                return "리그1"
            default :
                return ""
            }
        }
    }
    
    struct NBA {
        static let gameScheduled = 1
        static let gameLive = 2
        static let gameFinal = 3
        
        static let gameQtr1 = "1쿼터"
        static let gameQtr2 = "2쿼터"
        static let gameQtr3 = "3쿼터"
        static let gameQtr4 = "4쿼터"
        static let gameOt1 = "연장 1쿼터"
        static let gameOt2 = "연장 2쿼터"
        static let gameOt3 = "연장 3쿼터"
        
        static let conferenceCategory = ["서부", "동부"]
        
        // TODO: 나중에 데이터 추가되면 카테고리 추가
        //        static let teamStandingsCategories = ["게임차", "승률", "승", "패", "경기수", "홈성적", "원정성적", "경기당 득점", "경기당 득실마진", "경기당 도움", "경기당 리바운드", "야투 성공률", "3점 성공률", "자유투 성공률", "경기당 블록", "경기당 스틸", "경기당 턴오버", "경기당 파울")
        static let teamStandingsCategories = ["게임차", "승률", "승", "패", "경기수", "경기당 득점", "경기당 득실마진", "경기당 도움", "경기당 리바운드", "야투 성공률", "3점 성공률", "자유투 성공률", "경기당 블록", "경기당 스틸", "경기당 턴오버", "경기당 파울"]
        
        static let playerStandingsAttackCategories = ["경기당 득점", "경기당 도움", "경기당 공격 리바운드", "경기당 야투 시도", "경기당 야투 성공", "야투 성공률", "경기당 3점 시도", "경기당 3점 성공", "3점 성공률", "경기당 자유투 시도", "경기당 자유투 성공", "자유투 성공률"]
        static let playerStandingsDefendCategories = ["경기당 수비 리바운드", "경기당 블록", "경기당 스틸"]
        static let playerStandingsCommonCategories = ["경기당 리바운드", "경기당 턴오버", "경기당 파울", "경기당 파울 유도", "경기당 피블록", "경기당 득실마진", "경기수", "경기당 출전시간", "출전 경기 승", "출전 경기 패", "출전 경기 승률", "트리플더블", "더블더블"]
        static let playerStandingsSecondCategories = playerStandingsAttackCategories + playerStandingsDefendCategories + playerStandingsCommonCategories
        
        static let gameStatsAttackCategories = ["득점", "도움", "공격 리바운드", "야투 시도", "야투 성공", "야투 성공률", "3점 시도", "3점 성공", "3점 성공률", "자유투 시도", "자유투 성공", "자유투 성공률"]
        static let gameStatsDefendCategories = ["수비 리바운드", "블록", "스틸"]
        static let gameStatsCommonCategories = ["리바운드", "턴오버", "파울", "득실마진", "출전시간"]
        static let gameStatsSecondCategories = gameStatsAttackCategories + gameStatsDefendCategories + gameStatsCommonCategories
        static let gameStatsCategories = ["출전시간", "득점", "도움", "리바운드", "", "야투\n성공/시도(성공률)", "3점\n성공/시도(성공률)", "자유투\n성공/시도(성공률)", "", "스틸", "블록", "", "턴오버", "파울", "", "공격/수비\n리바운드", "득실마진"]
    }
    
    struct KBO {
        static let gameScheduled = 1
        static let gameLive = 2
        static let gameFinal = 3
        static let gameCanceled = 4
        
        static let teamStandingsCategories = ["게임차", "승률", "승", "패", "경기수", "연속", "타율", "안타", "홈런", "장타율", "득점", "평균자책", "피안타율", "피안타", "피홈런", "실점", "도루성공률"]
        
        static let playerStandingsHittingCategories = [""]
        static let playerStandingsPitchingCategories = [""]
        static let playerStandingsRunningCategories = [""]
        static let playerStandingsSecondCategories = playerStandingsHittingCategories + playerStandingsPitchingCategories + playerStandingsRunningCategories

        static let gameStatsHittingCategories = ["타수", "안타", "홈런", "타점", "득점", "볼넷", "삼진", "병살타"]
        static let gameStatsPitchingCategories = ["이닝", "실점", "자책", "볼넷", "삼진", "피안타"]
        static let gameStatsRunningCategories = [""]
        static let gameStatsSecondCategories = gameStatsHittingCategories + gameStatsPitchingCategories + gameStatsRunningCategories
    }
    
    struct MLB {
        static let gameScheduled = "Scheduled"
        static let gameLive = "In Progress"
        static let gamePostponed = "Postponed"
        static let gameRain = "Completed Early: Rain"
        static let gameFinal = "Final"
        static let gameFinishedList = [gameRain, gameFinal]
        
        static let conferenceCategory = ["내셔널리그", "아메리칸리그"]
        
        static let teamStandingsCategories = ["게임차", "승률", "승", "패", "경기수", "연속", "타율", "안타", "홈런", "장타율", "득점", "평균자책", "피안타율", "피안타", "피홈런", "실점", "도루성공률"]
        
        static let playerStandingsHittingCategories = [""]
        static let playerStandingsPitchingCategories = [""]
        static let playerStandingsRunningCategories = [""]
        static let playerStandingsSecondCategories = playerStandingsHittingCategories + playerStandingsPitchingCategories + playerStandingsRunningCategories

        static let gameStatsHittingCategories = ["타수", "안타", "홈런", "타점", "득점", "도루", "볼넷", "삼진"]
        static let gameStatsPitchingCategories = ["이닝", "실점", "자책", "볼넷", "삼진", "피안타"]
        static let gameStatsRunningCategories = [""]
        static let gameStatsSecondCategories = gameStatsHittingCategories + gameStatsPitchingCategories + gameStatsRunningCategories
    }
    
    static func viewPreparingAdviseText(type: String) -> String {
        return "\(type) 화면은 더 나은 서비스 제공을 위해 현재 개선 작업 중입니다. 이용에 불편을 드려 죄송합니다."
    }
    
    static func tournamentButtonText(leagueId: Int) -> String {
        switch leagueId {
        case Constants.Ids.mls:
            return "플레이오프 대진표"
        case Constants.Ids.nba:
            return "플레이오프 대진표"
        case Constants.Ids.mlb:
            return "포스트시즌 대진표"
        case Constants.Ids.kbo:
            return "가을야구 대진표"
        default :
            return ""
        }
    }
}
