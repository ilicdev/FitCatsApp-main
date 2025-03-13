//
//  HomeView.swift
//  FitCatsApp
//
//  Created by ilicdev on 17.1.25..
//

import SwiftUI

struct HomeView: View {
    @StateObject var stepTrackerViewModel: StepTrackerViewModel = StepTrackerViewModel()
    var body: some View {
        ScrollView {
            VStack {
                    TodayScoreView(stepTrackerViewModel: stepTrackerViewModel)
                VStack{
                    StepTrackerView(stepTrackerViewModel: stepTrackerViewModel)
                        .padding(.vertical, 20)
                }
                Spacer()
            }
            .padding(.vertical, 30)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
      
    }
}

struct TodayScoreView: View {
    @ObservedObject var stepTrackerViewModel: StepTrackerViewModel
    var body: some View {
        VStack {
            HStack{
                VStack(alignment:.leading){
                    Text("Today's score")
                        .font(.montserrat(size: 16, weight: .medium))
                        .foregroundStyle(Color.gray)
                    Text("\(stepTrackerViewModel.dailyStepCount)")
                        .font(.montserrat(size:32, weight:.bold))
                }
                Spacer()
                VStack{
                    if let imageName = stepTrackerViewModel.currentRank?.imageName, let name = stepTrackerViewModel.currentRank?.name {
                        Image("\(imageName)")
                            .resizable()
                            .frame(width:60, height:60)
                        Text("\(name)")
                            .font(.montserrat(size:16, weight:.bold))
                    }
              
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 3)
            )
            
        }
        .padding(3)
    }
}


struct StepTrackerView: View {
    @ObservedObject var stepTrackerViewModel: StepTrackerViewModel
    var body: some View {
        VStack{
            progressView(
                currentSteps: Int(stepTrackerViewModel.stepCount),
                nextRank: stepTrackerViewModel.nextRank,
                targetSteps: stepTrackerViewModel.nextRank?.threshold ?? 0
            )
        }
        
    }
    
    private func progressView(currentSteps: Int, nextRank: Rank?, targetSteps: Int) -> some View {
        let progress = stepTrackerViewModel.progressTowardsNextRank()
        return VStack {
            Text("This week progress")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("\(stepTrackerViewModel.formattedWeekDates())")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 23))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200)
                    .shadow(radius: 5)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(
                        Color.black,
                        style: StrokeStyle(
                            lineWidth: 23,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                
                VStack {
                    Text("\(stepTrackerViewModel.stepsLast7Days)")
                         .font(.largeTitle)
                         .fontWeight(.bold)
                    Text("Next: \(nextRank?.name ?? "Cat")")
                         .font(.subheadline)
                         .foregroundColor(.gray)
                }
            }
            .padding()
            if let rankNumber = nextRank?.rank {
                Image("signrank\(rankNumber)")
                    .resizable()
                    .scaledToFit()
                    .shadow(radius: 2)
                    .frame(height: 120)
                    .padding()
            }
        }
    }
}

#Preview {
    HomeView()
}

