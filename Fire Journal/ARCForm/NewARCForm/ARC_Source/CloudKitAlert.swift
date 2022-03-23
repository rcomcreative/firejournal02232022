//
//  CloudKitAlert.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/24/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import Foundation
import UIKit

class CloudKitAlert: NSObject {
    
    var title: String!
    var message: String = ""
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    
    init(name: String) {
        self.title = name
        super.init()
    }
    
    func fireJournalCloudKitAvailable( email: String, name: String ) ->UIAlertController {
            message = "Hi \(name)! We have found your account for Fire Journal with email address: \(email) would you like to use your information for this app and download those ARC Forms you already have created?"
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Yes", style: .default, handler: {_ in
                self.cloudOkay()
            })
            alert.addAction(okAction)
            let notOkAction = UIAlertAction.init(title: "No", style: .default, handler: {_ in
                self.cloudNotOkay()
            })
        alert.addAction(notOkAction)
            return alert
    }
    
    func cloudOkay() {
        DispatchQueue.main.async {
            self.nc.post(name: NSNotification.Name(rawValue: FJkYESUseCloudData), object: nil)
        }
    }
    
    func cloudNotOkay() {
        DispatchQueue.main.async {
            self.nc.post(name: NSNotification.Name(rawValue: FJkNOUseCloudData), object: nil)
        }
    }

}
