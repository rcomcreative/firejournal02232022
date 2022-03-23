//
//  SettingsResetTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/26/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class SettingsResetTVC: UITableViewController {
    
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var startB: UIButton!
    @IBOutlet weak var resetYourDataB: UIButton!
    var subject:String = ""
    var descriptionText:String = ""
    var settingType:FJSettings!
    var bodyText:String = ""
    
    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    
    var compact:SizeTrait = .regular
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTheText()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        
        switch compact {
        case .compact:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            navigationItem.setLeftBarButtonItems([button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        case .regular:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(updateTheData(_:)))
            
            navigationItem.leftItemsSupplementBackButton = true
            let button3 = self.splitViewController?.displayModeButtonItem
            navigationItem.setLeftBarButtonItems([button3!, button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        }
        self.title = titleName
        descriptionTV.text = bodyText
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
    }
    
    
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact:
                print("compact SETTING RESET DATA")
            case .regular:
                print("regular SETTING RESET DATA")
            }
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func goBackToSettings(_ sender: Any) {
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: nil)
    }
    
    @IBAction func updateTheData(_ sender: Any) {
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: nil)
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func configureTheText() {
        subject = "Fire Journal Reset Data Option"
        descriptionText = "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        bodyText = "Resetting your data will coordinate the data that is in your Fire Journal Cloud data tables with the data that is on your device. This may take some time, depending on how many journal, incident and form entries you have made.\n\nWhen the process is finished you will be taken to the startup screen for the app. Would you like to continue?\n\n\nBy clicking on the start button below you acknowledge that the app (Fire Journal) and the data in your iCloud account for this app will be cleaned and merged.\n\nIf you don't want to move forward tap the done button in the upper right corner.\n\nIf you want to move forward - tap the start button."
    }
    
    @IBAction func startResettingBTapped(_ sender: Any) {
        let alertMessage:String = "You’re about to reset your iCloud storage for this app (Fire Journal) with the data that is stored in this app's databases.\n\nThis cannot be reversed.\n\nContinue?"
        let title:String = "Reset Warning!"
        let alert = UIAlertController.init(title: title, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "I Agree", style: .default, handler: {_ in
            self.resetYourDataBTapped(self)
        })
        alert.addAction(okAction)
        let notOkAction = UIAlertAction.init(title: "I Dissagree", style: .cancel, handler: {_ in
            print("I disagree")
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(notOkAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func resetYourDataBTapped(_ sender: Any) {
        print("you are a bloody fool!")
        //        TODO: kill the data
        self.dismiss(animated: true, completion: nil)
        
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: nil)
    }
    
    // MARK: - Table view data source
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("SettingsInfoHeaderV", owner: self, options: nil)?.first as! SettingsInfoHeaderV
            let color = ButtonsForFJ092018.fillColor38
        headerV.colorV.backgroundColor = color
        headerV.subjectL.text = subject
        headerV.descriptionTV.text = descriptionText
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

}
