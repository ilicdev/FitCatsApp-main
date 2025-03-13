//
//  Statistics.swift
//  FitCatsApp
//
//  Created by ilicdev on 7.1.25..
//

import Foundation


struct Statistics: Codable {
    var totalSteps: Int
    var stepsPerWeek: [Int]
    var ranks: [String] // Store Rank IDs
    var bestRank: String // Store Best Rank ID
}
