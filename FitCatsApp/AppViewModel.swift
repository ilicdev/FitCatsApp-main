//
//  AppViewModel.swift
//  FitCatsApp
//
//  Created by ilicdev on 9.1.25..
//

import Foundation
import Combine

class AppViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var showLogin: Bool = false
    @Published var showSignUp: Bool = false
    
    private let services = ServiceContainer.shared
    private var cancellables = Set<AnyCancellable>()
    
    func setAuthenticatedUser(_ user: User?) {
        currentUser = user
        isAuthenticated = user != nil
    }
    
    func fetchUserFromFirestore(userId: String) async {
        do {
            let user = try await services.userService.getUser(id: userId)
            await MainActor.run {
                self.currentUser = user
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }
    
    func setupHealthKit() {
        guard services.healthService.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        Task {
            do {
                let success = try await services.healthService.requestAuthorization()
                if success {
                    print("HealthKit authorization successful")
                    await fetchSteps()
                } else {
                    print("User did not authorize HealthKit access")
                }
            } catch {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSteps() async {
        do {
            let steps = try await services.healthService.fetchStepsForLast7Days()
            print("Steps for last 7 days: \(steps)")
        } catch {
            print("Error fetching steps: \(error.localizedDescription)")
        }
    }
}
