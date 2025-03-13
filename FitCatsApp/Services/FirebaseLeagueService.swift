import Foundation
import FirebaseFirestore

class FirebaseLeagueService: LeagueServiceProtocol {
    private let db = Firestore.firestore()
    private let leaguesCollection = "leagues"
    private let usersCollection = "users"
    
    func createLeague(league: League) async throws {
        try await db.collection(leaguesCollection).document(league.id ?? "").setData(from: league)
    }
    
    func getLeague(id: String) async throws -> League {
        let document = try await db.collection(leaguesCollection).document(id).getDocument()
        guard let data = document.data() else {
            throw NSError(domain: "FirebaseLeagueService", code: -1, userInfo: [NSLocalizedDescriptionKey: "League not found"])
        }
        return try Firestore.Decoder().decode(League.self, from: data)
    }
    
    func updateLeague(id: String, data: [String: Any]) async throws {
        try await db.collection(leaguesCollection).document(id).updateData(data)
    }
    
    func getLeaguesForUser(userId: String) async throws -> [League] {
        let snapshot = try await db.collection(leaguesCollection)
            .whereField("participants", arrayContains: userId)
            .getDocuments()
        
        return try snapshot.documents.map { document in
            try Firestore.Decoder().decode(League.self, from: document.data())
        }
    }
    
    func joinLeague(userId: String, leagueId: String) async throws {
        let batch = db.batch()
        
        // Add user to league participants
        let leagueRef = db.collection(leaguesCollection).document(leagueId)
        batch.updateData([
            "participants": FieldValue.arrayUnion([userId])
        ], forDocument: leagueRef)
        
        // Add league to user's leagues
        let userRef = db.collection(usersCollection).document(userId)
        batch.updateData([
            "leagues": FieldValue.arrayUnion([leagueId])
        ], forDocument: userRef)
        
        try await batch.commit()
    }
    
    func leaveLeague(userId: String, leagueId: String) async throws {
        let batch = db.batch()
        
        // Remove user from league participants
        let leagueRef = db.collection(leaguesCollection).document(leagueId)
        batch.updateData([
            "participants": FieldValue.arrayRemove([userId])
        ], forDocument: leagueRef)
        
        // Remove league from user's leagues
        let userRef = db.collection(usersCollection).document(userId)
        batch.updateData([
            "leagues": FieldValue.arrayRemove([leagueId])
        ], forDocument: userRef)
        
        try await batch.commit()
    }
} 
