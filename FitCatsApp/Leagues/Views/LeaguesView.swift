//
//  LeaguesView.swift
//  FitCatsApp
//
//  Created by ilicdev on 27.1.25..
//

import SwiftUI

struct LeaguesView: View {
    @ObservedObject var viewModel: LeaguesViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var leagueName: String = ""
    @State private var showCreateLeagueSheet: Bool = false
    @State private var order: Int = 1
    @Namespace private var namespace

    var body: some View {
        VStack {
            menuView
            contentView
                .onAppear {
                    viewModel.fetchLeagues()
                    viewModel.fetchFriends(appViewModel: appViewModel)
                    viewModel.updateLeagueStatus()
                }
                .sheet(isPresented: $viewModel.openSheetDetail) {
                    LeagueDetailSheet(viewModel: viewModel)
                }
                Spacer()
            }
    }

    var menuView: some View {
        HStack {
            Spacer()
            Button {
                viewModel.selectedTab = .myLeague
            } label: {
                VStack {
                    Text("My leagues")
                        .font(.montserrat(size: 16, weight: .medium))
                        .foregroundStyle(Color.black)
                    ZStack {
                        if viewModel.selectedTab == .myLeague {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 70, height: 2)
                                .matchedGeometryEffect(id: "underline", in: namespace)
                                .transition(.move(edge: .bottom))
                        }
                    }
                    .frame(width: 70, height: 2)
                }
            }
       Spacer()
            Button {
                viewModel.selectedTab = .createNewLeague
            } label: {
                VStack {
                    Text("Create new league")
                        .font(.montserrat(size: 16, weight: .medium))
                        .foregroundStyle(Color.black)
                    ZStack {
                        if viewModel.selectedTab == .createNewLeague {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 70, height: 2)
                                .matchedGeometryEffect(id: "underline", in: namespace)
                                .transition(.move(edge: .bottom))
                        }
                    }
                    .frame(width: 70, height: 2)
                }
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.bottom, 18)

    }
    
    var contentView: some View {
        Group {
            if viewModel.selectedTab == .myLeague {
                VStack {
                     leagueStage
                if viewModel.selectedStage == .active {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.leagues.filter { $0.isActive == true }) { league in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 9)
                                .frame(height: 70)
                                .overlay(
                                    HStack {
                                        Image(systemName: "trophy")
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                        
                                        VStack(alignment: .leading) {
                                            Text(league.name)
                                                .font(.montserrat(size: 16, weight: .bold))
                                            
                                            Text("Ends in: \(viewModel.formattedDate(league.endDate))")
                                                .font(.montserrat(size: 14, weight: .regular))
                                                .foregroundStyle(Color.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                        .padding(.horizontal, 7)
                                )
                                .padding(.vertical, 9)
                                .onTapGesture {
                                    viewModel.openSheetDetail.toggle()
                                    viewModel.leagueId = league.id ?? ""
                                }
                        }
                        }

                    }
                }
                    else if viewModel.selectedStage == .completeed {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(viewModel.leagues.filter { $0.isActive != true }) { league in
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 9)
                                        .frame(height: 70)
                                        .overlay(
                                            HStack {
                                                Image(systemName: "trophy")
                                                    .resizable()
                                                    .frame(width: 35, height: 35)
                                                
                                                VStack(alignment: .leading) {
                                                    Text(league.name)
                                                        .font(.montserrat(size: 16, weight: .bold))
                                                    
                                                    Text("Ends in: \(viewModel.formattedDate(league.endDate))")
                                                        .font(.montserrat(size: 14, weight: .regular))
                                                        .foregroundStyle(Color.gray)
                                                }
                                                Spacer()
                                                Text("Completed")
                                                    .font(.montserrat(size: 11, weight: .bold))
                                                    .foregroundStyle(Color.green)
                                            }
                                                .padding(.horizontal, 7)
                                        )
                                        .padding(.vertical, 9)
                                        .onTapGesture {
                                            viewModel.openSheetDetail.toggle()
                                            viewModel.leagueId = league.id ?? ""
                                        }
                                    }
                                }
                            }
                    } else {
                        
                        Text("Wait a second...")
                            .font(.montserrat(size:14, weight:.bold))
                            .foregroundStyle(Color.gray)
                            .padding(.vertical, 40)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    viewModel.selectedStage = .active
                                }
                            }
                            
                    }
                }
            } else {
                CreateNewLeagueView(viewModel: viewModel)
            }
        }
    }
    
    var leagueStage: some View {
        HStack{
            Spacer()
            Button {
                viewModel.selectedStage = .inactive
            } label: {
                Text("Invites")
                    .font(.montserrat(size:14, weight:.bold))
                    .foregroundStyle(viewModel.selectedStage == .inactive ? Color.black : Color.gray)
            }
            Spacer()
            Divider()
                .frame(height:10)
            Spacer()
            Button {
                viewModel.selectedStage = .active
            } label: {
                Text("Active")
                    .font(.montserrat(size:14, weight:.bold))
                    .foregroundStyle(viewModel.selectedStage == .active ? Color.black : Color.gray)
            }
            Spacer()
            Divider()
                .frame(height:10)
            Spacer()
            Button {
                viewModel.selectedStage = .completeed
            } label: {
                Text("Completed")
                    .font(.montserrat(size:14, weight:.bold))
                    .foregroundStyle(viewModel.selectedStage == .completeed ? Color.black : Color.gray)
            }
            Spacer()
        }
    }
}


struct CreateNewLeagueView: View {
    @ObservedObject var viewModel: LeaguesViewModel
    @State private var selectedFriends: Set<String> = [] // Čuva ID-ove odabranih prijatelja

    var body: some View {
        VStack {
            Text("\(viewModel.currentStep) of \(viewModel.totalSteps)")
                .font(.montserrat(size:16, weight: .light))
                .foregroundStyle(Color.gray)
                .padding()

            Spacer()
            
            // Content for each step
            switch viewModel.currentStep {
            case 1:
                VStack {
                    Image(systemName: "trophy")
                        .resizable()
                        .frame(width:60, height:60)
                        .foregroundStyle(Color.gray)
                    Text("League name")
                        .font(.montserrat(size:18, weight: .medium))
                    textField
                    Spacer()
                }
            case 2:
                VStack {
                    Image(systemName: "calendar.badge.clock")
                        .resizable()
                        .frame(width:60, height:60)
                        .foregroundStyle(Color.gray)
                    Text("Start Date")
                        .font(.montserrat(size:18, weight: .medium))
                    
                    DatePicker("Start Date", selection: $viewModel.startDate, in: Date()...(Date().addingTimeInterval(7 * 24 * 60 * 60)), displayedComponents: .date)
                    Spacer()
                }
            case 3:
                VStack {
                    Image(systemName: "calendar.badge.checkmark")
                        .resizable()
                        .frame(width:60, height:60)
                        .foregroundStyle(Color.gray)
                    Text("End Date")
                        .font(.montserrat(size:18, weight: .medium))
                    
                    DatePicker("End Date", selection: $viewModel.endDate, in: viewModel.startDate...(Date().addingTimeInterval(7 * 24 * 60 * 60)), displayedComponents: .date)
                    Spacer()
                }
            case 4:
                VStack {
                    Text("Invite Friends")
                        .font(.montserrat(size: 18, weight: .medium))
                    ScrollView {
                    ForEach(viewModel.friends) { friend in
                        FriendRowView(friend: friend, selectedFriends: $selectedFriends)
                    }
                }
                    Spacer()
                }

            default:
                Text("Unknown Step")
            }
            
            Spacer()

            HStack {
                if viewModel.currentStep > 1 {
                    Button("Back") {
                        withAnimation {
                            viewModel.currentStep -= 1
                        }
                    }
                    .padding()
                    .font(.montserrat(size:14, weight:.bold))
                    .foregroundStyle(Color.gray)
                }

                Spacer()
                
                if viewModel.currentStep < viewModel.totalSteps {
                    Button("Next") {
                        withAnimation {
                            viewModel.currentStep += 1
                        }
                    }
                    .padding()
                    .font(.montserrat(size:14, weight:.bold))
                    .foregroundStyle(Color.gray)
                } else {
                    Button("Finish") {
                        viewModel.createLeague(invitedFriends: Array(selectedFriends))
                        viewModel.selectedTab = .myLeague
                    }
                    .padding()
                    .font(.montserrat(size:14, weight:.bold))
                    .foregroundStyle(Color.gray)
                }
            }
        }
        .padding()
        .animation(.default, value: viewModel.currentStep)
    }
    
    var textField: some View {
        TextField("Enter text", text: $viewModel.nameOfLeague)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.clear)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(.top, 40), alignment: .bottom
            )
            .padding(.bottom, 10)
    }
}


struct FriendRowView: View {
    let friend: User
    @Binding var selectedFriends: Set<String>

    var body: some View {
        HStack {
            Image(friend.currentRank?.imageName ?? "")
                .resizable()
                .frame(width: 20, height: 20)
            Text(friend.username ?? "")
                .font(.montserrat(size: 16, weight: .bold))
            Spacer()
            if selectedFriends.contains(friend.id ?? "") {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        selectedFriends.remove(friend.id ?? "")
                    }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        selectedFriends.insert(friend.id ?? "")
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.black)
        )
        .foregroundStyle(Color.white)
    }
}



