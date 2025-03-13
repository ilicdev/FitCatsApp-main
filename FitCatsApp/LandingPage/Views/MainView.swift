//
//  HomeLandingView.swift
//  FitCatsApp
//
//  Created by ilicdev on 7.1.25..
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject var mainViewModel: MainViewModel = MainViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    var body: some View {
        VStack {
            Spacer()
            if mainViewModel.selectedItem == 0{
                HomeView()
            } else if mainViewModel.selectedItem == 1{
                AboutView()
            } else if mainViewModel.selectedItem == 2 {
                LeaguesView(viewModel: LeaguesViewModel(userId: appViewModel.currentUser?.id ?? "", steps: appViewModel.currentUser?.thisWeekSteps ?? 0))
            } else if mainViewModel.selectedItem == 3 {
                AddFriendsView()
            } else if mainViewModel.selectedItem == 4 {
                ProfileView()
            }
            Spacer()
            HStack(spacing: 15) {
                Spacer()
                MenuItem(iconName: "pawprint.fill", tag: 1, selectedItem: $mainViewModel.selectedItem)
                Spacer()
                MenuItem(iconName: "trophy.fill", tag: 2, selectedItem: $mainViewModel.selectedItem)
                Spacer()
                MenuItem(iconName: "house.fill", tag: 0, selectedItem: $mainViewModel.selectedItem)
                Spacer()
                MenuItem(iconName: "person.2", tag: 3, selectedItem: $mainViewModel.selectedItem)
                Spacer()
                MenuItem(iconName: "person.crop.circle", tag: 4, selectedItem: $mainViewModel.selectedItem)
                Spacer()
            }
            .padding()
            .padding(.horizontal, 20)
            .frame(height:70)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
//                Color.white
            )
          
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -5)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MenuItem: View {
    let iconName: String
    let tag: Int
    @Binding var selectedItem: Int?
    
    var body: some View {
        if selectedItem == tag {
            Button(action: {
                selectedItem = tag
            }) {
                Image(systemName: iconName)
                    .font(.system(size: 21))
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 11)
                    .background(
                        Capsule()
                            .fill(Color.black)
                    )
            }
        } else {
            Button(action: {
                selectedItem = tag
            }) {
                Image(systemName: iconName)
                    .font(.system(size: 21))
                    .foregroundStyle(Color.gray)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 11)
            }
        }
    }
}
