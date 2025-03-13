//
//  AddFriendsView.swift
//  FitCatsApp
//
//  Created by ilicdev on 25.1.25..
//

import SwiftUI
import FirebaseAuth

struct AddFriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @Namespace private var namespace

    var body: some View {
        VStack {
            menuView
                .padding(.vertical)
            SearchBar(text: $viewModel.searchText)
            contentView
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
    
    var contentView: some View {
        ScrollView{
            if viewModel.selectedTab == .users {
                
                if viewModel.searchText.isEmpty {
                    ForEach(viewModel.users) { user in
                        HStack {
                            UserRow(user: user, isOnFriendsListView: false, isOnFriendRequestListView: false) {
                                viewModel.sendFriendRequest(to: user)
                                
                            }
                            
                        }
                    }
                } else {
                    ForEach(viewModel.filteredUsers) { user in
                        HStack {
                            UserRow(user: user, isOnFriendsListView: false, isOnFriendRequestListView: false) {
                                viewModel.sendFriendRequest(to: user)
                                
                            }
                            
                        }
                    }
                }
            } else if viewModel.selectedTab == .friendRequests {
                if viewModel.searchText.isEmpty {
                    ForEach(viewModel.friendRequests) { user in
                        UserRow(user: user, isOnFriendsListView: false, isOnFriendRequestListView: true) {
                            // no action
                        } acceptAction: {
                            viewModel.acceptFriendRequest(from: user)
                        } rejectAction: {
                            viewModel.declineFriendRequest(from: user)
                        }
                    }
                    
                } else {
                    ForEach(viewModel.filteredRequests) { user in
                        UserRow(user: user, isOnFriendsListView: false, isOnFriendRequestListView: true) {
                            // no action
                        } acceptAction: {
                            viewModel.acceptFriendRequest(from: user)
                        } rejectAction: {
                            viewModel.declineFriendRequest(from: user)
                        }
                    }
                }
            } else if viewModel.selectedTab == .friends {
                if viewModel.searchText.isEmpty {
                    ForEach(viewModel.friends) { user in
                        UserRow(user: user, isOnFriendsListView: true, isOnFriendRequestListView: false) {
                            viewModel.removeFriend(user: user)
                        }
                    }
                } else {
                    
                    ForEach(viewModel.filteredFriends) { user in
                        UserRow(user: user, isOnFriendsListView: true, isOnFriendRequestListView: false) {
                            viewModel.removeFriend(user: user)
                        }
                    }
                }
                
            }
            
        }

    }
    
    var menuView: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    viewModel.selectedTab = .users
                }
            } label: {
                VStack {
                    Text("Add New")
                        .font(.montserrat(size: 19, weight: .medium))
                    ZStack {
                        if viewModel.selectedTab == .users {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 70, height: 2)
                                .matchedGeometryEffect(id: "underline", in: namespace)
                                .transition(.move(edge: .bottom)) // Animacija slajda
                        }
                    }
                    .frame(width: 70, height: 2)
                }
            }
            Spacer()
            Button {
                withAnimation {
                    viewModel.selectedTab = .friendRequests
                }
            } label: {
                VStack {
                    Text("Requests")
                        .font(.montserrat(size: 19, weight: .medium))
                    ZStack {
                        if viewModel.selectedTab == .friendRequests {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 70, height: 2)
                                .matchedGeometryEffect(id: "underline", in: namespace)
                                .transition(.move(edge: .bottom)) // Animacija slajda
                        }
                    }
                    .frame(width: 70, height: 2)
                }
            }
            Spacer()
            Button {
                withAnimation {
                    viewModel.selectedTab = .friends
                }
            } label: {
                VStack {
                    Text("Friends")
                        .font(.montserrat(size: 19, weight: .medium))
                    ZStack {
                        if viewModel.selectedTab == .friends {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 70, height: 2)
                                .matchedGeometryEffect(id: "underline", in: namespace)
                                .transition(.move(edge: .bottom)) // Animacija slajda
                        }
                    }
                    .frame(width: 70, height: 2)
                }
            }
            Spacer()
        }
        .foregroundStyle(Color.black)
    }
}



struct UserRow: View {
    var user: User
    var isOnFriendsListView: Bool
    var isOnFriendRequestListView: Bool
    var action: () -> () // Akcija za slanje ili otkazivanje zahteva
    var acceptAction: (() -> ())? // Akcija za prihvatanje zahteva
    var rejectAction: (() -> ())? // Akcija za odbijanje zahteva
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.black)
            .frame(height: 50)
            .overlay(
                HStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30)
                        .overlay(
                            Image(user.currentRank?.imageName ?? "")
                                .resizable()
                                .frame(width: 20, height: 20)
                        )
                    
                    Text("\(user.username ?? "")")
                        .font(.montserrat(size: 16, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    Text("\(user.thisWeekSteps ?? 0)")
                        .font(.montserrat(size: 16, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                    if isOnFriendRequestListView {
                        // Ako smo na Friend Requests View, prikazujemo dugmadi za prihvatanje i odbijanje
                        HStack {
                            if let acceptAction = acceptAction {
                                Button(action: acceptAction) {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.green)
                                        .frame(width: 25, height: 25)
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .resizable()
                                                .foregroundStyle(Color.white)
                                                .frame(width: 15, height: 15)
                                        )
                                }
                            }
                            
                            if let rejectAction = rejectAction {
                                Button(action: rejectAction) {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.red)
                                        .frame(width: 25, height: 25)
                                        .overlay(
                                            Image(systemName: "xmark")
                                                .resizable()
                                                .foregroundStyle(Color.white)
                                                .frame(width: 15, height: 15)
                                        )
                                }
                            }
                        }
                    } else if isOnFriendsListView {
                        // Ako smo na Friends List View, prikazujemo dugme za uklanjanje prijatelja
                        Button(action: action) {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color.red)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .foregroundStyle(Color.white)
                                        .frame(width: 15, height: 15)
                                )
                        }
                    } else {
                        // Default: Prikazujemo dugme za slanje zahteva za prijateljstvo
                        Button(action: action) {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color.white)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Image(systemName: "plus")
                                        .resizable()
                                        .foregroundStyle(Color.black)
                                        .frame(width: 15, height: 15)
                                )
                        }
                    }
                }
                    .padding(.horizontal, 15)
            )
    }
}


struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search...", text: $text)
                .padding(7)
                .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(height:50)
                .shadow(color: Color.black.opacity(0.5), radius: 10, y: 8)
        )
    }
}
