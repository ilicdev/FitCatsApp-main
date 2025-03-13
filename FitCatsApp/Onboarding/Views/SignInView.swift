//
//  SignInView.swift
//  FitCatsApp
//
//  Created by ilicdev on 4.1.25..
//

import SwiftUI

struct SignInView: View {
    @StateObject var signInViewModel: SignInViewModel = SignInViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            BackButton {
                appViewModel.showLogin = false
            }
            
            VStack {
                Text("Welcome back!")
                    .font(.montserrat(size: 24, weight: .medium))
                Image("rank1")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .padding(.bottom, 40)
                
                VStack(spacing: 20) {
                    CustomTextField(label: "Email", 
                                  placeholder: "Enter your email", 
                                  text: $signInViewModel.username, 
                                  isSecure: false)
                    
                    CustomTextField(label: "Password", 
                                  placeholder: "Enter your password", 
                                  text: $signInViewModel.password, 
                                  isSecure: true)
                    
                    if !signInViewModel.errorMessage.isEmpty {
                        TextErrorView(errorMessage: signInViewModel.errorMessage)
                    }
                    
                    BlackCustomButton(title: "Sign In", 
                                    backgroundColor: .black, 
                                    textColor: .white, 
                                    cornerRadius: 10) {
                        Task {
                            await signInViewModel.login(appViewModel: appViewModel)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .overlay {
            if signInViewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
