
//
//  Rank.swift
//  FitCatsApp
//
//  Created by ilicdev on 7.1.25..
//

import Foundation

struct Rank: Codable {
    var name: String = "Cat"
    var imageName: String = "rank1"
    var rank:Int = 0
    var threshold: Int?

    var color: String = ""
    var minSteps: Int?
    var maxSteps: Int?
}

