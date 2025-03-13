//
//  ServiceProtocols.swift
//  FitCatsApp
//
//  Created by ilicdev on 10.3.25..
//

import Foundation
import HealthKit
import Combine

// MARK: - Health Service Protocol
protocol HealthServiceProtocol {
    func isHealthDataAvailable() -> Bool
    func requestAuthorization() async throws -> Bool
    func fetchStepsForLast7Days() async throws -> [Int]
    func observeStepCountUpdates() -> AnyPublisher<[Int], Error>
}

// MARK: - Authentication Service Protocol
protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> String
    func signUp(email: String, password: String) async throws -> String
    func signOut() throws
    var currentUserId: String? { get }
}

// MARK: - User Service Protocol
protocol UserServiceProtocol {
    func getUser(id: String) async throws -> User
    func updateUser(id: String, data: [String: Any]) async throws
    func createUser(user: User) async throws
    func sendFriendRequest(from: String, to: String) async throws
    func acceptFriendRequest(from: String, to: String) async throws
    func declineFriendRequest(from: String, to: String) async throws
}

// MARK: - League Service Protocol
protocol LeagueServiceProtocol {
    func createLeague(league: League) async throws
    func getLeague(id: String) async throws -> League
    func updateLeague(id: String, data: [String: Any]) async throws
    func getLeaguesForUser(userId: String) async throws -> [League]
    func joinLeague(userId: String, leagueId: String) async throws
    func leaveLeague(userId: String, leagueId: String) async throws
} 