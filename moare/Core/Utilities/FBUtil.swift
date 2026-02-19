//
//  FBUtil.swift
//  moare
//
//  Created by Mohwa Yoon on 6/20/25.
//

struct FBUtil {
    static func teamLogoURL(id: Int?) -> String? {
        if let id {
            return "https://media.api-sports.io/football/teams/\(id).png"
        } else {
            return nil
        }
    }
    
}

struct Util {
    static func teamLogoURL(leagueId: Int, teamId: Int?) -> String? {
        if let teamId {
            switch leagueId {
            case let id where Constants.Ids.footballLeagues.contains(id) || Constants.Ids.footballTournamentLeagues.contains(id):
                return "https://media.api-sports.io/football/teams/\(teamId).png"
            case Constants.Ids.nba:
                return "https://cdn.nba.com/logos/nba/\(teamId)/primary/L/logo.svg"
            case Constants.Ids.mlb:
                return "https://www.mlbstatic.com/team-logos/\(teamId).svg"
            case Constants.Ids.kbo:
                if let code = KBOUtil.codeMap[teamId] {
                    return "https://6ptotvmi5753.edge.naverncp.com/KBO_IMAGE/emblem/regular/fixed/emblem_\(code).png"
                } else {
                    return nil
                }
            case let id where Constants.Ids.tennisAll.contains(id):
                return "https://player-team-images.s3.ap-northeast-2.amazonaws.com/tennis/player/\(teamId).png"
            default :
                return nil
            }
        } else {
            return nil
        }
    }
    
    /// 두 팀 ID 페어 목록과 게임 목록에서 라운드 매치들을 뽑고,
    /// 매치된 게임은 원본 `games`에서 제거합니다.
    /// - Parameters:
    ///   - pairs: [[Int?]]  // 각 페어는 최대 2개. nil 이면 부분 매치 허용 시 한쪽만 매칭.
    ///   - games: inout [GameForSchedule<T>]  // 매치된 게임 제거를 위해 inout
    ///   - allowPartial: true면 pair 내에 nil 있을 때 한 팀만 일치해도 매칭
    /// - Returns: [[GameForSchedule<T>]]  // 페어별 매칭된 게임 리스트
    /// - by gpt
    static func collectRound<T: Decodable & Equatable>(
        from pairs: [[Int?]],
        games: inout [GameForSchedule<T>],
        allowPartial: Bool = true
    ) -> (seedIdTuple: [(Int?, Int?)], rounds: [[GameForSchedule<T>]?]) {

        func matches(_ g: GameForSchedule<T>, _ pair: [Int?]) -> Bool {
            let a = pair.count > 0 ? pair[0] : nil
            let b = pair.count > 1 ? pair[1] : nil

            switch (a, b, allowPartial) {
            case let (.some(x), .some(y), _):
                // 두 팀 다 확정: 순서 무시하고 같은 두 팀이면 매치
                return (g.homeTeamId == x && g.awayTeamId == y) || (g.homeTeamId == y && g.awayTeamId == x)

            case let (.some(x), .none, true),
                 let (.none, .some(x), true):
                // 부분 매치 허용: 한 팀만 맞아도 매치
                return g.homeTeamId == x || g.awayTeamId == x

            default:
                return false
            }
        }

        var seedIdTuple: [(Int?, Int?)] = []
        var result = [[GameForSchedule<T>]]()
        result.reserveCapacity(pairs.count)

        for pair in pairs {
            // seed 튜플 기록 (pair 길이에 상관없이 안전하게)
            let a = pair.count > 0 ? pair[0] : nil
            let b = pair.count > 1 ? pair[1] : nil
            seedIdTuple.append((a, b))
            
            // 페어 매칭
            let filtered = games.filter { matches($0, pair) }
            result.append(filtered)
            
            // 매칭된 게임은 원본에서 제거. 제거 않하면 다음라운드에서 pair에 nil이 있는 경우(부분 매치 허용) 중복으로 game이 filter됨.
            let toRemove = Set(filtered.map(\.gameId))
            games.removeAll { toRemove.contains($0.gameId) }
        }

        return (seedIdTuple, result)
    }
}
