//
//  LeagueDetailSheet.swift
//  FitCatsApp
//
//  Created by ilicdev on 29.1.25..
//

import SwiftUI

struct LeagueDetailSheet: View {
    @ObservedObject var viewModel: LeaguesViewModel
    var body: some View {
            VStack(spacing:10){
                HStack {
                    Text("League Info")
                        .font(.montserrat(size:24, weight:.bold))
                        .padding(.vertical)
                    Spacer()
                }
                HStack {
                    Button {
                        viewModel.leaderBoardMenu = .leaderBoard
                    } label: {
                        Text("Leaderboard")
                            .font(.montserrat(size:14, weight:.bold))
                            .foregroundStyle(viewModel.leaderBoardMenu == .leaderBoard ? Color.black : Color.gray)
                    }
                    
                    Rectangle()
                        .frame(width:2, height:10)
                    
                    
                    Button {
                        viewModel.leaderBoardMenu = .info
                    } label: {
                        Text("Info")
                            .font(.montserrat(size:14, weight:.bold))
                            .foregroundStyle(viewModel.leaderBoardMenu == .info ? Color.black : Color.gray)
                    }
                }
                .padding(.vertical, 10)
                if viewModel.leaderBoardMenu == .leaderBoard {
                    ForEach(0..<viewModel.participants.count, id: \.self) { index in
                        let user = viewModel.participants.sorted {
                            ($0.thisWeekSteps ?? 0) > ($1.thisWeekSteps ?? 0)
                        }[index] // Get the user based on the sorted index
                        
                        HStack {
                            Text("\(index + 1)") // Rank number starting from 1
                                .font(.montserrat(size: 16, weight: .bold))
                            
                            Image(user.currentRank?.imageName ?? "")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                            Text("\(user.username ?? "")")
                                .font(.montserrat(size: 16, weight: .bold))
                            
                            Spacer()
                            
                            Text("\(user.thisWeekSteps ?? 0)")
                                .font(.montserrat(size: 16, weight: .bold))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.black)
                        )
                        .foregroundStyle(Color.white)
                    }
                } else {
                    VStack(alignment:.leading){
                        LeagueInfoView(viewModel: viewModel)
                    }
                }
                
                Spacer()
            }
        
        .padding(.top, 20)
        .padding(.horizontal, 15)
        .onAppear {
            viewModel.onLeagueSelected(leagueID: viewModel.leagueId)
        }
           }
}

struct LeagueInfo: View {
    var image: String
    var title: String
    var data: String
    var body: some View {
        HStack(spacing:0){
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:30, height:30)
                .padding(.trailing, 5)
            Text(title)
                .font(.montserrat(size: 16, weight: .bold))
            Text(data)
                .font(.montserrat(size: 16, weight: .regular))
        }
    }
}

struct LeagueInfoView: View {
    @ObservedObject var viewModel: LeaguesViewModel
    var body: some View {
        HStack {
        VStack(alignment:.leading){
                LeagueInfo(image: "calendar.badge.clock", title: "Start date: ", data: "\(viewModel.formattedDate(viewModel.league?.startDate ?? Date()))")
                LeagueInfo(image: "calendar.badge.checkmark", title: "End date: ", data: "\(viewModel.formattedDate(viewModel.league?.endDate ?? Date()))")
                LeagueInfo(image: "person.2", title: "Participants: ", data: "\(viewModel.league?.participants.count ?? 0)")
            }
            Spacer()
        }
    }
}
