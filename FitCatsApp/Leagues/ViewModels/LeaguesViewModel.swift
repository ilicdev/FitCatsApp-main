//
//  LeaguesViewModel.swift
//  FitCatsApp
//
//  Created by ilicdev on 27.1.25..
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class LeaguesViewModel: ObservableObject {
    @Published var leagues: [League] = []
    @Published var league: League?
    @Published var currentUserId: String
    @Published var currentSteps: Int
    @Published var selectedTab: LeaguesMenu = .myLeague
    @Published var currentStep: Int = 1
    @Published var leagueId: String  = ""
    @Published var currentUser: User?
    @Published var participants: [User] = []
    @Published var openSheetDetail: Bool = false
    @Published var users: [String: User] = [:]
    @Published var selectedStage: LeagueStage = .active
    @Published var leaderBoardMenu: LeaderboardMenu = .leaderBoard

    let totalSteps: Int = 4
    private var db = Firestore.firestore()
    
    @Published var nameOfLeague: String = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var friends: [User] = []

    init(userId: String, steps: Int) {
        self.currentUserId = userId
        self.currentSteps = steps
        fetchLeagues()
    }
    
    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
    
    func fetchLeagueByID(leagueID: String, completion: @escaping (League?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("leagues").document(leagueID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching league: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = snapshot, document.exists else {
                print("League not found.")
                completion(nil)
                return
            }
            
            do {
                let league = try document.data(as: League.self)
                completion(league)
            } catch {
                print("Error decoding league: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    func fetchParticipantsForLeague(leagueID: String, completion: @escaping ([User]?) -> Void) {
        let db = Firestore.firestore()
        
        // 1. Pronađi ligu prema ID-ju
        db.collection("leagues").document(leagueID).getDocument { leagueSnapshot, error in
            if let error = error {
                print("Error fetching league: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let leagueData = leagueSnapshot?.data() else {
                print("League not found.")
                completion(nil)
                return
            }
            
            // 2. Izvuci participant IDs iz lige
            guard let participantIDs = leagueData["participants"] as? [String], !participantIDs.isEmpty else {
                print("No participants found for this league.")
                completion([])
                return
            }
            
            // 3. Povuci korisnike pomoću participant IDs
            db.collection("users")
                .whereField("id", in: participantIDs) // Pronađi korisnike čiji ID-jevi su u listi
                .getDocuments { userSnapshot, error in
                    if let error = error {
                        print("Error fetching participants: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    
                    guard let documents = userSnapshot?.documents else {
                        completion([])
                        return
                    }
                    
                    let users = documents.compactMap { document -> User? in
                        do {
                            return try document.data(as: User.self)
                        } catch {
                            print("Error decoding user: \(error.localizedDescription)")
                            return nil
                        }
                    }
                    completion(users)
                }
        }
    }
    
    func onLeagueSelected(leagueID: String) {
        fetchParticipantsForLeague(leagueID: leagueID) { users in
            if let users = users {
                print("Participants for league \(leagueID):")
                self.participants = users
            } else {
                print("Failed to fetch participants for league \(leagueID).")
            }
        }
        
        fetchLeagueByID(leagueID: leagueID) { league in
            if let league = league {
                print("League fetched successfully: \(leagueID):")
                self.league = league
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
        }
    }

    
    
    func fetchFriends(appViewModel: AppViewModel) {
        print("Pozvana fetchFriends funkcija.")

        guard let user = appViewModel.currentUser else {
            print("korisnik ne postoji")
            return
        }
        
        guard let friendsIDs = user.friends, !friendsIDs.isEmpty else {
               print("Lista prijatelja je prazna: \(user.friends ?? [])")
               self.friends = []
               return
           }
        
        
        db.collection("users").whereField("id", in: friendsIDs).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Friends IDs: \(friendsIDs)")
                self.friends = []
                return
            }
            print("Ovo je lista prijatelja: \(self.friends)")
            DispatchQueue.main.async {
                
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
            print("Osvežena lista prijatelja: \(self.friends)")

        }
    }

    func fetchUser(by id: String, completion: @escaping (User?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(id).getDocument { document, error in
            if let error = error {
                print("Error fetching user: \(error)")
                completion(nil)
                return
            }
            
            if let document = document, document.exists {
                do {
                    // Decode the document into a User object
                    let user = try document.data(as: User.self)
                    completion(user)
                } catch {
                    print("Error decoding user: \(error)")
                    completion(nil)
                }
            } else {
                print("User with id \(id) does not exist.")
                completion(nil)
            }
        }
    }

    func fetchLeagues() {
        db.collection("users").document(currentUserId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let leagueIds = document.data()?["leagues"] as? [String] {
                    self.fetchLeaguesDetails(leagueIds: leagueIds)
                }
            }
        }
    }

    func fetchLeaguesDetails(leagueIds: [String]) {
        let dispatchGroup = DispatchGroup()
        for leagueId in leagueIds {
            dispatchGroup.enter()
            
            db.collection("leagues").document(leagueId).getDocument { (document, error) in
                if let document = document, document.exists {
                    do {
                        var league = try document.data(as: League.self)
                        league.id = document.documentID
                        
                        // Pokreni transakciju da bi ažurirao podatke
                        let leagueRef = self.db.collection("leagues").document(leagueId)
                        self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                            let leagueDocument: DocumentSnapshot
                            do {
                                try leagueDocument = transaction.getDocument(leagueRef)
                            } catch let fetchError as NSError {
                                errorPointer?.pointee = fetchError
                                return nil
                            }

                            // Setovanje novog statusa isActive
                            transaction.updateData(["isActive": league.isActive], forDocument: leagueRef)

                            return nil
                        }) { (object, error) in
                            if let error = error {
                                print("Transaction failed: \(error)")
                            } else {
                                // Fetching again for UI update
                                DispatchQueue.main.async {
                                    self.leagues.append(league)
                                }
                            }
                        }
                    } catch {
                        print("Error decoding league: \(error)")
                    }
                } else if let error = error {
                    print("Error fetching league: \(error)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.fetchCreatedByUsers()
        }
    }
    
    func updateLeagueStatus() {
        let db = Firestore.firestore()
        let today = Timestamp(date: Date())
        db.collection("leagues")
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching leagues: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let batch = db.batch()
                for document in documents {
                    let data = document.data()
                    if let endDate = data["endDate"] as? Timestamp {
                        if endDate.seconds <= today.seconds { // Provera da li je endDate prošao
                            batch.updateData(["isActive": false], forDocument: document.reference)
                        }
                    }
                }
                
                batch.commit { error in
                    if let error = error {
                        print("Error updating leagues: \(error.localizedDescription)")
                    } else {
                        print("Successfully updated expired leagues.")
                        self.fetchLeagues()
                    }
                }
            }
    }

    func createLeague(invitedFriends: [String]) {
        let newLeague = League(
            id: UUID().uuidString,
            name: self.nameOfLeague,
            startDate: self.startDate,
            endDate: self.endDate,
            participants: [currentUserId] + invitedFriends,
            steps: [currentSteps],
            isActive: true,
            createdBy: currentUserId
        )

        db.collection("leagues").document(newLeague.id ?? "").setData([
            "name": newLeague.name,
            "startDate": newLeague.startDate,
            "endDate": newLeague.endDate,
            "participants": newLeague.participants,
            "steps": newLeague.steps,
            "isActive": newLeague.isActive,
            "createdBy": newLeague.createdBy
        ]) { error in
            if let error = error {
                print("Error creating league: \(error)")
            } else {
                self.addUserToLeague(leagueId: newLeague.id ?? "")
                print("League successfully created: \(newLeague)")
            }
        }
    }

    
    func fetchCreatedByUsers() {
        for index in leagues.indices {
            let league = leagues[index]
            fetchUser(by: league.createdBy) { user in
                if let user = user {
                    DispatchQueue.main.async {
                        self.leagues[index].createdByUser = user
                    }
                }
            }
        }
    }
    // Add user to the created league
    func addUserToLeague(leagueId: String) {
        db.collection("users").document(currentUserId).updateData([
            "leagues": FieldValue.arrayUnion([leagueId])
        ])
    }

    // Update steps for the user in the league
    func updateStepsInLeague(leagueId: String, steps: Int) {
        db.collection("leagues").document(leagueId).updateData([
            "steps": FieldValue.arrayUnion([steps])
        ])
        
        db.collection("users").document(currentUserId).updateData([
            "leagueSteps": FieldValue.arrayUnion([LeagueSteps(league: leagueId, steps: steps)])
        ])
    }

    func sortLeaguesBySteps() {
        leagues.sort { $0.steps.max() ?? 0 > $1.steps.max() ?? 0 }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.M.yyyy."
        return formatter.string(from: date)
    }
}


enum LeaguesMenu: String, CaseIterable, Identifiable {
    case myLeague = "My leagues"
    case createNewLeague = "Create new league"
    var id: String { self.rawValue }
}

enum LeagueStage: String, CaseIterable, Identifiable {
    case inactive = "Inactive"
    case active = "Active"
    case completeed = "Completed"
    
    var id: String { self.rawValue }
}

enum LeaderboardMenu: String, CaseIterable, Identifiable {
    case leaderBoard = "Leaderboard"
    case info = "Info"

    var id: String { self.rawValue }
}
