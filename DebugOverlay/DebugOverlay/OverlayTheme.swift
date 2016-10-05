//
//  OverlayTheme.swift
//  Debug Overlay
//
//  Created by Joshua Kelley on 5/17/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import UIKit

enum PresentingScreenIs {
    case dark
    case light
    
    func overlayBGColorForMode() -> UIColor {
        switch self {
        case .dark   : return UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        case .light  : return UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        }
    }
    
    func textColorForMode() -> UIColor {
        switch self {
        case .dark   : return UIColor(red: 0, green: 254, blue: 0, alpha: 1.0) //UIColor(red: 47.0, green: 255.0, blue: 18.0, alpha: 1.0)
        case .light  : return UIColor.black
        }
    }
}
