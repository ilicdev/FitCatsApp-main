//
//  AboutView.swift
//  FitCatsApp
//
//  Created by ilicdev on 24.1.25..
//

import SwiftUI

struct AboutView: View {
    @StateObject var viewModel = AboutViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Fitness Cats")
                    .font(.montserrat(size: 20, weight: .bold))
                Text("Cats are one of the most popular pets in the world. The cat family includes over 40 different species of cats.")
                    .font(.montserrat(size: 12, weight: .regular))
                    .multilineTextAlignment(.center)
                    .frame(width: 330)
                    .padding(.bottom, 60)
                
                rankName(image: "rank1", rankName: "Cat", steps: "0")
                rankName(image: "rank2", rankName: "Cheetah", steps: "21000")
                rankName(image: "rank3", rankName: "Jaguar", steps: "42000")
                rankName(image: "rank4", rankName: "Leopard", steps: "63000")
                rankName(image: "rank5", rankName: "Tiger", steps: "84000")
                rankName(image: "rank6", rankName: "Lion", steps: "105000")
                Spacer()
            }
            .padding(.horizontal, 10)
            .alert(item: $viewModel.alertItem) { item in
                Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func rankName(image: String, rankName: String, steps: String) -> some View {
        HStack {
            Image(image)
                .resizable()
                .frame(width: 55, height: 55)
            VStack(alignment: .leading) {
                Text("\(rankName)")
                    .font(.montserrat(size: 16, weight: .bold))
                Text("\(steps) steps")
                    .font(.montserrat(size: 16, weight: .regular))
            }
            Spacer()
            Button {
                viewModel.showInfo(for: rankName)
            } label: {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.black)
            }
        }
    }
}
