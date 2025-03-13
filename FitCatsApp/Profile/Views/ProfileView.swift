//
//  ProfileView.swift
//  FitCatsApp
//
//  Created by ilicdev on 24.1.25..
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject var profileViewModel: ProfileViewModel = ProfileViewModel()
    let columns = [
        GridItem(.flexible()), // Prva kolona sa fiksnom širinom
        GridItem(.flexible())  // Druga kolona sa fiksnom širinom
    ]
    var body: some View {
    VStack {
        ScrollView {
            VStack {
                if let currentUser = appViewModel.currentUser {
                    PersonalProfileView(user: currentUser)
                }
                
                VStack {
                    // Naslov
                    Text("Rank Achievements")
                        .font(.montserrat(size:20, weight: .medium))
                        .padding()
                    
                    if !profileViewModel.rankHistory.isEmpty {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                            ForEach(profileViewModel.rankHistory.keys.sorted(), id: \.self) { key in
                                if let rank = profileViewModel.ranks.first(where: { $0.name == key }) {
                                    VStack {
                                        HStack {
                                            VStack {
                                                Image(rank.imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 94, height: 94)
                                                Text(rank.name)
                                                    .font(.montserrat(size: 16, weight: .bold))
                                                    .fixedSize(horizontal: true, vertical: false)
                                            }
                                            
                                            Text("\(profileViewModel.rankHistory[key] ?? 0)")
                                                .font(.montserrat(size: 20, weight: .bold))
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                        
                    } else {
                        Text("No rank history available")
                            .foregroundColor(.gray)
                    }
                    
                    
                }
                .onAppear {
                    profileViewModel.fetchRankHistory()
                }
            }
                
                
            }
            .padding(.horizontal, 10)
            HStack{
                 BlackCustomButton(
                    title: "Add Friends",
                    backgroundColor: Color.black,
                    textColor: Color.white,
                    cornerRadius: 10,
                    destination: AnyView(
                        VStack(alignment:.leading){
                            AddFriendsView()
                        }
                            .padding(.horizontal, 20)
                    )
                )
                
                BlackCustomButton(title: "Sign Out", backgroundColor: Color.black, textColor: Color.white, cornerRadius: 10) {
                    // action
                    DispatchQueue.main.async {
                        appViewModel.currentUser = nil
                        appViewModel.isAuthenticated = false
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
}

struct PersonalProfileView: View {
    var user: User
    var body: some View {
        HStack{
            VStack(alignment:.leading){
                Text("\(user.username ?? "")")
                    .font(.montserrat(size:24, weight: .bold))
                    .padding(.bottom, 8)
                Text("\(user.friends?.count ?? 0) Friends")
                    .font(.montserrat(size:14, weight: .bold))
                Text("This week score: \(user.thisWeekSteps ?? 0)")
                    .font(.montserrat(size:14, weight: .regular))
            }
            
            Spacer()
            VStack{
                Image("\(user.currentRank?.imageName ?? "rank1")")
                    .resizable()
                    .frame(width:60, height:60)
                Text("\(user.currentRank?.name ?? "Cat")")
                    .font(.montserrat(size:16, weight: .bold))
            }
        }
    }
}

#Preview {
    ProfileView()
}
