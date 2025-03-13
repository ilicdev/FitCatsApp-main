//
//  CustomTextField.swift
//  FitCatsApp
//
//  Created by ilicdev on 4.1.25..
//

import SwiftUI


struct CustomTextField: View {
    let label: String        // Tekst za gornju etiketu
    let placeholder: String  // Placeholder za TextField
    @Binding var text: String // Binding za unos teksta
    var isSecure: Bool = false // Flag da li je polje za lozinku

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.montserrat(size:16, weight:.bold))
                .foregroundColor(Color.gray.opacity(0.6))
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(.vertical, 5)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.5)),
                        alignment: .bottom
                    )
                    .font(.montserrat(size:14, weight:.regular))
                     } else {
                         TextField(placeholder, text: $text)
                             .padding(.vertical, 5)
                             .overlay(
                                 Rectangle()
                                     .frame(height: 1)
                                     .foregroundColor(Color.gray.opacity(0.5)),
                                 alignment: .bottom
                             )
                             .font(.montserrat(size:14, weight:.regular))
                     }
     
        }
        .padding(.horizontal)
    }
}


#Preview {
    CustomTextField(label: "Username", placeholder: "Enter username", text: .constant(""), isSecure: false)
}
