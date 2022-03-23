//
//  ColorExtension.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/18/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    struct fjColor {
        static var incidentRed: UIColor  { return UIColor(red:0.93, green:0.2, blue:0.22, alpha:1) }
        static var emsBlue: UIColor  { return UIColor(red:0.26, green:0.38, blue:0.61, alpha:1) }
        static var emsBlueLite: UIColor  { return UIColor(red:0.26, green:0.38, blue:0.61, alpha:0.5) }
        static var rescueGold: UIColor  { return UIColor(red: 252/255, green: 178/255, blue: 76/255, alpha: 1) }
        static var fireOrange: UIColor  { return UIColor(red: 219/255, green: 87/255, blue: 57/255, alpha: 1) }
        static var formBlue: UIColor  { return UIColor(red: 60/255, green: 70/255, blue: 147/255, alpha: 1) }
        static var clipboardGold: UIColor { return UIColor(red: 248/255, green: 151/255, blue: 52/255, alpha: 1)}
        static var clipboardGreen: UIColor  { return UIColor(red: 36/255, green: 151/255, blue: 79/255, alpha: 1) }
        static var lineGray: UIColor { return UIColor(red:0.94, green:0.94, blue:0.95, alpha:1.0)}
    }
}
