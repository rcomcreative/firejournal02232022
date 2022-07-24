//
//  NetworkAlert.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/11/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import Foundation
import UIKit

class NetworkAlert: NSObject {
    
    var title: String!
    var message: String = "This app is not connected to the internet at this time."
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    
    init(name: String) {
        self.title = name
        super.init()
    }
    
    func networkUnavailable()->UIAlertController {
            let title = "Internet Activity"
            let errorString = "This app is not connected to the internet at this time."
            let alert = UIAlertController.init(title: title, message: errorString, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Thanks", style: .default, handler: {_ in
                self.networkOkay()
            })
            alert.addAction(okAction)
            return alert
    }
    
    func networkOkay() {
        DispatchQueue.main.async {
            self.nc.post(name: NSNotification.Name(rawValue: FJkAlertISReleased), object: nil)
        }
    }
    
    
    
    
}
