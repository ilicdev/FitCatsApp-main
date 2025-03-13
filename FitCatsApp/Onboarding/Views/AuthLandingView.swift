//
//  ContentView.swift
//  FitCatsApp
//
//  Created by ilicdev on 27.12.24..
//

import SwiftUI

struct AuthLandingView: View {
    @ObservedObject var authLandingViewModel = AuthLandingViewModel()
    @EnvironmentObject var appViewModel: AppViewModel  // Pristupamo AppViewModel putem EnvironmentObject

    var body: some View {
        VStack{
            if appViewModel.showLogin {
                SignInView()
                    .environmentObject(appViewModel)

            } else if appViewModel.showSignUp {
                SignUpView()
                    .environmentObject(appViewModel)
            } else {
                authLandingView
            }
            
        
        }
   
    }
    
    var authLandingView: some View {
        VStack {
            VStack{
                Text("Welcome to")
                    .font(.montserrat(size: 24, weight: .medium))
                
                Text("Fitness Cats!")
                    .font(.montserrat(size: 34, weight: .medium))
             
                Image("rank1")
                    .resizable()
                    .frame(width:145, height:145)
     
                    .padding(.vertical, 30)
            }
  
            Text("Sign in or create a new account")
                .font(.montserrat(size: 16, weight: .regular))
                .foregroundStyle(Color.gray)
                .padding(.vertical, 15)
            Button{
                appViewModel.showLogin.toggle()
            }label: {
                BlackCustomButton(title: "Go To Sign In", backgroundColor: Color.black, textColor: Color.white, cornerRadius: 10)
            }
         
            Button{
                appViewModel.showSignUp.toggle()
            }label:{
                BlackCustomButton(title: "Dont't have account? Sign Up", backgroundColor: Color.black, textColor: Color.white, cornerRadius: 10)
            }
        }
    }
}

#Preview {
    AuthLandingView()
}
