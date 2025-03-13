//
//  SignInViewModel.swift
//  FitCatsApp
//
//  Created by ilicdev on 4.1.25..
//

import Foundation
import Combine

class SignInViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let services = ServiceContainer.shared
    
    func validateForm() -> Bool {
        errorMessage = ""
        
        if username.isEmpty {
            errorMessage = "Email cannot be empty"
            return false
        }
        
        if !username.contains("@") {
            errorMessage = "Invalid email format"
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Password cannot be empty"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        return true
    }
    
    func login(appViewModel: AppViewModel) async {
        guard validateForm() else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let userId = try await services.authService.signIn(email: username, password: password)
            let user = try await services.userService.getUser(id: userId)
            await MainActor.run {
                appViewModel.setAuthenticatedUser(user)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
