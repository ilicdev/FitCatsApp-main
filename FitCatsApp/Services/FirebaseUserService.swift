import Foundation
import FirebaseFirestore

class FirebaseUserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    func getUser(id: String) async throws -> User {
        let document = try await db.collection(usersCollection).document(id).getDocument()
        guard let data = document.data() else {
            throw NSError(domain: "FirebaseUserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return try Firestore.Decoder().decode(User.self, from: data)
    }
    
    func updateUser(id: String, data: [String: Any]) async throws {
        try await db.collection(usersCollection).document(id).updateData(data)
    }
    
    func createUser(user: User) async throws {
        try await db.collection(usersCollection).document(user.id).setData(from: user)
    }
    
    func sendFriendRequest(from: String, to: String) async throws {
        try await db.collection(usersCollection).document(to).updateData([
            "friendRequests": FieldValue.arrayUnion([from])
        ])
    }
    
    func acceptFriendRequest(from: String, to: String) async throws {
        let batch = db.batch()
        
        // Add each user to the other's friends list
        let toUserRef = db.collection(usersCollection).document(to)
        let fromUserRef = db.collection(usersCollection).document(from)
        
        batch.updateData([
            "friends": FieldValue.arrayUnion([from]),
            "friendRequests": FieldValue.arrayRemove([from])
        ], forDocument: toUserRef)
        
        batch.updateData([
            "friends": FieldValue.arrayUnion([to])
        ], forDocument: fromUserRef)
        
        try await batch.commit()
    }
    
    func declineFriendRequest(from: String, to: String) async throws {
        try await db.collection(usersCollection).document(to).updateData([
            "friendRequests": FieldValue.arrayRemove([from])
        ])
    }
} 