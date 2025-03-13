//
//  RootView.swift
//  FitCatsApp
//
//  Created by ilicdev on 9.1.25..
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    var body: some View {
        Group {
           if appViewModel.isAuthenticated {
               MainView()
           } else {
               AuthLandingView()
           }
       }
    }
}

#Preview {
    RootView()
}
