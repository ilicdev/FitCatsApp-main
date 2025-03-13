//
//  FriendsRequest.swift
//  FitCatsApp
//
//  Created by ilicdev on 25.1.25..
//

import Foundation
import FirebaseFirestore
import FirebaseAuth



class FriendsViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var currentUser: User?
    @Published var friendRequests: [User] = []
    @Published var friends: [User] = []
    @Published var searchText: String = ""
    @Published var selectedTab: TabSelection = .users

    private let db = Firestore.firestore()
    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        fetchCurrentUser()
        fetchUsers()
    }
    
    var filteredUsers: [User] {
            if searchText.isEmpty {
                return users
            } else {
                return users.filter {
                    guard let username = $0.username else { return false }
                    return username.lowercased().contains(searchText.lowercased())
                }
            }
        }
    
    var filteredFriends: [User] {
            if searchText.isEmpty {
                return friends
            } else {
                return friends.filter {
                    guard let username = $0.username else { return false }
                    return username.lowercased().contains(searchText.lowercased())
                }
            }
        }
    var filteredRequests: [User] {
            if searchText.isEmpty {
                return friendRequests
            } else {
                return friendRequests.filter {
                    guard let username = $0.username else { return false }
                    return username.lowercased().contains(searchText.lowercased())
                }
            }
        }
    
    func fetchCurrentUser() {
        guard let userID = currentUserID else { return }
        db.collection("users").document(userID).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }

            // Mapiranje currentRank kao Rank strukture
            let currentRankData = data["currentRank"] as? [String: Any] ?? [:]
            let currentRank = Rank(
                name: currentRankData["name"] as? String ?? "Cat",
                imageName: currentRankData["imageName"] as? String ?? "rank1",
                rank: currentRankData["rank"] as? Int ?? 0,
                threshold: currentRankData["threshold"] as? Int,
                color: currentRankData["color"] as? String ?? "",
                minSteps: currentRankData["minSteps"] as? Int,
                maxSteps: currentRankData["maxSteps"] as? Int
            )

            // Kreiraj korisnika sa mapiranim currentRank
            self.currentUser = User(
                id: userID,
                username: data["username"] as? String,
                email: data["email"] as? String,
                thisWeekSteps: data["thisWeekSteps"] as? Int,
                lastWeekSteps: data["lastWeekSteps"] as? Int,
                currentRank: currentRank,
                rankHistory: data["rankHistory"] as? [String: Int] ?? [:],
                friends: data["friends"] as? [String] ?? [],
                friendRequests: data["friendRequests"] as? [String] ?? [],
                leagues: data["leagues"] as? [String] ?? [],
                leagueInvites: data["leagueInvites"] as? [String] ?? [],
                leagueSteps: nil,
                statistics: nil
            )

            self.fetchFriends()
            self.fetchFriendRequests()
        }
    }



    func fetchUsers() {
        db.collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }

            self.users = documents.compactMap { doc -> User? in
                let data = doc.data()

                // Mapiranje currentRank kao Rank strukture
                let currentRankData = data["currentRank"] as? [String: Any] ?? [:]
                let currentRank = Rank(
                    name: currentRankData["name"] as? String ?? "Cat",
                    imageName: currentRankData["imageName"] as? String ?? "rank1",
                    rank: currentRankData["rank"] as? Int ?? 0,
                    threshold: currentRankData["threshold"] as? Int,
                    color: currentRankData["color"] as? String ?? "",
                    minSteps: currentRankData["minSteps"] as? Int,
                    maxSteps: currentRankData["maxSteps"] as? Int
                )

                return User(
                    id: doc.documentID,
                    username: data["username"] as? String,
                    email: data["email"] as? String,
                    thisWeekSteps: data["thisWeekSteps"] as? Int,
                    lastWeekSteps: data["lastWeekSteps"] as? Int,
                    currentRank: currentRank,
                    rankHistory: data["rankHistory"] as? [String: Int] ?? [:],
                    friends: data["friends"] as? [String] ?? [],
                    friendRequests: data["friendRequests"] as? [String] ?? [],
                    leagues: data["leagues"] as? [String] ?? [],
                    leagueInvites: data["leagueInvites"] as? [String] ?? [],
                    leagueSteps: nil,
                    statistics: nil
                )
            }.filter { $0.id != self.currentUserID }
        }
    }


    func fetchFriendRequests() {
        guard let requests = currentUser?.friendRequests, !requests.isEmpty else {
            self.friendRequests = [] // Postavi praznu listu ako su friendRequests prazni ili nil
            return
        }
        
        db.collection("users").whereField("id", in: requests).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                self.friendRequests = [] // U slučaju greške postavi praznu listu
                return
            }
            
            self.friendRequests = documents.compactMap { doc -> User? in
                let data = doc.data()
                
                // Mapiranje currentRank kao Rank strukture
                let currentRankData = data["currentRank"] as? [String: Any] ?? [:]
                let currentRank = Rank(
                    name: currentRankData["name"] as? String ?? "Cat",
                    imageName: currentRankData["imageName"] as? String ?? "rank1",
                    rank: currentRankData["rank"] as? Int ?? 0,
                    threshold: currentRankData["threshold"] as? Int,
                    color: currentRankData["color"] as? String ?? "",
                    minSteps: currentRankData["minSteps"] as? Int,
                    maxSteps: currentRankData["maxSteps"] as? Int
                )

                return User(
                    id: doc.documentID,
                    username: data["username"] as? String,
                    email: data["email"] as? String,
                    thisWeekSteps: data["thisWeekSteps"] as? Int,
                    lastWeekSteps: data["lastWeekSteps"] as? Int,
                    currentRank: currentRank,
                    rankHistory: data["rankHistory"] as? [String: Int] ?? [:],
                    friends: data["friends"] as? [String] ?? [],
                    friendRequests: data["friendRequests"] as? [String] ?? [],
                    leagues: data["leagues"] as? [String] ?? [],
                    leagueInvites: data["leagueInvites"] as? [String] ?? [],
                    leagueSteps: nil,
                    statistics: nil
                )
            }
        }
    }

    func fetchFriends() {
        guard let friendsIDs = currentUser?.friends, !friendsIDs.isEmpty else {
            self.friends = [] // Postavi praznu listu ako su friends prazni ili nil
            return
        }

        db.collection("users").whereField("id", in: friendsIDs).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                self.friends = [] // U slučaju greške postavi praznu listu
                return
            }
            
            self.friends = documents.compactMap { doc -> User? in
                let data = doc.data()

                // Mapiranje currentRank kao Rank strukture
                let currentRankData = data["currentRank"] as? [String: Any] ?? [:]
                let currentRank = Rank(
                    name: currentRankData["name"] as? String ?? "Cat",
                    imageName: currentRankData["imageName"] as? String ?? "rank1",
                    rank: currentRankData["rank"] as? Int ?? 0,
                    threshold: currentRankData["threshold"] as? Int,
                    color: currentRankData["color"] as? String ?? "",
                    minSteps: currentRankData["minSteps"] as? Int,
                    maxSteps: currentRankData["maxSteps"] as? Int
                )

                return User(
                    id: doc.documentID,
                    username: data["username"] as? String,
                    email: data["email"] as? String,
                    thisWeekSteps: data["thisWeekSteps"] as? Int,
                    lastWeekSteps: data["lastWeekSteps"] as? Int,
                    currentRank: currentRank,
                    rankHistory: data["rankHistory"] as? [String: Int] ?? [:],
                    friends: data["friends"] as? [String] ?? [],
                    friendRequests: data["friendRequests"] as? [String] ?? [],
                    leagues: data["leagues"] as? [String] ?? [],
                    leagueInvites: data["leagueInvites"] as? [String] ?? [],
                    leagueSteps: nil,
                    statistics: nil
                )
            }
        }
    }


    func sendFriendRequest(to user: User) {
        guard let currentUserID = currentUserID else { return }
        db.collection("users").document(user.id).updateData([
            "friendRequests": FieldValue.arrayUnion([currentUserID])
        ])
    }

    func acceptFriendRequest(from user: User) {
        guard let currentUserID = currentUserID else { return }
        db.collection("users").document(currentUserID).updateData([
            "friends": FieldValue.arrayUnion([user.id]),
            "friendRequests": FieldValue.arrayRemove([user.id])
        ])
        db.collection("users").document(user.id).updateData([
            "friends": FieldValue.arrayUnion([currentUserID])
        ])
    }

    func declineFriendRequest(from user: User) {
        guard let currentUserID = currentUserID else { return }
        db.collection("users").document(currentUserID).updateData([
            "friendRequests": FieldValue.arrayRemove([user.id])
        ])
    }
    
    func removeFriend(user: User) {
        guard let currentUserID = currentUserID else { return }
        db.collection("users").document(currentUserID).updateData([
            "friends": FieldValue.arrayRemove([user.id])
        ])
        db.collection("users").document(user.id).updateData([
            "friends": FieldValue.arrayRemove([currentUserID])
        ])
    }

}


enum TabSelection: String, CaseIterable, Identifiable {
    case users = "Users"
    case friendRequests = "Add New"
    case friends = "Friends"
    var id: String { self.rawValue }
}
