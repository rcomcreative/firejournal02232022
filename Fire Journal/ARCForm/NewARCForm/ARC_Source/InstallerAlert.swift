//
//  InstallerAlert.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 10/5/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import Foundation
import UIKit

class InstallerAlert: NSObject {
    
//    MARK: -PROPERTIES-
    var title: String!
    var message: String = ""
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    var theInstallerName: String = ""
    var textUsername: UITextField?
    
    
    let userDefaults = UserDefaults.standard

    
    init(name: String) {
        self.title = name
        super.init()
    }
    
    func fjARCPlusInstallerNameAlert( theName: String ) ->UIAlertController {
        message = "Would you like to use \(theName) as your default installer name?"
        theInstallerName = theName
        let alert = UIAlertController.init(title: "Installer Name", message: message, preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.text = self.theInstallerName
            }
        let okAction = UIAlertAction.init(title: "Yes", style: .default, handler: {_ in
            if let text = alert.textFields![0].text {
                self.theInstallerName = text
            }
            self.userName()
        })
        
        let notOkAction = UIAlertAction.init(title: "No Don't Set", style: .default, handler: {_ in
            self.notOkay()
        })
        
        alert.addAction(okAction)
        alert.addAction(notOkAction)
        return alert
    }
    
    func userName() {
        userDefaults.set(self.theInstallerName, forKey: FJkDefaultInstallerName)
        userDefaults.set(true, forKey: FJkDefualtInstallerNameSaved)
        DispatchQueue.main.async {
            self.nc.post(name: NSNotification.Name(rawValue: FJkDefaultInstallerName ), object:nil, userInfo: ["name": self.theInstallerName ])
        }
    }
    
    func notOkay() {
        userDefaults.set(false, forKey: FJkDefualtInstallerNameSaved)
        DispatchQueue.main.async {
            self.nc.post(name: NSNotification.Name(rawValue: FJkDefaultInstallerName ), object: nil, userInfo: ["name": ""])
        }
    }
    
}
