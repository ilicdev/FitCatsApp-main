//
//  BackButton.swift
//
//
//  Created by ilicdev on 9.1.25..
//
import Foundation
import SwiftUI

struct BackButton: View {
    var action: () -> ()
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 24))
                .foregroundStyle(Color.black)
                .fontWeight(.bold)
                .padding()
        }
    }
}

