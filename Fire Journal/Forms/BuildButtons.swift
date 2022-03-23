//
//  BuildButtons.swift
//  dashboard
//
//  Created by DuRand Jones on 9/20/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class BuildButtons {

    static var allIncidentsIcon: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100.0, height: 100.0), false, 0.0)
        ButtonsForFJ092018.drawIncidentDataMapButton(numberwidth: 80.0, numberheight: 80.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static var fireIncidentsIcon: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100.0, height: 100.0), false, 0.0)
        ButtonsForFJ092018.drawFireMapButton(numberwidth: 80.0, numberheight: 80.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static var emsIncidentsIcon: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100.0, height: 100.0), false, 0.0)
        ButtonsForFJ092018.drawCorrectemsmapbutton(numberwidth: 80.0, numberheight: 80.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static var rescueIncidentsIcon: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100.0, height: 100.0), false, 0.0)
        ButtonsForFJ092018.drawCorrectrescuemapbutton(numberwidth: 80.0, numberheight: 80.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static var ics214Icon: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100.0, height: 100.0), false, 0.0)
        ButtonsForFJ092018.drawICS214MapButton(numberwidth: 80.0, numberheight: 80.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static var ARCFormIcon: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100.0, height: 100.0), false, 0.0)
        ButtonsForFJ092018.drawARCFormMapButton(numberwidth: 80.0, numberheight: 80.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static var YourLocationIcon: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100.0, height: 100.0), false, 0.0)
        ButtonsForFJ092018.drawUserLocationMapButton(numberwidth: 80.0, numberheight: 80.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static var YourFireStationLocationIcon: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 100.0, height: 100.0), false, 0.0)
        ButtonsForFJ092018.drawFireStationWhitePin(numberwidth: 80.0, numberheight: 80.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
    
    private func buttonColor(frame: CGRect)->CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.colors = [ButtonsForFJ092018.gradientForBoxColor,ButtonsForFJ092018.gradientForBoxColor2]
        return layer
    }
    
}
