//
//  FitCatsAppApp.swift
//  FitCatsApp
//
//  Created by ilicdev on 27.12.24..
//

import SwiftUI
import FirebaseCore
import HealthKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct FitCatsApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    RootView()
                        .environmentObject(appViewModel)
                        .onAppear {
                            appViewModel.setupHealthKit()
                        }
                    
                }.padding(.horizontal, 30)
            }
        }
    }
}


