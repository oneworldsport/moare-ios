//
//  FootballTeamStandingsResponseModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct FBTeamStandingsResponseModel: Decodable, Equatable {
    let standings: FBTeamStandingsSource
}

// UEFA리그의 경우 team data의 statistics로 순위를 표현할수가 없어서, 백엔드에서 football api를 통해 받아온 데이터를 response해준다.
enum FBTeamStandingsSource: Decodable, Equatable {
    case db([FBTeam])
    case external([FBTeamForStandings])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dbTeams = try? container.decode([FBTeam].self) {
            self = .db(dbTeams)
        } else if let externalTeams = try? container.decode([FBTeamForStandings].self) {
            self = .external(externalTeams)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown standings format")
        }
    }
}

extension FBTeamStandingsSource {
    var isEmpty: Bool {
        switch self {
        case .db(let teams):
            return teams.isEmpty
        case .external(let teams):
            return teams.isEmpty
        }
    }
}
