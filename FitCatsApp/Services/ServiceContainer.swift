import Foundation

class ServiceContainer {
    static let shared = ServiceContainer()
    
    let healthService: HealthServiceProtocol
    let authService: AuthServiceProtocol
    let userService: UserServiceProtocol
    let leagueService: LeagueServiceProtocol
    let signUpService: SignUpServiceProtocol
    
    private init() {
        self.healthService = HealthKitService()
        self.authService = FirebaseAuthService()
        self.userService = FirebaseUserService()
        self.leagueService = FirebaseLeagueService()
        self.signUpService = SignUpService()
    }
} 