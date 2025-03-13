//
//  BlackCustomButton.swift
//  FitCatsApp
//
//  Created by ilicdev on 4.1.25..
//

import SwiftUI

struct BlackCustomButton: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    let cornerRadius: CGFloat
    let destination: AnyView?
    let action: (() -> Void)?
    
    init(title: String, backgroundColor: Color, textColor: Color, cornerRadius: CGFloat, destination: AnyView? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.destination = destination
        self.action = action
    }

    var body: some View {
        Group {
            if let destination = destination {
                NavigationLink(destination: destination) {
                    buttonContent
                }
            } else if let action = action {
                Button(action: action) {
                    buttonContent
                }
            } else {
                buttonContent
            }
        }
    }
    
    private var buttonContent: some View {
        Text(title)
            .foregroundColor(textColor)
            .font(.montserrat(size: 16, weight: .medium))
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}
