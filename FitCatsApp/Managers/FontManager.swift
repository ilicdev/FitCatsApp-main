//
//  FontManager.swift
//  FitCatsApp
//
//  Created by ilicdev on 27.12.24..
//

import SwiftUI

enum FontManager {
    static func customFont(name:String, size:CGFloat) -> Font {
        Font.custom(name, size: size)
    }
    
    enum Style {
        case title
             case body
             case button

             var font: Font {
                 switch self {
                 case .title:
                     return Font.custom("Montserrat-Bold", size: 24)
                 case .body:
                     return Font.custom("Montserrat-Regular", size: 16)
                 case .button:
                     return Font.custom("Montserrat-Medium", size: 18)
                 }
             }
    }
}

enum FontWeight {
    case regular
    case bold
    case light
    case medium

    var rawValue: String {
        switch self {
        case .regular: return "Regular"
        case .bold: return "Bold"
        case .light: return "Light"
        case .medium: return "Medium"
        }
    }
}


extension Font {
    static func montserrat(_ style: FontManager.Style) -> Font {
        style.font
    }

    static func montserrat(size: CGFloat, weight: FontWeight = .regular) -> Font {
            Font.custom("Montserrat-\(weight.rawValue)", size: size)
    }
}
