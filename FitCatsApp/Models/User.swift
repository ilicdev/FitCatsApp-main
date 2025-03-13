//
//  User.swift
//  FitCatsApp
//
//  Created by ilicdev on 7.1.25..
//

import Foundation

struct User: Codable, Identifiable {
    var id: String
    var username: String?
    var email: String?
    var thisWeekSteps: Int?
    var lastWeekSteps: Int?
    var currentRank: Rank?
    var rankHistory: [String: Int] // skladisti rankove u recnik name: broj puta koliko je bio taj rank
    var friends: [String]? // Store User IDs of friends
    var friendRequests: [String]? // Store User IDs of friend requests
    var leagues: [String]? // Store League IDs
    var leagueInvites: [String]? // Store League Invite IDs
    var leagueSteps: [LeagueSteps]?
    var statistics: Statistics?
}

struct LeagueSteps: Codable {
    var league: String // Store League ID
    var steps: Int
}

struct League: Codable, Identifiable {
    var id: String?
    var name: String
    var startDate: Date
    var endDate: Date
    var participants: [String]
    var steps: [Int]
    var isActive: Bool
    var createdBy: String
    var createdByUser: User?
}
