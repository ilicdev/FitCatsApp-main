import Foundation

protocol SignUpServiceProtocol {
    func validateSignUpForm(username: String, email: String, password: String, confirmPassword: String) -> (isValid: Bool, errorMessage: String)
    func createNewUser(username: String, email: String, password: String) async throws -> User
}

class SignUpService: SignUpServiceProtocol {
    private let services = ServiceContainer.shared
    
    func validateSignUpForm(username: String, email: String, password: String, confirmPassword: String) -> (isValid: Bool, errorMessage: String) {
        if username.isEmpty {
            return (false, "Username cannot be empty")
        }
        
        if email.isEmpty {
            return (false, "Email cannot be empty")
        }
        
        if !email.contains("@") {
            return (false, "Invalid email format")
        }
        
        if password.isEmpty {
            return (false, "Password cannot be empty")
        }
        
        if password.count < 6 {
            return (false, "Password must be at least 6 characters")
        }
        
        if password != confirmPassword {
            return (false, "Passwords do not match")
        }
        
        return (true, "")
    }
    
    func createNewUser(username: String, email: String, password: String) async throws -> User {
        let userId = try await services.authService.signUp(email: email, password: password)
        
        let newUser = User(
            id: userId,
            username: username,
            email: email,
            thisWeekSteps: 0,
            lastWeekSteps: 0,
            currentRank: Rank(name: "Cat", imageName: "rank1", threshold: 0),
            rankHistory: [:],
            friends: [],
            friendRequests: [],
            leagues: [],
            leagueInvites: [],
            leagueSteps: [],
            statistics: Statistics(totalSteps: 0, stepsPerWeek: [], ranks: [], bestRank: "Cat")
        )
        
        try await services.userService.createUser(user: newUser)
        return newUser
    }
} 