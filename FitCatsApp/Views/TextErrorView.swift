//
//  TextErrorView.swift
//  FitCatsApp
//
//  Created by ilicdev on 4.1.25..
//

import SwiftUI

struct TextErrorView: View {
    var errorMessage: String
    var body: some View {
        Text(errorMessage)
            .font(.montserrat(size:14, weight: .bold))
            .foregroundColor(.red)
            .padding(.bottom, 10)
    }
}

