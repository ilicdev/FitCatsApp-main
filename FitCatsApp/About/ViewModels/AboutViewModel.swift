//
//  AboutViewModel.swift
//  FitCatsApp
//
//  Created by ilicdev on 29.1.25..
//

import Foundation

class AboutViewModel: ObservableObject {
    @Published var alertItem: AlertItem?
    
    func showInfo(for rank: String) {
        switch rank {
        case "Cat":
            alertItem = AlertItem(title: "Cat", message: "A small, domesticated carnivore known for its agility and independence.")
        case "Cheetah":
            alertItem = AlertItem(title: "Cheetah", message: "The fastest land animal, reaching speeds up to 120 km/h (75 mph).")
        case "Jaguar":
            alertItem = AlertItem(title: "Jaguar", message: "A powerful big cat with a strong bite, found in South America.")
        case "Leopard":
            alertItem = AlertItem(title: "Leopard", message: "A stealthy predator known for its spotted coat and adaptability.")
        case "Tiger":
            alertItem = AlertItem(title: "Tiger", message: "The largest big cat, famous for its orange coat with black stripes.")
        case "Lion":
            alertItem = AlertItem(title: "Lion", message: "The 'king of the jungle,' known for its mane and social pride structure.")
        default:
            alertItem = nil
        }
    }
}




struct AlertItem: Identifiable {
    var id: String { title }
    var title: String
    var message: String
}
