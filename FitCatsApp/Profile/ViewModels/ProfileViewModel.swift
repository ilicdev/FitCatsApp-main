//
//  ProfileViewModel.swift
//  FitCatsApp
//
//  Created by ilicdev on 24.1.25..
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var rankHistory: [String: Int] = [:]
    @Published var currentRank: Rank?
    
    let ranks: [Rank] = [
        Rank(name: "Cat", imageName: "rank1", rank: 0, threshold: 21_000, color: "Yellow", minSteps: 0, maxSteps: 21_000),
        Rank(name: "Cheetah", imageName: "rank2", rank: 1, threshold: 42_000, color: "Orange", minSteps: 21_000, maxSteps: 42_000),
        Rank(name: "Jaguar", imageName: "rank3", rank: 2, threshold: 63_000, color: "Red", minSteps: 42_000, maxSteps: 63_000),
        Rank(name: "Leopard", imageName: "rank4", rank: 3, threshold: 84_000, color: "Blue", minSteps: 63_000, maxSteps: 84_000),
        Rank(name: "Tiger", imageName: "rank5", rank: 4, threshold: 105_000, color: "Purple", minSteps: 84_000, maxSteps: 105_000),
        Rank(name: "Lion", imageName: "rank6", rank: 5, threshold: 105_000, color: "Purple", minSteps: 105_000, maxSteps: 250_000)
    ]
    
    init() {
        // Inicijalizuj rankHistory sa svim rankovima postavljenim na 0
        rankHistory = ranks.reduce(into: [String: Int]()) { dict, rank in
            dict[rank.name] = 0
        }
        
    }

    @MainActor
    func fetchRankHistory() {
        let db = Firestore.firestore()
        guard let currentUser = Auth.auth().currentUser else {
            print("User is not logged in")
            return
        }
        
        let userId = currentUser.uid
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists, let data = document.data() {
                // Ažuriraj rankHistory sa podacima iz Firestore-a
                if let fetchedRankHistory = data["rankHistory"] as? [String: Int] {
                    var updatedRankHistory = self?.rankHistory ?? [:]
                    for (rankName, count) in fetchedRankHistory {
                        updatedRankHistory[rankName] = count
                    }

                    print("Fetched rankHistory:", fetchedRankHistory)

                    // Postavi rankHistory sa ažuriranim podacima
                    self?.rankHistory = updatedRankHistory
                    print("Updated rankHistory:", self?.rankHistory) // Proveri da li je rankHistory ažuriran
                }
            } else {
                print("Document does not exist or error fetching data.")
            }
        }
    }

}
