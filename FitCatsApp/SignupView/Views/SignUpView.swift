//
//  SignUpView.swift
//  FitCatsApp
//
//  Created by ilicdev on 7.1.25..
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appViewModel: AppViewModel // Povezivanje sa centralnim ViewModel-om
    @StateObject var signUpViewModel: SignUpViewModel = SignUpViewModel()
    
    var body: some View {
        VStack(alignment:.leading){
            BackButton {
                appViewModel.showSignUp = false
            }
            VStack {
                Text("Create new account!")
                    .font(.montserrat(size: 24, weight:.medium))
                Image("rank1")
                    .resizable()
                    .frame(width:90, height:90)
                    .padding(.bottom, 40)
                VStack(spacing:20){
                    CustomTextField(label: "Username", placeholder: "Enter your username", text: $signUpViewModel.username, isSecure: false)
                    CustomTextField(label: "Email", placeholder: "Enter your email", text: $signUpViewModel.email, isSecure: false)
                    CustomTextField(label: "Password", placeholder: "Enter your password", text: $signUpViewModel.password, isSecure: true)
                    CustomTextField(label: "Confirm password", placeholder: "Enter password again", text: $signUpViewModel.confirmPassword, isSecure: true)
                    
                    if !signUpViewModel.errorMessage.isEmpty {
                        TextErrorView(errorMessage: signUpViewModel.errorMessage)
                    }
                    
                    BlackCustomButton(title: "Sign Up", backgroundColor: .black, textColor: .white, cornerRadius: 10) {
                        Task {
                            await signUpViewModel.signUp(appViewModel: appViewModel)
                        }
                    }
                }
                Spacer()
            }
            .overlay{
                ZStack{
                    if signUpViewModel.isLoading {
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
}

#Preview {
    SignUpView()
}

