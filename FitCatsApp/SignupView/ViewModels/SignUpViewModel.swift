//
//  SignUpViewModel.swift
//  FitCatsApp
//
//  Created by ilicdev on 7.1.25..
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let signUpService: SignUpServiceProtocol
    
    init(signUpService: SignUpServiceProtocol = SignUpService()) {
        self.signUpService = signUpService
    }
    
    func signUp(appViewModel: AppViewModel) async {
        let validation = signUpService.validateSignUpForm(
            username: username,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        if !validation.isValid {
            errorMessage = validation.errorMessage
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let newUser = try await signUpService.createNewUser(
                username: username,
                email: email,
                password: password
            )
            
            await MainActor.run {
                appViewModel.setAuthenticatedUser(newUser)
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
